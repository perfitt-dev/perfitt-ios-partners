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
    
        self.loadURL()
        
        NotificationCenter.default.addObserver(self, selector: #selector(callJSMethod), name: NSNotification.Name(rawValue: "PerfittPartners"), object: nil)
        
    }
    
    private func loadURL() {
//        let url = URL(string: "https://perfitt-static-files.s3.ap-northeast-2.amazonaws.com/resources/clutter/test.html")!
        let url = URL(string: "http://m.sgumg.cafe24.com")!
        let request = URLRequest(url: url)
        self.webView.load(request)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.configuration.userContentController.add(self, name: "PERFITT_SDK")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc private func callJSMethod(_ notification: Notification) {
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


extension ViewController: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if (message.name == "PERFITT_SDK") {
            if let getKey = message.body as? String {

                let vc = PerfittPartners(APIKey: getKey)
                self.navigationController?.pushViewController(vc, animated: true)
                
            }


        }
    }
    
    
}
