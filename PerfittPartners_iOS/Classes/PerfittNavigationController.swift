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
        
//        var backButtonBackgroundImage = UIImage(named: "icBackBlack")!
        var backButtonBackgroundImage = UIImage.getImageResource(imageName: "icBackBlack")!
        backButtonBackgroundImage = backButtonBackgroundImage.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: backButtonBackgroundImage.size.width - 1, bottom: 0, right: 0))
        
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        barButtonItemAppearance.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .selected)
        
        
        let barAppearance =
                UINavigationBar.appearance(whenContainedInInstancesOf: [PerfittNavigationController.self])
        
        barAppearance.backItem?.title = ""
        barAppearance.backIndicatorImage = backButtonBackgroundImage
        barAppearance.backIndicatorTransitionMaskImage = backButtonBackgroundImage
        
        
        
        
        navigationBar.tintColor = .black
        navigationBar.isTranslucent = true
        
        navigationBar.layer.masksToBounds = false
        navigationBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        navigationBar.layer.shadowOpacity = 0.8
        navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        navigationBar.layer.shadowRadius = 2
        
        navigationBar.barTintColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]

    }
    
}
