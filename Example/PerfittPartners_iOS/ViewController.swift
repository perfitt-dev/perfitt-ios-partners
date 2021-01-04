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
        
        // partner사가 작성하는곳
        PerfittPartners.instance.initializeApiKey(APIKey: "PARTNERS_TEST_KEY", vc: self)
        self.loadURL()
    }
    
    
    private func loadURL() {
        let url = URL(string: "http://m.sgumg.cafe24.com")!
        let request = URLRequest(url: url)
        self.webView.load(request)
        
        // partner사가 작성하는 곳 ( javascript 연결 )
        self.webView.configuration.userContentController.add(PerfittPartners.BridgeJavaScript(), name: PerfittPartners.instance.contentKit)
        self.webView.configuration.userContentController.add(PerfittPartners.BridgeJavaScript(), name: PerfittPartners.instance.contentA4)
        
        // partner사가 작성하는 곳 ( call back 데이터 )
        PerfittPartners.instance.onConfirm(completion: { callback in
//            DispatchQueue.main.async {
            self.webView.evaluateJavaScript(callback, completionHandler: { (any, err) in
                if let callBackError = err {
                    debugPrint("callback error: \(callBackError.localizedDescription)")
                    return
                }
                // TODO: any 데이터를 활용해서
            })
//            }
            
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
