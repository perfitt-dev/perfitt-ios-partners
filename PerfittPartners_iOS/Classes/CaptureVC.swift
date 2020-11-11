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
    
    var camMode: CamMode?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.28)    }
    
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
            switch camMode {
            case .A4:
                let bundles = Bundle.main.loadNibNamed("PerfittCameraVC", owner: self, options: nil)
                let cameraVC = bundles?.filter({ $0 is PerfittCameraVC }).first as? PerfittCameraVC
                
                cameraVC?.rightImg = false
                cameraVC?.rightImgData = base64Data
                
                self.navigationController?.pushViewController(cameraVC ?? self, animated: true)
                
            case .KIT:
                let bundles = Bundle.main.loadNibNamed("PerfittKitCameraVC", owner: nil, options: nil)
                let cameraVC = bundles?.filter( { $0 is PerfittKitCameraVC }).first as? PerfittKitCameraVC
                
                cameraVC?.rightImg = false
                cameraVC?.rightImgData = base64Data
                
                self.navigationController?.pushViewController(cameraVC ?? self, animated: true)
            case .none: return
            }
            
            
        }
        else {
            let bundle = Bundle.main.loadNibNamed("UserInfoAlert", owner: self, options: nil)
            let userInfoAlert = bundle?.filter({ $0 is UserInfoAlert }).first as? UserInfoAlert
            userInfoAlert?.delegate = self
            userInfoAlert?.modalPresentationStyle = .fullScreen
            userInfoAlert?.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
            
            self.present(userInfoAlert!, animated: true, completion: nil)
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
}

extension CaptureVC: UserInfoAlertDelegate {
    func confirm(nickName: String?, gender: String?, averageSize: Int) {
        debugPrint("api request click ")
        guard let right = self.rightImgData else {
            debugPrint("right data empty")
            return
        }
        
        guard let left = self.base64Data else {
            debugPrint("left data empty")
            return
        }
        
        let requestData = FootModel(leftImage: left, rightImage: right , sourceType: "\(APIConsts.SDK_VERSION)_\(UIDevice.current.name)_\(self.getOSInfo())", averageSize: averageSize, nickName: nickName, gender: gender)
        
        APIController.init().reqeustFootData(requestData, "PARTNERS_TEST_KEY", camMode: self.camMode!.rawValue, successHandler: { result in
            debugPrint("api request success")
            let userInfo: [AnyHashable: Any] = ["methodName": "PERFITT_CALLBACK('\(result ?? "")')"]
            NotificationCenter.default.post(name: NSNotification.Name.init("PerfittPartners"), object: nil, userInfo: userInfo)
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }, failedHandler: { errorResult in
            debugPrint("api request failed", errorResult.message)
            
            DispatchQueue.main.async {
                self.showAlert(title: "", message: errorResult.message, handler: nil)
            }
        })
        
        
    }
    
    private func showAlert(title: String, message: String, handler: ((UIAlertAction) -> ())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        controller.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
}
