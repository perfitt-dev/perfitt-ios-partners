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
        // Do any additional setup after loading the view, typically from a nib.
        
//        PerfittPartners.instance.initializeApiKey(APIKey: "apikey")
        
        
        self.loadURL()
        
        //        Perfitt.instance.initializeApiKey(APIKey: "apikey")
        //
        //        Perfitt.instance.onConfirm({ value in
        //
        //        })
        
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
        
        self.webView.configuration.userContentController.add(self, name: PerfittPartners.instance.contentName)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc private func callJSMethod(_ notification: Notification) {
        // TODO
        PerfittPartners.instance.delegate?.confirm()
        // PerfitPartners.instance.onConfirm(){ apiKey ->
        // webview.laodUrl(url)
        //}
        guard let callBackName = notification.userInfo?["methodName"] as? String else { return }
        webView.evaluateJavaScript(callBackName, completionHandler: { (any, err) in
            if let callBackError = err {
                debugPrint("callback error: \(callBackError)")
                return
                
                // TODO: 결과 값을 이용해 기능구현?
            }
            
        })
    }
    
}


extension ViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if (message.name == PerfittPartners.instance.contentName) {
            if let getKey = message.body as? String {
                guard let vc = Bundle.main.loadNibNamed("PerfittCameraVC", owner: self, options: nil)?.first as? UIViewController else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
    }

}
