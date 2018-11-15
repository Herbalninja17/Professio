//
//  HomeViewController.swift
//  Professio
//
//  Created by issd on 26/10/2018.
//  Copyright © 2018 Omnia. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet var homeBtn1: UIButton!
    @IBOutlet var homeBtn2: UIButton!
    @IBOutlet var homeBtn3: UIButton!
    @IBOutlet var logo: UIImageView!
    
    var uibutton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeBtn1.alpha = 0.0
        self.homeBtn2.alpha = 0.0
        self.homeBtn3.alpha = 0.0
        self.logo.alpha = 0.0
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        UIView.animate(withDuration: 1.0, animations: {
            self.homeBtn1.alpha = 1.0
            self.homeBtn2.alpha = 1.0
            self.homeBtn3.alpha = 1.0
            self.logo.alpha = 1.0
            
        }, completion: nil)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
