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
    
    var rightRect: CGRect?
    var leftRect: CGRect?
    
    var rightTriangle: CGRect?
    var leftTriangle: CGRect?
    
    var camMode: CamMode?
    
    var captureData: FeetBody?
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.color = .red
        indicator.backgroundColor = .white
        
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.28)
                
        self.setNavi()
    }
    
    private func setNavi() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
    }
    
    @objc private func done() {
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.previewImageView.image = UIImage(data: imageData)
        
        // 사이즈 조정
        guard let jpeg = resizeImage(image: UIImage.init(data: imageData)!, targetSize: CGSize.init(width: 720, height: 1280)).jpegData(compressionQuality: 1.0) else {
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
                
                cameraVC?.reciveCaptureData = self.captureData
                
                self.navigationController?.pushViewController(cameraVC ?? self, animated: true)
            case .none: return
            }
            
            
        }
        else {
            self.fetchFeetData()
        }
    }
    
}
extension CaptureVC {
    private func fetchFeetData() {
        guard let right = self.rightImgData else { return }
        guard let left = self.base64Data else { return }
        
        let sourceType = "\(APIConsts.SDK_VERSION)_\(UIDevice.current.name)_\(self.getOSInfo())"
        
        self.captureData?.averageSize = PerfittPartners.init().getAverageSize()
        self.captureData?.sourceType = sourceType
        self.captureData?.left?.image = left
        self.captureData?.right?.image = right
        
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.activityIndicator)

        NSLayoutConstraint.activate([
            self.activityIndicator.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.activityIndicator.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            self.activityIndicator.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.activityIndicator.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        self.activityIndicator.startAnimating()

        APIController.init().reqeustFeetData(self.captureData, PerfittPartners.instance.getAPIKey() ?? "", camMode: self.camMode!.rawValue, successHandler: { response in

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                let bundle = Bundle.main.loadNibNamed("FeetResultVC", owner: self, options: nil)
                let feetRsultVC = bundle?.filter({ $0 is FeetResultVC }).first as? FeetResultVC
                feetRsultVC?.model = response
                self.navigationController?.pushViewController(feetRsultVC!, animated: true)
            }

        }, failedHandler: { requestError in

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()

                self.showAlert(title: "", message: requestError.message, handler: nil)
            }

        })
    }
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

extension CaptureVC {
//    func confirm(nickName: String?, gender: String?, averageSize: Int) {
//        debugPrint("api request click ")
//        guard let right = self.rightImgData else {
//            debugPrint("right data empty")
//            return
//        }
//
//        guard let left = self.base64Data else {
//            debugPrint("left data empty")
//            return
//        }
//
//
//
//
//
//
//    }
    
    private func showAlert(title: String, message: String, handler: ((UIAlertAction) -> ())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        controller.addAction(okAction)
        
        self.present(controller, animated: true, completion: nil)
//        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
}
