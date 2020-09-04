//
//  ViewController.swift
//  PerfittPartners_iOS
//
//  Created by perfitt-dev on 09/04/2020.
//  Copyright (c) 2020 perfitt-dev. All rights reserved.
//

import UIKit
import PerfittPartners_iOS

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPerfittPartners(_ sender: UIButton) {
        sender.isHidden = true
        if let testView: UIImageView = PerfittPartners(frame: self.view.frame)  {
            self.view.addSubview(testView)
        }
    }
}

