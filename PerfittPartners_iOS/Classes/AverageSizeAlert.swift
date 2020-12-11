//
//  AverageSizeAlert.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/12/11.
//

import UIKit

class AverageSizeAlert: UIViewController {
    @IBOutlet weak var averageSize: UITextField!
    @IBOutlet weak var containerView: UIView!
    var pickerView: UIPickerView!
    
    var delegate: AverageSizeDelegate?
    var gender: String?
    var sizeRun: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView.layer.cornerRadius = 8
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

    @IBAction func onConfirm( _ sender: UIButton ) {
        guard let size = self.averageSize.text else { return }
        guard let sizeInt = Int(size) else { return }
        
        PerfittPartners.instance.setAverageSize(to: sizeInt)
        self.delegate?.confirm()
        self.dismiss(animated: true, completion: nil)
        
    }

}

extension AverageSizeAlert: UIPickerViewDelegate, UIPickerViewDataSource {
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

protocol AverageSizeDelegate {
    func confirm()
}
