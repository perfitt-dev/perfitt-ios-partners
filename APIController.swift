//
//  APIController.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/08.
//

import Foundation

class APIController {
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
    
    func reqeustFootData(_ footData: FootModel, _ APIKEY: String, successHandler: @escaping () -> Void, failedHandler: @escaping() -> Void) {
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
    
    
//    func requestFootData(_ footData: )
    
//    func getHancerNewsExampleJson(successHandler: @escaping (Response) -> Void, failedHandler: @escaping(Error) -> Void) {
//        self.methodGet(url: "https://hn.algolia.com/api/v1/search?tags=story&page=1", completionHandler: { (data, response, error) in
//            if let err = error {
//                debugPrint("response error")
//                failedHandler(err)
//                return
//            }
//
//            guard let responseData = data else { return }
//            let str = String(data: responseData, encoding: .utf8)
//            do {
//                let decoder = JSONDecoder()
//                let model = try decoder.decode(Response.self, from: responseData)
//                successHandler(model)
//            } catch {
//                debugPrint("parse error")
//                failedHandler(error)
//            }
//
//        })
//    }
//
//    func postTest(successHandler: @escaping () -> Void, failedHandler: @escaping(Error) -> Void) {
//        let parms = NSMutableDictionary()
//        self.methodPost(url: "https://dev-api.perfitt.io/m/test", params: parms, completionHander: { (data, response, error) in
//            // server error check
//            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
//            guard (200..<300).contains(statusCode) else {
//                print("~~> status code : \(statusCode)")
//                // error handle
//                return
//            }
//
//            if let err = error {
//                failedHandler(err)
//                return
//            }
//
//
//
//            guard let responseData = data else { return }
//            if let str = String(data: responseData, encoding: .utf8) {
//                debugPrint("post success", str)
//                successHandler()
//            }
//        })
//    }
//

}
