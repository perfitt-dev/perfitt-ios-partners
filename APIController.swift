//
//  APIController.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/08.
//

import Foundation

open class APIController {
    // RESTFul API Type이 Get일 경우
    private func apiTypeTypeGet(url: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let encodingURL = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        guard let requestURL = URL(string: encodingURL) else { return }
        var request: URLRequest = URLRequest(url: requestURL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session: URLSession = URLSession(configuration: .default)
        
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    // RESTFul API Type이 Post일 경우
    private func apiTypePost(url: String, params: [String: Any], completionHander: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let encodingURL = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        guard let requestURL = URL(string: encodingURL) else { return }
        var request: URLRequest = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        }
        catch {
            debugPrint("params error")
        }
        
        let session: URLSession = URLSession(configuration: .default)
        session.dataTask(with: request, completionHandler: completionHander).resume()
    }
    
    // 발정보 전송
    public func reqeustFootData(_ footData: FootModel, _ APIKEY: String, successHandler: @escaping () -> Void, failedHandler: @escaping() -> Void) {
        do {
            let jsonData = try  JSONEncoder().encode(footData)
            let params = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            
            self.apiTypePost(url: APIConsts.FOOTDATA + "?apiKey=\(APIKEY)", params: params ?? [:], completionHander: { (data, response, error) in
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    failedHandler()
                    return
                }
                guard (200..<300).contains(statusCode) else {
                    print("~~> status code : \(statusCode)")
                    guard let responseData = data else { return }
                    if let str = String(data: responseData, encoding: .utf8) {
                        debugPrint("~~>pos failed body", str)
                        successHandler()
                    }
                    failedHandler()
                    return
                }

                if let _ = error {
                    failedHandler()
                    return
                }

                guard let responseData = data else { return }
                if let str = String(data: responseData, encoding: .utf8) {
                    debugPrint("~~>post success", str)
                    successHandler()
                }
            })
        } catch {
            failedHandler()
        }
        
    }
    
}
