//
//  SizePickerController.swift
//  Pods
//
//  Created by nick on 2021/02/18.
//

import Foundation

class SizePickerController: NSObject, SizePickerDelegate {
    func onConfirm() {
        // move to camera
        switch PerfittPartners.instance.status {
        case .A4:
            debugPrint("ing")
            self.moveToA4Tutorial()
        case .Kit:
            self.moveToKitTutorial()
        }
    }
}

extension SizePickerController {
    private func moveToKitTutorial() {
        let tutorialVC = PerfittKitTutorialVC.initViewController(viewControllerClass: PerfittKitTutorialVC.self)
        let navigationController = PerfittNavigationController(rootViewController: tutorialVC)
        
        let time = DispatchTime.now() + .milliseconds(300)
        DispatchQueue.main.asyncAfter(deadline: time) {
            PerfittPartners.instance.ownerViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    private func moveToA4Tutorial() {
        
    }
    
    
}

