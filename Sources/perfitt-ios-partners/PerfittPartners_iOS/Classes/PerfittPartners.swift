
import WebKit

enum CameraStatus {
    case Kit, A4
}

open class PerfittPartners {
    
    public static var instance = PerfittPartners()
    
    private var apiKey: String?
    private var customerId: String?
    private var averageSize: Int?
    private var ownerViewController: UIViewController?
    
    private var status: CameraStatus! = .Kit
    
    public var contentKit: String {
        get {
            return "PERFITT_SDK_KIT"
        }
    }
    
    public var contentA4: String {
        get {
            return "PERFITT_SDK_A4"
        }
    }
    
    
    public var result: ((String) -> Void)?
    public var callbackName: String? {
        didSet {
            self.result!(callbackName ?? "")
        }
    }
    
    public var nativeResult: ((String) -> Void)?
    public var nativeCallbackName: String? {
        didSet {
            self.nativeResult!(nativeCallbackName ?? "")
        }
    }
    
    public func setAverageSize(to size: Int) {
        self.averageSize = size
    }
    
    public func getAverageSize() -> Int {
        return self.averageSize ?? 0
    }
 
    // A4 용지
    private func getA4Camera() {
        let bundles = Bundle.main.loadNibNamed("PerfittCameraVC", owner: nil, options: nil)
        let cameraVC = bundles?.filter({ $0 is PerfittCameraVC }).first as? PerfittCameraVC
        cameraVC?.rightImg = true
        let navigationController = UINavigationController(rootViewController: cameraVC!)
        navigationController.navigationItem.backBarButtonItem?.title = ""
        navigationController.modalPresentationStyle = .fullScreen
        
        let time = DispatchTime.now() + .milliseconds(300)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.ownerViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    // Kit
    private func getKitCamera()  {
        let bundles = Bundle.main.loadNibNamed("PerfittKitCameraVC", owner: nil, options: nil)
        let cameraVC = bundles?.filter( { $0 is PerfittKitCameraVC }).first as? PerfittKitCameraVC
        cameraVC!.rightImg = true
        let navigationController = UINavigationController(rootViewController: cameraVC!)
        navigationController.navigationItem.backBarButtonItem?.title = ""
        navigationController.modalPresentationStyle = .fullScreen
        
        let time = DispatchTime.now() + .milliseconds(300)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.ownerViewController!.present(navigationController, animated: true, completion: nil)
        }
    }
    
    private func getKitTutorial() {
        let bundles = Bundle.main.loadNibNamed("PerfittKitTutorialVC", owner: nil, options: nil)
        let tutorialVC = bundles?.filter({ $0 is PerfittKitTutorialVC }).first as? PerfittKitTutorialVC
        
        let navigationController = UINavigationController(rootViewController: tutorialVC!)
        navigationController.navigationItem.backBarButtonItem?.title = ""
        navigationController.modalPresentationStyle = .fullScreen
        
        let time = DispatchTime.now() + .milliseconds(300)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.ownerViewController!.present(navigationController, animated: true, completion: nil)
        }
    }
    
    //
    private func getAverageSizeAlert() -> UIViewController {
        let bundles = Bundle.main.loadNibNamed("SizePicker", owner: nil, options: nil)
        guard let averagePopup = bundles?.filter( { $0 is SizePicker }).first as? SizePicker else {
            return UIViewController()
        }
        averagePopup.delegate = AverageSizeController()
        return averagePopup
    }
    
    public func showAverageSizeAlert() {
        let alert = self.getAverageSizeAlert()
        alert.modalPresentationStyle = .overCurrentContext
        self.ownerViewController?.present(alert, animated: true, completion: nil)
    }
    
    public func onConfirm(completion: @escaping((String) -> Void) ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.result = completion
        }
    }
    
    public func onNativeConfirm(completion: @escaping( (String) -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.nativeResult = completion
        }
    }
    
    public func runSDK(_ customerId: String) {
        self.setCustomId(to: customerId)
        PerfittPartners.instance.showAverageSizeAlert()
        PerfittPartners.instance.status = .Kit
    }
    
    public func initializeApiKey(APIKey: String, vc: UIViewController) {
        // TODO: - APIKey 인증 방식 설정
        
        // 인증에 성공하면 apikey를 저장합니다!
        self.apiKey = APIKey
        
        self.ownerViewController = vc
    }
    
    public func getAPIKey() -> String? {
        return self.apiKey
    }
    
    public func setCustomId(to customId: String) {
        self.customerId = customId
    }
    
    public func getCustomerId() -> String? {
        return self.customerId
    }
    
    public class BridgeJavaScript: NSObject, WKScriptMessageHandler {
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            debugPrint("test message: \(message.name)")
            // PERFITT_SDK ( KIT )
            if (message.name == PerfittPartners.instance.contentKit) {
                
                PerfittPartners.instance.showAverageSizeAlert()
                PerfittPartners.instance.status = .Kit
            }
            // PERFITT_SDK ( A4 )
            else if (message.name == PerfittPartners.instance.contentA4) {
                PerfittPartners.instance.showAverageSizeAlert()
                PerfittPartners.instance.status = .A4
            }
        }
    }
    
    public class AverageSizeController: NSObject, SizePickerDelegate {
        func onConfirm() {
            // move to camera
            switch PerfittPartners.instance.status {
            case .A4:
                PerfittPartners.instance.getA4Camera()
            case .Kit:
                
                if UserDefaults.standard.bool(forKey: "perfittKitStart") {
                    PerfittPartners.instance.getKitCamera()
                }
                else {
                    PerfittPartners.instance.getKitTutorial()
                }
                
            case .none:
                debugPrint("error!!!!!")
            }
        }
    }
}




