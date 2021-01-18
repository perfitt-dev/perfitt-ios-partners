//
//  FeetResultVC.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/12/11.
//

import UIKit

class FeetResultVC: UIViewController {
    
    @IBOutlet weak var leftWidth: UILabel!
    @IBOutlet weak var leftLength: UILabel!
    
    @IBOutlet weak var rightWidth: UILabel!
    @IBOutlet weak var rightLength: UILabel!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var inputGender: UISegmentedControl!
    
    var model: FeetModel?
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.color = .red
        indicator.backgroundColor = .white
        
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupUI()
    }
    
    private func setupUI() {
        self.leftWidth.text = String(format: "%.0fmm", model?.feet?.left?.width ?? 0.0)
        self.leftLength.text = String(format: "%.0fmm", model?.feet?.left?.length ?? 0.0)
        self.rightWidth.text = String(format: "%.0fmm", model?.feet?.right?.width ?? 0.0)
        self.rightLength.text = String(format: "%.0fmm", model?.feet?.right?.length ?? 0.0)
        
        self.name.returnKeyType = .done
        self.name.delegate = self
    }
    
    @IBAction func onReset(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onConfirm(_ sender: UIButton) {
        guard let nickName = self.name.text else { return }
        let gender = self.inputGender.selectedSegmentIndex == 0 ? "M" : "F"
        
//        let body = FootModel(averageSize: PerfittPartners.instance.getAverageSize(), nickName: nickName, gender: gender, customerId: nil)
        let body = FootModel(feetId: model?.id, averageSize: PerfittPartners.instance.getAverageSize(), nickName: nickName, gender: gender, customerId: nil)
        
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.activityIndicator)
        
        NSLayoutConstraint.activate([
            self.activityIndicator.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.activityIndicator.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            self.activityIndicator.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.activityIndicator.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        self.activityIndicator.startAnimating()
        
        APIController.init().reqeustFootData(body, PerfittPartners.instance.getAPIKey() ?? "", successHandler: { result in
            
            
            DispatchQueue.main.async {
                let callBackResult = "PERFITT_CALLBACK('\(result ?? "")')"
                PerfittPartners.instance.callbackName = callBackResult
                PerfittPartners.instance.nativeCallbackName = result ?? ""
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                self.navigationController?.dismiss(animated: true, completion: nil)
            }

        }, failedHandler: { errorResult in
            debugPrint("api request failed", errorResult.message)
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                self.showAlert(title: "", message: errorResult.message, handler: { _ in
                    self.navigationController?.dismiss(animated: true, completion: nil)
                })
            }
            
        })
    }
    
    private func showAlert(title: String, message: String, handler: ((UIAlertAction) -> ())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        controller.addAction(okAction)
        
        self.present(controller, animated: true, completion: nil)
//        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }


}

extension FeetResultVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        return true
    }
}
