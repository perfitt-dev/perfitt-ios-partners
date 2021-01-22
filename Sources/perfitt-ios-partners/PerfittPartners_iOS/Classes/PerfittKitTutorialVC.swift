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

        // Do any additional setup after loading the view.
        let urlStr = "https://www.notion.so/46745cc28caa4418afa928b48cdc7048"
        guard let url = URL(string: urlStr) else { return }
        
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
    
    @IBAction func onStart(_ sender: UIButton) {
        let bundles = Bundle.main.loadNibNamed("PerfittKitCameraVC", owner: nil, options: nil)
        let cameraVC = bundles?.filter( { $0 is PerfittKitCameraVC }).first as? PerfittKitCameraVC
        cameraVC!.rightImg = true
        self.navigationController?.pushViewController(cameraVC!, animated: true)
    }

}
