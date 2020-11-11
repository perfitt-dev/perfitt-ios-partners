//
//  ViewController.swift
//  PerfittPartners_iOS
//
//  Created by perfitt-dev on 09/04/2020.
//  Copyright (c) 2020 perfitt-dev. All rights reserved.
//

import UIKit
import WebKit
import PerfittPartners_iOS

class ViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadURL()
        NotificationCenter.default.addObserver(self, selector: #selector(callJSMethod), name: NSNotification.Name(rawValue: "PerfittPartners"), object: nil)
        
        //        Perfitt.instance.onConfirm(completion: { methodName in
        //            self.webView.evaluateJavaScript(methodName, completionHandler: nil)
        ////            self.webView.evaluateJavaScript(methodName, completionHandler: { (perfittResult, err) in
        ////                if let callBackError = err {
        ////                    debugPrint("callback error: \(callBackError)")
        ////                    return
        ////
        ////                    // TODO: 결과 값을 이용해 기능구현?
        ////                }
        ////
        ////            })
        //        })
    }
    
    // partner사가 작성하는곳
    private func loadURL() {
        let url = URL(string: "http://m.sgumg.cafe24.com")!
        let request = URLRequest(url: url)
        self.webView.load(request)
        
        self.webView.configuration.userContentController.add(self, name: PerfittPartners.instance.contentKit)
        self.webView.configuration.userContentController.add(self, name: PerfittPartners.instance.contentA4)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc private func callJSMethod(_ notification: Notification) {
        // TODO
//        PerfittPartners.instance.delegate?.confirm()
        // PerfitPartners.instance.onConfirm(){ apiKey ->
        // webview.laodUrl(url)
        //}
        guard let callBackName = notification.userInfo?["methodName"] as? String else { return }
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(callBackName, completionHandler: { (any, err) in
                if let callBackError = err {
                    debugPrint("callback error: \(callBackError)")
                    return
                    
                    // TODO: 결과 값을 이용해 기능구현?
                }
                
            })
        }
    }
    
}


extension ViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        // PERFITT_SDK ( KIT )
        if (message.name == PerfittPartners.instance.contentKit) {
            let camera = PerfittPartners.instance.getKitCamera()
            self.present(camera, animated: true, completion: nil)
        }
        // PERFITT_SDK ( A4 )
        else if (message.name == PerfittPartners.instance.contentA4) {
            let camera = PerfittPartners.instance.getA4Camera()
            self.present(camera, animated: true, completion: nil)
        }
    }

}
