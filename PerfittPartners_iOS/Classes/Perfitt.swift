//
//  Perfitt.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/10/23.
//

import Foundation
import WebKit

open class Perfitt {
    public static var instance = Perfitt()
    public static var delegate: PartnersDelegate?
//    public static var delegate: PerfittDelegate?
    public var messageName: String {
        get {
            return "PERFITT_SDK"
        }
    }
    
//    public var startSDK: UIViewController {
//        get {
//            return PerfittPartners()
//        }
//    }
    
    public func getPerfittContentController(_ target: WKScriptMessageHandler) -> WKUserContentController{
        let contentController = WKUserContentController()
        contentController.add(target, name: self.messageName)
        return contentController
    }
    
    public func onConfirm(_ delegate: PartnersDelegate?) {
        Perfitt.delegate = delegate
    }
    
//    public func onConfirm(_ delegate: PerfittDelegate?) {
//        self.delegate = sele
//    }
    
    public func measuserFootStart(_ rootViewController: UIViewController) {
        let alert = UIAlertController(title: "TEST", message: "measure foot start", preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        rootViewController.present(alert, animated: true, completion: nil)
    }
    
    public func initializeApiKey(APIKey: String) {
        // TODO: - APIKey 인증 방식 설정
        /**
         * APIController.ini().authAPIKey() {
         *      successHandler( nil),
         *      failedHandler( { _ in
         *        failedError("failed auth api key ") } )
         * }
         */
    }
    
//    @propertyWrapper
}

public protocol PartnersDelegate {
    func onConfirm(value: String)
}
//
//public protocol PerfittDelegate {
//    func onConfirm(value: String)
//}
