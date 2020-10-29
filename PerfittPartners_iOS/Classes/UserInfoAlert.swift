//
//  UserInfoAlert.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/10/28.
//

import UIKit

class UserInfoAlert: UIViewController {
    
    @IBOutlet weak var userNickName: UITextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var averageSize: UITextField!
    
    var pickerView: UIPickerView!
    
    var delegate: UserInfoAlertDelegate?
    var gender: String?
    var sizeRun: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userNickName.delegate = self
        self.createSizeRun()
        self.createPickerView()
        self.dismissPickerView()
        self.setDefaultPicker()
    }
    
    private func createSizeRun() {
        for i in 0...30 {
            self.sizeRun.append(String(200 + (i * 5)))
        }

    }
    
    private func setDefaultPicker() {
        if let indexPosition = self.sizeRun.firstIndex(of: "245"){
           pickerView.selectRow(indexPosition, inComponent: 0, animated: true)
         }
    }
    
    private func createPickerView() {
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        averageSize.inputView = pickerView
    }
    
    private func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let applyBtn = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.applySize))
        applyBtn.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.systemRed], for: .normal)
        toolBar.setItems([applyBtn], animated: true)
        toolBar.isUserInteractionEnabled = true
        self.averageSize.inputAccessoryView = toolBar
        self.averageSize.inputAccessoryView?.tintColor = .black
    }
    
    @objc private func applySize() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        self.averageSize.text = self.sizeRun[row]
        self.averageSize.resignFirstResponder()
    }
    
    @IBAction func onGenderSelect(_ sender: UIButton) {
        switch sender {
        case maleButton:
            maleButton.isSelected = true
            femaleButton.isSelected = false
            self.gender = "M"
        case femaleButton:
            maleButton.isSelected = false
            femaleButton.isSelected = true
            self.gender = "F"
        default:
            return
        }
    }
    
    @IBAction func onCancel( _ sender: UIButton ) {
//        debugPrint("select on cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onConfirm( _ sender: UIButton ) {
        debugPrint("api request size: ", self.averageSize.text)
        guard let size = self.averageSize.text else {
            // TODO : alert
            debugPrint("api request size empty")
            return
        }
        debugPrint("api request size not empty")
        guard let sizeInt = Int(size) else {
            debugPrint("api request size casting failed")
            return
        }
        self.dismiss(animated: true, completion: { [self] in
            delegate?.confirm(nickName: self.userNickName.text, gender: self.gender, averageSize: sizeInt)
        })
        
    }

}
extension UserInfoAlert: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sizeRun.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sizeRun[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.averageSize.text = self.sizeRun[row]
    }
    
}

extension UserInfoAlert: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}


protocol UserInfoAlertDelegate {
    func confirm(nickName: String?, gender: String?, averageSize: Int)
}
