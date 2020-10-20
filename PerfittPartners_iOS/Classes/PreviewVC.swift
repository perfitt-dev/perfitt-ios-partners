//
//  PreviewVC.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/18.
//

import UIKit

open class PreviewVC: UIViewController {
    
    public var imageData: Data!
    var previewImageView: UIImageView!
    var previewFor: String!
    var postProcessedImage: String?
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

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
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
            
            self.showUserInfoAlert(requestData: requestData)

            
        }
    }
    
    private func showUserInfoAlert(requestData: FootModel) {
        let userInfoAlert = UIAlertController(title: "내 발 정보 편집하기", message: nil, preferredStyle: .alert)
        let contentVC = UIViewController()
        contentVC.view.backgroundColor = .systemTeal
//        let nickName = UILabel()
//        nickName.text = "별칭"
//        nickName.font = .boldSystemFont(ofSize: 12)
//        nickName.translatesAutoresizingMaskIntoConstraints = false
        
//        contentVC.view.addSubview(nickName)
//        NSLayoutConstraint.activate([
//            nickName.topAnchor.constraint(equalTo: contentVC.view.topAnchor, constant: 4),
//            nickName.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor, constant: 4),
//            nickName.bottomAnchor.constraint(equalTo: contentVC.view.bottomAnchor, constant: 4)
//        ])
//        let v = UIViewController()
//        v.view.backgroundColor = UIColor.gray
//        v.view.bounds.size = CGSize(width: 1000, height: 900)
        
        //알림창에 뷰 컨트롤러를 등록
        userInfoAlert.setValue(contentVC, forKey: "contentViewController")
        //알림창 화면에 표시
        let requestAPIBtn = UIAlertAction(title: "확인", style: .default, handler: {_ in
            debugPrint("test")
        })
        
        userInfoAlert.addAction(requestAPIBtn)
        self.present(userInfoAlert, animated: false)
        
        // MARK : - Alert 확인 버튼을 눌렀을경우 API CALL을 진행 시킨다.
//        APIController.init().reqeustFootData(requestData, self.APIKEY ?? "", successHandler: { result in
//            DispatchQueue.main.async {
//                self.indicator.stopAnimating()
//                let userInfo: [AnyHashable: Any] = ["methodName": "callback('\(result ?? "")')"]
//                NotificationCenter.default.post(name: NSNotification.Name.init("PerfittPartners"), object: nil, userInfo: userInfo)
//                self.navigationController?.popToRootViewController(animated: true)
//            }
//        }, failedHandler: { errorResult in
//            debugPrint("!!!!ERROR :")
//            DispatchQueue.main.async {
//                self.indicator.stopAnimating()
//                self.showAlert(title: "", message: errorResult.message, handler: nil)
//            }
//
//        })
    }
    
    private func showAlert(title: String, message: String, handler: ((UIAlertAction) -> ())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        controller.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
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
