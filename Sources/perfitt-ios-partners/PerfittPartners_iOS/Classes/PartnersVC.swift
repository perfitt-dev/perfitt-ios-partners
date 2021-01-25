//
//  PartnersVC.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/10/28.
//

import Foundation

public class PartnersVC: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.showAlertTwoBtn(title: "adsfa", message: "sdfsdf", handler: { _ in
            let bundles = Bundle.main.loadNibNamed("PerfittCameraVC", owner: self, options: nil)
            let cameraVC = bundles?.filter({ $0 is PerfittCameraVC }).first as? PerfittCameraVC
            let navi = UINavigationController(rootViewController: cameraVC!)
            navi.modalPresentationStyle = .overFullScreen
            
            let time = DispatchTime.now() + .milliseconds(100)
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.present(navi, animated: true, completion: nil)
            }
            
        }, cancelHandler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func showAlertTwoBtn(title: String, message: String, handler: ((UIAlertAction) -> ())?, cancelHandler: ((UIAlertAction) -> ())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: cancelHandler)
        controller.addAction(cancelAction)
        controller.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
}

