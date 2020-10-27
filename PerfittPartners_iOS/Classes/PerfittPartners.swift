
import Foundation
open class PerfittPartners {
    public static var instance = PerfittPartners()
    public var delegate: PerfittPartnersDelegate?
    
    private var apiKey: String?
    public var contentName: String {
        get {
            return "PERFITT_SDK"
        }
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
