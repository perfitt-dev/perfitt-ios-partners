//
//  PerfittNavigationController.swift
//  Pods
//
//  Created by nick on 2021/02/18.
//
import UIKit

class PerfittNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .fullScreen
        
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        barButtonItemAppearance.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .selected)
        
        let barAppearance =
                UINavigationBar.appearance(whenContainedInInstancesOf: [PerfittNavigationController.self])
        
        barAppearance.backItem?.title = ""
        
        
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .black

//
    }
}
