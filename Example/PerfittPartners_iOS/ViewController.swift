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
        
        if let testView: UIView = PerfittPartners(frame: CGRect(x: 0, y: 100, width: 300, height: 300))  {
            self.view.addSubview(testView)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

