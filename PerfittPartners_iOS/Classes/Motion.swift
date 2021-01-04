//
//  Motion.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/17.
//

import UIKit
import CoreMotion

open class Motion: UIView {
    weak var delegate: MotionDelegate?
    private var button: UIButton?
    private let motionManager = CMMotionManager()
    private var pitch: Double = 0
    private var roll: Double = 0
    private var isMotionStatusReady: Bool = false
    let largeCircleRadius: CGFloat = 72 // 이게 움직이는 것
    let smallCircleRadius: CGFloat = 64 // 이건 자리에 그대로 있는 것

//    let bgImageView = UIImageView(image: UIImage(named: "ovalCopy2"))
    let bgImageView = UIView()
    let movingImageView = UIView()

    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setMotionLayout()
        initMotionManager()
        configureButtonView()
        drawView()
        
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)!
        self.backgroundColor = .white
        setMotionLayout()
        initMotionManager()
        configureButtonView()
        drawView()
        
    }
    
    private func drawView() {
        self.bgImageView.layer.cornerRadius = self.smallCircleRadius / 2
        
        self.bgImageView.layer.masksToBounds = true
        self.bgImageView.backgroundColor = .white
        
        self.bgImageView.layer.borderColor = UIColor.gray.cgColor
        self.bgImageView.layer.borderWidth = 3
        
        self.movingImageView.layer.cornerRadius = self.largeCircleRadius / 2
        
        self.movingImageView.layer.masksToBounds = true
        self.movingImageView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        self.movingImageView.layer.borderColor = UIColor.darkGray.cgColor
        self.movingImageView.layer.borderWidth = 3
        
        
        let captureTap = UITapGestureRecognizer(target: self, action: #selector(capture(_:)))
        self.bgImageView.addGestureRecognizer(captureTap)
    }
    
    @objc private func capture(_ sender: UITapGestureRecognizer) {
        
        if self.isMotionStatusReady {
            delegate?.tapButton()
        }
    }
    
    private func setMotionLayout() {
        self.bgImageView.translatesAutoresizingMaskIntoConstraints = false
        self.movingImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bgImageView)
        self.addSubview(movingImageView)
        
        NSLayoutConstraint.activate([
            bgImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            bgImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            bgImageView.widthAnchor.constraint(equalToConstant: self.smallCircleRadius),
            bgImageView.heightAnchor.constraint(equalToConstant: self.smallCircleRadius),
            
            movingImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            movingImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            movingImageView.widthAnchor.constraint(equalToConstant: self.largeCircleRadius),
            movingImageView.heightAnchor.constraint(equalToConstant: self.largeCircleRadius)
            
        ])
        
        
    }

    //MARK: Private Methods
    private func initMotionManager() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.05;
            let queue = OperationQueue()
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: { (motion, error) -> Void in
                if let attitude = motion?.attitude {
                    self.pitch = attitude.pitch * 180.0 / Double.pi
                    self.roll = attitude.roll * 180.0 / Double.pi
                    
                    DispatchQueue.main.async {
                        if abs(self.roll) > 5 || abs(self.pitch) > 5 {
                            self.isMotionStatusReady = false
                            self.bgImageView.layer.borderColor = UIColor.gray.cgColor
                            self.bringSubviewToFront(self.movingImageView)
                            self.delegate?.setCurrentStatus(status: false)
                        } else {
                            self.isMotionStatusReady = true
                            self.bgImageView.layer.borderColor = UIColor.init(red: 237 / 255, green: 0, blue: 30 / 255, alpha: 1).cgColor
                            self.bringSubviewToFront(self.bgImageView)
                            self.delegate?.setCurrentStatus(status: true)
                        }

                        let posX = CGFloat((self.roll >= 0 ? min(self.roll, 10) : max(self.roll, -10)) * -1)
                        let posY = CGFloat((self.pitch >= 0 ? min(self.pitch, 10) : max(self.pitch, -10)))

                        
                        self.movingImageView.transform = CGAffineTransform(translationX: posX, y: posY)

                        self.setNeedsDisplay()
                    }
                }
            })
        }
    }
    
    private func mapValue(value: Double, adder: CGFloat) -> CGFloat {
        return CGFloat(value / 90 * 80) + adder
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }

    @objc private func tapButton() {
        if self.isMotionStatusReady {
            delegate?.tapButton()
        }
    }

    private func configureButtonView() {
        button = UIButton(type: .system)
        if let btn = button {
            btn.layer.cornerRadius = CGFloat(largeCircleRadius)
            btn.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
            self.addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false

            btn.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            btn.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            btn.widthAnchor.constraint(equalToConstant: CGFloat(largeCircleRadius * 2)).isActive = true
            btn.heightAnchor.constraint(equalToConstant: CGFloat(largeCircleRadius * 2)).isActive = true
        }

    }
}

public protocol MotionDelegate: class {
    func tapButton()
    func setCurrentStatus(status: Bool);
}

