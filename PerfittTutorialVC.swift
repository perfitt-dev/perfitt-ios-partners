//
//  PerfittTutorialVC.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/18.
//

import UIKit
import WebKit

class PerfittTutorialVC: UIViewController {
    
    private var webView: WKWebView!
    fileprivate let tutorialURL = "https://service.perfitt.io/howtomeasure"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    fileprivate func setup() {
        self.webView = WKWebView(frame: self.view.frame)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(webView)
        NSLayoutConstraint.activate([
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        self.loadWebView()
    }
    
    fileprivate func loadWebView() {
        let url = URL(string: tutorialURL)!
        let request = URLRequest(url: url)
        
        self.webView.load(request)
    }
    
    
    
}
