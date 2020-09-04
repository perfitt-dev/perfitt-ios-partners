//
//  PerfittPartners.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/04.
//


import UIKit

open class PerfittPartners: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setView(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setView(frame: CGRect) {
        self.frame = frame
        self.backgroundColor = .brown
    }
}
