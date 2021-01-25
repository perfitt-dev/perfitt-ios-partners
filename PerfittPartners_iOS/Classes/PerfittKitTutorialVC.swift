//
//  PerfittKitTutorialVC.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/12/29.
//

import UIKit
import WebKit

class PerfittKitTutorialVC: UIViewController {
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "촬영 가이드"
        // Do any additional setup after loading the view.
        let urlStr = "https://service.perfitt.io/app/guides?app=mobile"
        guard let url = URL(string: urlStr) else { return }
        
        let request = URLRequest(url: url)
        
        self.webView.load(request)
        self.webView.navigationDelegate = self
    }
}

extension PerfittKitTutorialVC: WKNavigationDelegate{
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        debugPrint("click type", navigationAction.navigationType.rawValue)
        if navigationAction.navigationType == .other {
            // 이동하는 url catch
            if let url = navigationAction.request.url?.absoluteString {
                
                if url.contains("/app/guides/start") {
                    let bundles = Bundle.main.loadNibNamed("PerfittKitCameraVC", owner: nil, options: nil)
                    let cameraVC = bundles?.filter( { $0 is PerfittKitCameraVC }).first as? PerfittKitCameraVC
                    cameraVC!.rightImg = true
                    self.navigationController?.pushViewController(cameraVC!, animated: true)
                    
                    // 웹 뷰 페이지 전환 제어
                    decisionHandler(.cancel)
                }
                else {
                    // 웹 뷰 페이지 전환 제어
                    decisionHandler(.allow)
                }
                return
            }
            
        }
        decisionHandler(.allow)

    }
}
