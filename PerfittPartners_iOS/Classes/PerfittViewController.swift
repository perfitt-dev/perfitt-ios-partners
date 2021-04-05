//
//  PerfittViewController.swift
//  Pods
//
//  Created by nick on 2021/02/18.
//

import UIKit

class PerfittViewController: UIViewController {
    // indicator
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.color = .red
        indicator.backgroundColor = .white
        
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}


// MARK : Alert
extension PerfittViewController {
    
    func showAlertTwoBtn(title: String, message: String, handler: ((UIAlertAction) -> ())?, cancelHandler: ((UIAlertAction) -> ())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: cancelHandler)
        controller.addAction(cancelAction)
        controller.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, vc: UIViewController, handler: ((UIAlertAction) -> ())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        controller.addAction(okAction)
        
        vc.present(controller, animated: true, completion: nil)
    }

}

// MARK: Indicator
extension PerfittViewController {
    func showActivityIndicator() {
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.activityIndicator)

        NSLayoutConstraint.activate([
            self.activityIndicator.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.activityIndicator.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            self.activityIndicator.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.activityIndicator.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        self.activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    func setNaviRightItem() {

        let barItemImage = UIImage.getImageResource(imageName: "icCloseBlack")
        let rightItem = UIBarButtonItem(image: barItemImage, style: .plain, target: self, action: #selector(self.onClose))
        self.navigationItem.setRightBarButton(rightItem, animated: true)
    }
    
    @objc private func onClose() {
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
}
