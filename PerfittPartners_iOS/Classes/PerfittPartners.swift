
import Foundation
open class PerfittPartners {
    public static var instance = PerfittPartners()
    public var delegate: PerfittPartnersDelegate?
    
    private var apiKey: String?
    
    
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
    
    // A4 용지
    public func getA4Camera() -> UINavigationController {
        let bundles = Bundle.main.loadNibNamed("PerfittCameraVC", owner: nil, options: nil)
        let cameraVC = bundles?.filter({ $0 is PerfittCameraVC }).first as? PerfittCameraVC
        cameraVC?.rightImg = true
        let navigationController = UINavigationController(rootViewController: cameraVC!)
        navigationController.navigationItem.backBarButtonItem?.title = ""
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
    
    // Kit
    public func getKitCamera() -> UINavigationController {
        let bundles = Bundle.main.loadNibNamed("PerfittKitCameraVC", owner: nil, options: nil)
        let cameraVC = bundles?.filter( { $0 is PerfittKitCameraVC }).first as? PerfittKitCameraVC
        cameraVC?.rightImg = true
        let navigationController = UINavigationController(rootViewController: cameraVC!)
        navigationController.navigationItem.backBarButtonItem?.title = ""
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
    
    public func onConfirm(_ delegate: PerfittPartnersDelegate?) {
        self.delegate = delegate
    }

    public func initializeApiKey(APIKey: String) {
        // TODO: - APIKey 인증 방식 설정
        /**
         * APIController.ini().authAPIKey() {
         *      successHandler( nil),
         *      failedHandler( { _ in
         *        failedError("failed auth api key ") } )
         * }
         */
        
        // 인증에 성공하면 apikey를 저장합니다!
        self.apiKey = APIKey
    }
    
    public func getAPIKey() -> String? {
        return self.apiKey
    }
    
}

public protocol PerfittPartnersDelegate {
    func confirm(returnStr: String)
    var methodName: String { get set }
}
