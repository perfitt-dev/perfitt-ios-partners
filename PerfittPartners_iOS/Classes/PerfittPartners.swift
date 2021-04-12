
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
        //        self.registerFont()
        //        self.testFont()
//        self.customFont()
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
    
    // call back at webview javascript function
    public func onConfirm(completion: @escaping((String) -> Void) ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.result = completion
        }
    }
    
    // call back at native view controller
    public func onNativeConfirm(completion: @escaping( (String) -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.nativeResult = completion
        }
    }
}
//
//extension PerfittPartners {
//    private func customFont() {
//        let fontName = "NotoSansCJKkr-R_p"
//        let podBundle = Bundle(for: PerfittPartners.self)
//
//        guard let bundleURL = podBundle.url(forResource: "PerfittPartners_iOS", withExtension: "bundle") else {
//            debugPrint("pod bundle failed")
//            return
//        }
//        guard let bundle = Bundle(url: bundleURL) else {
//            debugPrint("create bundle failed")
//            return
//        }
//
//        if let cfURL = bundle.url(forResource: fontName, withExtension: "ttf") {
//            debugPrint("~~> ttf cfurl : \(cfURL as CFURL)")
//            CTFontManagerRegisterFontsForURL(cfURL as CFURL, .process, nil)
//
//        } else if let cfURL = bundle.url(forResource: fontName, withExtension: "otf") {
//            debugPrint("~~> otf cfurl : \(cfURL as CFURL)")
//            CTFontManagerRegisterFontsForURL(cfURL as CFURL, .process, nil)
////            debugPrint("~~> arr:", CTFontManagerCopyAvailableFontFamilyNames())
//            let fonts = CTFontManagerCopyAvailableFontFamilyNames() as Array
//            for font in fonts {
//                debugPrint("~~> font name : \(font)")
//            }
//
//
//
//        } else {
//            //              assertionFailure
//            debugPrint("~~> Could not find font:\(fontName) in bundle:\(bundle)")
//        }
//    }
//}
//
////extension PerfittPartners {
////    private func testFont() {
////        let podBundle = Bundle(for: PerfittPartners.self)
////        UIFont.jbs_registerFont(withFilenameString: "NotoSansCJKkr-M_p.otf", bundle: podBundle)
////    }
////}
//
////extension PerfittPartners {
////    private func registerFont() {
////        debugPrint("~~> register font")
////        let podBundle = Bundle(for: PerfittPartners.self)
////        guard let bundleURL = podBundle.url(forResource: "PerfittPartners_iOS", withExtension: "bundle") else {
////            debugPrint("pod bundle failed")
////            return
////        }
////        guard let bundle = Bundle(url: bundleURL) else {
////            debugPrint("create bundle failed")
////            return
////        }
////        guard let fontURL = bundle.url(forResource: "NotoSansCJKkr-M_p", withExtension: "otf") else {
////            debugPrint("~~> not load font")
////            return
////        }
////        guard let fontData = try? Data(contentsOf: fontURL) as CFData else {
////            debugPrint("~~> not converting data")
////            return
////        }
////        guard let provider = CGDataProvider(data: fontData) else {
////            debugPrint("~~> not provider")
////            return
////        }
////        guard let font = CGFont(provider) else {
////            debugPrint("~~> font error")
////            return
////        }
////
////        guard CTFontManagerRegisterGraphicsFont(font, nil) else {
////            debugPrint("~~> register font failed")
////            return
////        }
////
////    }
////}
