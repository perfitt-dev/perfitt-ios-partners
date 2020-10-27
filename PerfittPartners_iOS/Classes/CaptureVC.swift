//
//  CaptureVC.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/10/27.
//

import UIKit

class CaptureVC: UIViewController {
    @IBOutlet weak var previewImageView: UIImageView!
    
    
    var imageData: Data!
    var previewFor: String?
    var postProcessedImage: String?
    var rightImgData: String?
    var leftImgData: String?
    var base64Data: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.previewImageView.image = UIImage(data: imageData)
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
        
    }
    
    @IBAction func retake(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        if previewFor == "Right" {
            let bundles = Bundle.main.loadNibNamed("PerfittCameraVC", owner: self, options: nil)
            let cameraVC = bundles?.filter({ $0 is PerfittCameraVC }).first as? PerfittCameraVC
            
            cameraVC?.rightImg = false
            cameraVC?.rightImgData = base64Data
            
            self.navigationController?.pushViewController(cameraVC ?? self, animated: true)
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
            
//            indicator.startAnimating()
            let requestData = FootModel(leftImage: left, rightImage: right , sourceType: "\(APIConsts.SDK_VERSION)_\(UIDevice.current.name)_\(self.getOSInfo())")
            
            self.showUserInfoAlert(requestData: requestData)
            
            
        }
    }
    
}
extension CaptureVC {
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    private func getOSInfo() -> String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
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
        APIController.init().reqeustFootData(requestData, "apikey", successHandler: { result in
            DispatchQueue.main.async {
                
                PerfittPartners.instance.delegate?.confirm()
//                self.indicator.stopAnimating()
                
//                Perfitt.instance.delegate?.onConfirm("callback('\(result ?? "")')")
//                let userInfo: [AnyHashable: Any] = ["methodName": "callback('\(result ?? "")')"]
//                NotificationCenter.default.post(name: NSNotification.Name.init("PerfittPartners"), object: nil, userInfo: userInfo)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }, failedHandler: { errorResult in
            debugPrint("!!!!ERROR :")
            DispatchQueue.main.async {
//                self.indicator.stopAnimating()
//                self.showAlert(title: "", message: errorResult.message, handler: nil)
            }

        })
    }
}
