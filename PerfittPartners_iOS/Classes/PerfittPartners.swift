
enum CameraStatus {
    case Kit, A4
}

open class PerfittPartners {
    
    // create singleton
    public static var instance = PerfittPartners()
    
    var apiKey: String?
    var customerId: String?
    var averageSize: Int?
    var ownerViewController: UIViewController?
    
    // camera mode
    var status: CameraStatus = .Kit
    
    // define interface name
    public let contentKit: String = "PERFITT_SDK_KIT"
    public let contentA4: String = "PERFITT_SDK_A4"
    
    // define webview interface
    public let bridgeJavaScript: PerfittBridgeJavaScript = PerfittBridgeJavaScript()
    
    // call web view
    var result: ((String) -> Void)?
    public var callbackName: String? {
        didSet {
            self.result!(callbackName ?? "")
        }
    }
    
    // call native
    var nativeResult: ((String) -> Void)?
    public var nativeCallbackName: String? {
        didSet {
            self.nativeResult!(nativeCallbackName ?? "")
        }
    }
}

extension PerfittPartners {
    // define sdk
    public func initializeApiKey(APIKey: String, vc: UIViewController) {
        // 인증에 성공하면 apikey를 저장합니다!
        self.apiKey = APIKey
        self.ownerViewController = vc
    }
    
    // start native sdk
    public func runSDK(_ customerId: String) {
        self.customerId = customerId
        PerfittPartners.instance.status = .Kit
        
        // show average size popup
        let sizePicker = SizePicker.initViewController(viewControllerClass: SizePicker.self)
        sizePicker.delegate = SizePickerController()
        sizePicker.modalPresentationStyle = .overCurrentContext
        self.ownerViewController?.present(sizePicker, animated: true, completion: nil)
    }
    
    // get using api key
    public func getAPIKey() -> String? {
        return self.apiKey
    }
    
    // call back func
    public func onConfirm(completion: @escaping((String) -> Void) ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.result = completion
        }
    }
    
    // call back func
    public func onNativeConfirm(completion: @escaping( (String) -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.nativeResult = completion
        }
    }
}
