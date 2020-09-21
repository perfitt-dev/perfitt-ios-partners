//
//  PreviewVC.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/18.
//

import UIKit

class PreviewVC: UIViewController {
    
    public var imageData: Data!
    var previewImageView: UIImageView!
    var previewFor: String!
    var postProcessedImage: String?
//    var loadingLayer: CircleDotLoadingLayer?
    var rightImgData: String?
    var leftImgData: String?
    var base64Data: String!
    
    var APIKEY: String?
    
    lazy var indicator: UIActivityIndicatorView = {
        let value = UIActivityIndicatorView()
        value.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        value.center = self.view.center
        value.tintColor = .red
        value.hidesWhenStopped = true
        
        value.stopAnimating()
        return value
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        previewImageView = UIImageView(image: UIImage(data: imageData))
        // 사이즈 조정
        guard let jpeg = resizeImage(image: UIImage.init(data: imageData)!.rotate(radians: (.pi / 2)), targetSize: CGSize.init(width: 1280, height: 720)).jpegData(compressionQuality: 1.0) else {
            return
        }
        
        base64Data = jpeg.base64EncodedString()
        
        if (previewFor == "Right") {
            self.title = "오른발 촬영결과"
        } else {
            self.title = "왼발 촬영결과"
        }
        
        self.setup()
        
    }
    
    private func setup() {
        self.view.backgroundColor = .black
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        
        let retakeBtn = UIButton()
        let confirmBtn = UIButton()
        
        retakeBtn.setTitle("재촬영", for: .normal)
        retakeBtn.setTitleColor(UIColor.lightGray, for: .normal)
        retakeBtn.addTarget(self, action: #selector(retake(_:)), for: .touchUpInside)
        retakeBtn.titleLabel?.textAlignment = .center
        
        confirmBtn.setTitle("확인", for: .normal)
        confirmBtn.setTitleColor(UIColor.red, for: .normal)
        confirmBtn.addTarget(self, action: #selector(confirm(_:)), for: .touchUpInside)
        confirmBtn.titleLabel?.textAlignment = .center
        
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        retakeBtn.translatesAutoresizingMaskIntoConstraints = false
        confirmBtn.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(previewImageView)
        self.view.addSubview(bottomView)
        self.view.addSubview(indicator)
        bottomView.addSubview(retakeBtn)
        bottomView.addSubview(confirmBtn)
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            previewImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            previewImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            previewImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            previewImageView.heightAnchor.constraint(equalTo: self.previewImageView.widthAnchor, multiplier: 16.0 / 9.0),
            
            bottomView.topAnchor.constraint(equalTo: self.previewImageView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 96),
            
            retakeBtn.topAnchor.constraint(equalTo: bottomView.topAnchor),
            retakeBtn.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            retakeBtn.trailingAnchor.constraint(equalTo: bottomView.centerXAnchor),
            retakeBtn.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
            
            confirmBtn.topAnchor.constraint(equalTo: bottomView.topAnchor),
            confirmBtn.leadingAnchor.constraint(equalTo: bottomView.centerXAnchor),
            confirmBtn.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            confirmBtn.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor)
        ])
    }
    
    @objc func retake(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func confirm(_ sender: UIButton) {
        debugPrint("source type : \(APIConsts.SDK_VERSION)_\(UIDevice.current.name)_\(self.getOSInfo())" )
        if previewFor == "Right" {
            let cameraVC = PerfittPartners(APIKey: self.APIKEY ?? "")
            cameraVC.rightImg = false
            cameraVC.rightImgData = base64Data
            self.navigationController?.pushViewController(cameraVC, animated: true)
        }
        else {
            
            guard let right = self.rightImgData else {
                debugPrint("right data empty")
                return
            }
            
            guard let left = self.base64Data else {
                debugPrint("left data empty")
                return
            }
            
            indicator.startAnimating()
            let requestData = FootModel(leftImage: left, rightImage: right , sourceType: "\(APIConsts.SDK_VERSION)_\(UIDevice.current.name)_\(self.getOSInfo())")
            
            APIController.init().reqeustFootData(requestData, self.APIKEY ?? "", successHandler: {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    let userInfo: [AnyHashable: Any] = ["methodName": "callback('\(self.APIKEY ?? "")')"]
                    NotificationCenter.default.post(name: NSNotification.Name.init("PerfittPartners"), object: nil, userInfo: userInfo)
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }, failedHandler: {
                debugPrint("!!!!ERROR :")
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    BaseController.showAlert(title: "api error", message: "api failed", handler: nil)
                }

            })
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func getOSInfo()->String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
}
