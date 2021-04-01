//
//  FeetResultVC.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/12/11.
//

import UIKit

class FeetResultVC: PerfittViewController {
    @IBOutlet weak var leftWidth: UILabel!
    @IBOutlet weak var leftLength: UILabel!
    
    @IBOutlet weak var rightWidth: UILabel!
    @IBOutlet weak var rightLength: UILabel!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var footImage: UIImageView!
    
    @IBOutlet weak var inputGender: UISegmentedControl!
    
    var model: FeetModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupUI()
    }
}

// MARK: - Data Bind
extension FeetResultVC {
    private func setupUI() {
        self.title = "측정 결과"
        self.leftWidth.text = String(format: "%.0fmm", model?.feet?.left?.width ?? 0.0)
        self.leftLength.text = String(format: "%.0fmm", model?.feet?.left?.length ?? 0.0)
        self.rightWidth.text = String(format: "%.0fmm", model?.feet?.right?.width ?? 0.0)
        self.rightLength.text = String(format: "%.0fmm", model?.feet?.right?.length ?? 0.0)
        
        self.inputGender.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        self.name.returnKeyType = .done
        self.name.delegate = self
        if #available(iOS 13.0, *) {
            self.name.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        }
    }
}

// MARK: - Action
extension FeetResultVC {
    @IBAction func onReset(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onConfirm(_ sender: UIButton) {
        guard let nickname = self.name.text else { return }
        let gender = self.inputGender.selectedSegmentIndex == 0 ? "M" : "F"
        
        let body = FootModel(feetId: model?.id, averageSize: PerfittPartners.instance.averageSize ?? 0, nickname: nickname, gender: gender, customerId: PerfittPartners.instance.customerId)
        
        self.requestFootInfo(body: body)
    }
}

// MARK: - Call API
extension FeetResultVC {
    private func requestFootInfo(body: FootModel) {
        self.showActivityIndicator()
        
        APIController.init().reqeustFootData(body, PerfittPartners.instance.getAPIKey() ?? "", successHandler: { result in
            if let _ = PerfittPartners.instance.customerId {
                PerfittPartners.instance.nativeCallbackName = result ?? ""
            }
            else {
                let callBackResult = "PERFITT_CALLBACK('\(result ?? "")')"
                PerfittPartners.instance.callbackName = callBackResult
            }
            self.hideActivityIndicator()
            self.navigationController?.dismiss(animated: true, completion: nil)
            
        }, failedHandler: { errorResult in
            self.hideActivityIndicator()
            self.showAlert(title: "", message: errorResult.message, vc: self, handler: { _ in
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
}
extension FeetResultVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
