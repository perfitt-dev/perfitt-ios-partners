//
//  BaseController.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/04.
//

import UIKit

open class BaseController: UIViewController {
    public func showAlertTwoBtn(title: String, message: String, handler: ((UIAlertAction) -> ())?, cancelHandler: ((UIAlertAction) -> ())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: cancelHandler)
        controller.addAction(cancelAction)
        controller.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
    
    public func showAlert(title: String, message: String, handler: ((UIAlertAction) -> ())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        controller.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
        
    }
}
