//
//  PerfittKitTutorialVC.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/12/29.
//

import UIKit
import WebKit

class PerfittKitTutorialVC: PerfittViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "촬영 가이드"
        // Do any additional setup after loading the view.
        let urlStr = "https://service.perfitt.io/app/guides?app=mobile"
        guard let url = URL(string: urlStr) else { return }
        self.setNaviRightItem()
        
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
                    self.moveToCam()
                    
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

extension PerfittKitTutorialVC {
    private func moveToCam() {
        let kitCameraVC = PerfittKitCameraVC.initViewController(viewControllerClass: PerfittKitCameraVC.self)
        kitCameraVC.rightImg = true
        self.navigationController?.pushViewController(kitCameraVC, animated: true)
    }
    
//    private func setNaviRightItem() {
//        let barItemImage = UIImage(named: "icCloseBlack")
//        let rightItem = UIBarButtonItem(image: barItemImage, style: .plain, target: self, action: #selector(self.onClose))
//        self.navigationItem.setRightBarButton(rightItem, animated: true)
//    }
//
//    @objc private func onClose() {
//        DispatchQueue.main.async {
//            self.navigationController?.dismiss(animated: true, completion: nil)
//        }
//    }
}
