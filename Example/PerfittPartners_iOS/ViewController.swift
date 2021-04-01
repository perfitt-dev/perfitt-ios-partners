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
    var popupWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // partner사가 작성하는곳
        PerfittPartners.instance.initializeApiKey(APIKey: "PARTNERS_TEST_KEY", vc: self)
        
        self.loadURL()
    }
    
    private func loadURL() {
//        let url = URL(string: "http://m.sgumg.cafe24.com")!
        let url = URL(string: "http://www.sappun.co.kr/preview/?dgnset_type=MOBILE&dgnset_id=14412")!
        let request = URLRequest(url: url)
        self.webView.load(request)
        // partner사가 작성하는 곳 ( javascript 연결 )
        self.webView.configuration.userContentController.add(PerfittPartners.instance.bridgeJavaScript, name: PerfittPartners.instance.contentKit)
        self.webView.configuration.userContentController.add(PerfittPartners.instance.bridgeJavaScript, name: PerfittPartners.instance.contentA4)
        
        // partner사가 작성하는 곳 ( call back 데이터 )
        PerfittPartners.instance.onConfirm(completion: { callback in
            self.webView.evaluateJavaScript(callback, completionHandler: { (any, err) in
                if let callBackError = err {
                    debugPrint("callback error: \(callBackError.localizedDescription)")
                    return
                }
                // TODO: any 데이터를 활용해서
            })
        })
        
        self.webView.uiDelegate = self
        // webview popup permission
        self.webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ViewController {
    @IBAction func onRunSDK(_ sender: UIButton) {
        PerfittPartners.instance.runSDK("member_id")
    }
    
}


extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            // init popup webview
            self.popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
            self.popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            // for popup close
            self.popupWebView?.navigationDelegate = self
            self.popupWebView?.uiDelegate = self
            
            // add main view
            self.view.addSubview(self.popupWebView!)
            
            return self.popupWebView!
        }
}

// close popup
extension ViewController: WKNavigationDelegate {
    func webViewDidClose(_ webView: WKWebView) {
        // popup close
        webView.removeFromSuperview()
        popupWebView = nil
    }
}
