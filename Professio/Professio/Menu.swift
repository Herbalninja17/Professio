//
//  Menu.swift
//  Professio
//
//  Created by issd on 07/10/2018.
//  Copyright © 2018 Omnia. All rights reserved.
//

import UIKit
import ARKit

class Menu: SCNNode {
    
    func loadModels() {
        
        guard let menuOption = SCNScene(named: "art.scnassets/meny.scn") else {return}
        let warpperNode = SCNNode()
        for child in menuOption.rootNode.childNodes{
            warpperNode.addChildNode(child)
        }
        
        self.addChildNode(warpperNode)
        
    }

}
