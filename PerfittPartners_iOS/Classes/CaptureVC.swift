//
//  CaptureVC.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/10/27.
//

import UIKit

class CaptureVC: PerfittViewController {
    @IBOutlet weak var previewImageView: UIImageView!
    var imageData: Data!
    var previewFor: String?
    var postProcessedImage: String?
    var rightImgData: String?
    var leftImgData: String?
    var base64Data: String!
    
    var rightRect: CGRect?
    var leftRect: CGRect?
    
    var rightTriangle: CGRect?
    var leftTriangle: CGRect?
    
    var camMode: CamMode?
    
    var captureData: FeetBody?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNaviRightItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.previewImageView.image = UIImage(data: imageData)
        
        // 사이즈 조정
        guard let jpeg = resizeImage(image: UIImage.init(data: imageData)!, targetSize: CGSize.init(width: 720, height: 1280)).jpegData(compressionQuality: 1.0) else {
            return
        }
        
        base64Data = jpeg.base64EncodedString()
        
        if previewFor == "Right" {
            self.title = "오른발 촬영결과"
        } else {
            self.title = "왼발 촬영결과"
        }
        
    }
}

// MARK: - Action
extension CaptureVC {
    
    @IBAction func retake(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        if previewFor == "Right" {
            switch camMode {
            case .A4:
                self.moveToA4Cam()
            case .KIT:
                self.moveToKitCam()
            case .none: return
            }
        }
        else {
            self.fetchFeetData()
        }
    }
}

// MARK: - Call API
extension CaptureVC {
    
    private func fetchFeetData() {
        guard let right = self.rightImgData else { return }
        guard let left = self.base64Data else { return }
        
        let sourceType = "\(APIConsts.SDK_VERSION)_\(UIDevice.current.name)_\(self.getOSInfo())"
        
        self.captureData?.averageSize = PerfittPartners.instance.averageSize ?? 0
        self.captureData?.sourceType = sourceType
        self.captureData?.left?.image = left
        self.captureData?.right?.image = right
        
        
        self.showActivityIndicator()
        APIController.init().reqeustFeetData(self.captureData, PerfittPartners.instance.getAPIKey() ?? "", camMode: self.camMode!.rawValue, successHandler: { response in
            self.hideActivityIndicator()
            self.moveToFeetResult(model: response)

        }, failedHandler: { requestError in
            self.hideActivityIndicator()
            
            self.showAlert(title: "", message: requestError.message, vc: self, handler: nil)
        })
    }
}

// MARK: Flow
extension CaptureVC {
    private func moveToFeetResult(model: FeetModel?) {
        let feetResultVC = FeetResultVC.initViewController(viewControllerClass: FeetResultVC.self)
        feetResultVC.model = model
        self.navigationController?.pushViewController(feetResultVC, animated: true)
    }
    
    private func moveToKitCam() {
        let cameraVC = PerfittKitCameraVC.initViewController(viewControllerClass: PerfittKitCameraVC.self)
        cameraVC.rightImg = false
        cameraVC.rightImgData = self.base64Data
        cameraVC.reciveCaptureData = self.captureData
        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    private func moveToA4Cam() {
        let cameraVC = PerfittCameraVC.initViewController(viewControllerClass: PerfittCameraVC.self)
        cameraVC.rightImg = false
        cameraVC.rightImgData = base64Data
        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
}

// MARK: - ETC
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
