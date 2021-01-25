//
//  SizePicker.swift
//  Pods
//
//  Created by nick on 2020/12/29.
//

import UIKit

class SizePicker: UIViewController {
    @IBOutlet weak var pickerView: CustomPickerView!
    @IBOutlet weak var confirmButton: UIButton!
    
    let minSize = 200
    let maxSize = 350
    
    var delegate: SizePickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 14.0, *) {
            let transparent = UIColor(red: 255.0 , green: 255.0, blue: 255.0, alpha: 0.0)
//            pickerView.subviews[1].backgroundColor = transparent
            self.pickerView.subviews.last?.backgroundColor = transparent
        }
        self.pickerView.delegate = self
        self.pickerView.selectRow(9, inComponent: 0, animated: false)
        
        self.confirmButton.layer.cornerRadius = 24
        
        self.setupUI()
    }
    
    private func setupUI() {
        let outsideTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onOutSideTap))
        self.view.addGestureRecognizer(outsideTapGesture)
        
    }
    
    @objc private func onOutSideTap() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onConfirm(_ sender: UIButton) {
        let row = pickerView.selectedRow(inComponent: 0)
        
        PerfittPartners.instance.setAverageSize(to: Int(minSize + row * 5))
        self.delegate?.onConfirm()
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SizePicker: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (maxSize - minSize) / 5 + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (String)(minSize + row * 5)
    }

    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(63)
    }
}

protocol SizePickerDelegate {
    func onConfirm()
}
