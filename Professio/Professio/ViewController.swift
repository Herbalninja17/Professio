//
//  ViewController.swift
//  Professio
//
//  Created by issd on 04/10/2018.
//  Copyright © 2018 Omnia. All rights reserved.
//

import UIKit
import SceneKit // scene to load 3d world
import ARKit // for AR things
import AVFoundation // for video and audio
import SpriteKit // sprite to load the video, images and websites on
import Firebase
import WebKit // webpage

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var test: ARSCNView!
    var socials = ""
    var ref: DatabaseReference!
    var trackedImageClicked = ""
    var imageFound = false
    var wallNode = SCNNode()
    
    struct Info {
        var name: String?
        var type: String?
        var ig: String?
        //var fb: String?
        //var tw: String?
        //var slideshowUrl: String?
        //var videoFileUrl: String?
        //var wallFileUrl: String?
    }
    
    var infoCompare : [Info] = [ Info(name: nil, type: nil, ig: nil)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        ref.observeSingleEvent(of: .value, with: { snapshot in
            //print(snapshot.childrenCount) // get the expected number of items
           
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                guard let restDict = rest.value as? [String: Any] else { continue }
                let name = restDict["name"] as? String
                let ig = restDict["ig"] as? String
                let type = restDict["type"] as? String
                //print(name, ig, type)
                self.infoCompare.append(Info(name: name, type: type, ig: ig))
//                for (index, Info) in self.infoCompare.enumerated(){
//                    if(Info.name == name){
//                        print(Info.ig) //test code
//                    }
//                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSceneView()
        
        
    }
    
    func startSceneView(){
        
        // 1.1 Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // 1.2 check if rss file is null
        guard let arImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {return}
        
        // 1.3. configure tracking img
        configuration.detectionImages = arImages
        configuration.maximumNumberOfTrackedImages = 100
        
        // 1.4 Set the view's delegate
        sceneView.delegate = self
        
        // 1.5 Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //let scene = SCNScene(named: "art.scnassets/girl.scn")!
        //sceneView.scene = scene
        
        // 1.6 Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let trackedImageName = trackedImageClicked //this
        if let touch = touches.first {
            let location = touch.location(in: sceneView)
            
            let hitList = sceneView.hitTest(location, options: nil)
            
            if let hitObject = hitList.first {
                let node = hitObject.node
                
                print(trackedImageName)
                
                for (_, Info) in self.infoCompare.enumerated(){
                    if(Info.name == trackedImageName){
                        if node.name == "instagramPlane" {
                            let Username =  "\(Info.ig!)" // Your Instagram Username here
                            let appURL = URL(string: "instagram://user?username=\(Username)")!
                            let application = UIApplication.shared
                            
                            if application.canOpenURL(appURL) {
                                application.open(appURL)
                            } else {
                                // if Instagram app is not installed, open URL inside Safari
                                let webURL = URL(string: "https://instagram.com/\(Username)")!
                                application.open(webURL)
                            }
                        }
                        if node.name == "facebookPlane" {
                            socials = "https://www.facebook.com/\(Info.ig!)"
                            performSegue(withIdentifier: "segue", sender: self)
                        }
                        if node.name == "twitterPlane" {
                            socials = "https://twitter.com/hashtag/\(Info.ig!)"
                            performSegue(withIdentifier: "segue", sender: self)
                        }
                    }
                }
            }
            
        }
        if imageFound == true {
            
            guard let touch = touches.first else { return }
            let results = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
            guard let hitFeature = results.last else { return }
            let hitTransform = SCNMatrix4(hitFeature.worldTransform) // <- if higher than beta 1, use just this -> hitFeature.worldTransform
            let hitPosition = SCNVector3Make(hitTransform.m41,
                                             hitTransform.m42,
                                             hitTransform.m43)
            createWall(hitPosition: hitPosition, wallNode: wallNode)
        
            //imageFound = false

        }
    }
    
    func createWall(hitPosition : SCNVector3, wallNode : SCNNode) {
        wallNode.position = hitPosition
        sceneView.scene.rootNode.addChildNode(wallNode)
        
    }
    
    func createBall(hitPosition : SCNVector3) {
        let newBall = SCNSphere(radius: 0.01)
        let newBallNode = SCNNode(geometry: newBall)
        newBallNode.position = hitPosition
        self.sceneView.scene.rootNode.addChildNode(newBallNode)
    }
    
    //2 Define the name and node of the soon to be tracked image (c# equivelent of properties statements)
    struct TrackedImage {
        var name : String?
        var node : SCNNode?
        var videoplayback: SKVideoNode?
        //var info: [Info]? = [Info(contentType: nil, ig: nil, fb: nil, tw: nil, slideshowUrl: nil, videoFileUrl: nil, wallFileUrl: nil)]
    }
    
    //2.1 Create an Array list of the Tracked image Properties
    var trackedImages : [TrackedImage] = [ TrackedImage(name: nil, node: nil, videoplayback: nil)]
    
    //3 To add all found images and creates their nodes
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //3.1 search for images thats registered on the assets folder
        guard let currentImageAnchor = anchor as? ARImageAnchor else { return }
        let name = currentImageAnchor.name!
        
        //3.2 register all found images in th earray list (this will work 24/7)
        trackedImages.append(TrackedImage(name: name, node: nil, videoplayback: nil))
        
        //3.3 reconizes all registered images thats in the camera's view
        if let imageAnchor = anchor as? ARImageAnchor{
            // Get the reference ar image
            let referenceImage = imageAnchor.referenceImage
            
            // load scene by name (always have to name the scene after the image)
            let scene = SCNScene(named: "art.scnassets/\(referenceImage.name!).scn")!
            
            // link the "container" node with the rootNode, parent child relationship
            guard let container = scene.rootNode.childNode(withName: "container", recursively: false) else { return }
            container.removeFromParentNode() //just in case its linked to any other nodes
            
            for (_, Info) in self.infoCompare.enumerated(){
                if(Info.name == referenceImage.name){
                    print(Info.type!)
                    if(Info.type == "video"){
                        //video
                        let urll = Info.name
                        let videoURL = Bundle.main.url(forResource: urll, withExtension: "mp4")!
                        let videoPlayer = AVPlayer(url: videoURL)
                        let videoScene = SKScene(size: CGSize(width: 1080.0, height: 1920.0))
                        
                        let videoNode = SKVideoNode(avPlayer: videoPlayer)
                        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
                        videoNode.size = videoScene.size
                        videoNode.yScale = -1
                        videoNode.play()
                        videoScene.addChild(videoNode)
                        
                        guard let video = container.childNode(withName: "videoPlane", recursively: false) else {return}
                        video.geometry?.firstMaterial?.diffuse.contents = videoScene
                        
                        for (index, TrackedImage) in trackedImages.enumerated(){
                            if(TrackedImage.name == referenceImage.name){
                                trackedImages[index].videoplayback = videoNode
                                
                            }
                        }
                        
                    }
                    if(Info.type == "slideshow"){
                        
                        DispatchQueue.main.async {
                            let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 1920, height: 1080))
                            let request = URLRequest(url: URL(string: "https://insidethehead.co/chapters#age")!)
                            
                            webView.loadRequest(request)
                            
                            guard let web = container.childNode(withName: "videoPlane", recursively: false) else {return}
                            web.geometry?.firstMaterial?.diffuse.contents = webView
                        }
                    }
                    if(Info.type == "wall"){
                        
                        
                        //imageFoundName = Info.name!
                        //imageFoundHeight = referenceImage.physicalSize.height
                        //imageFoundWidth = referenceImage.physicalSize.width
                        //imageFound = true
                        let backgroundImageView = UIImageView(image: UIImage(named: "art.scnassets/\(Info.name!).jpg"))
                        guard let wall = container.childNode(withName: "videoPlane", recursively: false) else {return}
                        wall.geometry?.firstMaterial?.diffuse.contents = backgroundImageView
                        
                        // Create a plane to match the detected image.
                        let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
                        plane.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
                        
                        // Create SCNNode from the plane
                        let planeNode = SCNNode(geometry: plane)
                        planeNode.eulerAngles.x = .pi / 2
                        
                        
                        planeNode.addChildNode(container)// Add container to the main node
                        self.wallNode = planeNode
                        imageFound = true
                        
                        // Add the plane to the scene.
                        //sceneView.scene.rootNode.addChildNode(planeNode)
                        
                    }
                    if(Info.type != "wall"){
                        
                        // Create a plane to match the detected image.
                        let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
                        plane.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
                        
                        // Create SCNNode from the plane
                        let planeNode = SCNNode(geometry: plane)
                        //planeNode.eulerAngles.x = -.pi / 2
                        
                        planeNode.addChildNode(container)// Add container to the main node
                        
                        // Add the plane to the scene.
                        node.addChildNode(planeNode)
                        
                        // for each traced image thats registered, link its content to its name
                        for (index, TrackedImage) in trackedImages.enumerated(){
                            if(TrackedImage.name == referenceImage.name){
                                trackedImages[index].node = planeNode
                                
                            }
                        }
                        
                    }
                    
                    
                    
                }
                
            }
            
            
            
            
        }
        
        //test code for console
//        for item in trackedImages {
//            print(item)
//        }
        
    }
    
    //4 keep track of changing images so it can display correct content
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if let imageAnchor = anchor as? ARImageAnchor{
            let referenceImage = imageAnchor.referenceImage
            // Search the corresponding node for the ar image anchor
            for (_, TrackedImage) in trackedImages.enumerated(){
                if(TrackedImage.name == referenceImage.name){
                    // Check if track is lost on ar image
                    
                    if(imageAnchor.isTracked){
                        // The image is being tracked
                        TrackedImage.videoplayback?.play()
                        TrackedImage.node?.isHidden = false
                        trackedImageClicked = referenceImage.name!
                        
                    }else{
                        // The image is lost
                        //print("image is lost")
                        TrackedImage.videoplayback?.pause()
                        TrackedImage.node?.isHidden = true // Hide or delete content
                        //print(TrackedImage)//test code
                    }
                    break
                }
            }
        }
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
