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
    
    // 발정보 전송
    public func reqeustFootData(_ footData: FootModel, _ APIKEY: String, successHandler: @escaping (String?) -> Void, failedHandler: @escaping(ErrorModel) -> Void) {
        do {
            let jsonData = try  JSONEncoder().encode(footData)
            let params = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            
            self.apiTypePost(url: APIConsts.FOOTDATA + "?apiKey=\(APIKEY)", params: params ?? [:], completionHander: { (data, response, error) in
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    let errModel = ErrorModel(message: "서버에러입니다.", type: "")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        failedHandler(errModel)
                    }
                    return
                }
                                
                guard (200..<300).contains(statusCode) else {
                    print("~~> status code : \(statusCode)")
                    guard let responseData = data else { return }
                    let decoder = JSONDecoder()
                    do {
                        let errModel = try decoder.decode(ErrorModel.self, from: responseData)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            failedHandler(errModel)
                        }
                        return
                    }
                    catch {
                        if statusCode > 500 {
                            let errModel = ErrorModel(message: "time out", type: "time out")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                failedHandler(errModel)
                            }
                        }
                    }
                    return
                }
                
                if let _ = error {
                    guard let responseData = data else { return }
                    let decoder = JSONDecoder()
                    let errModel = try! decoder.decode(ErrorModel.self, from: responseData)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        failedHandler(errModel)
                    }
                    return
                }
                
                if let responseData = data {
                    let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                    let successStr = json?["id"] as? String
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        successHandler(successStr)
                    }
                }
                
                
            })
        } catch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                failedHandler(ErrorModel(message: "서버에러입니다.", type: ""))
            }
            
        }
        
    }
    
    // feet data 전송
    func reqeustFeetData (_ feetData: FeetBody?, _ APIKEY: String, camMode: String, successHandler: @escaping (FeetModel) -> Void, failedHandler: @escaping(ErrorModel) -> Void) {
        do {
            let jsonData = try  JSONEncoder().encode(feetData)
            let params = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            let apiPath = "\(APIConsts.CORE)/\(camMode)/feet"
            
            self.apiTypePost(url: apiPath + "?apiKey=\(APIKEY)", params: params ?? [:], completionHander: { (data, response, error) in
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    let errModel = ErrorModel(message: "서버에러입니다.", type: "")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        failedHandler(errModel)
                    }
                    return
                }
                                
                guard (200..<300).contains(statusCode) else {
                    print("~~> status code : \(statusCode)")
                    guard let responseData = data else { return }
                    let decoder = JSONDecoder()
                    let errModel = try! decoder.decode(ErrorModel.self, from: responseData)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        failedHandler(errModel)
                    }
                    return
                }
                
                if let _ = error {
                    guard let responseData = data else { return }
                    let decoder = JSONDecoder()
                    let errModel = try! decoder.decode(ErrorModel.self, from: responseData)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        failedHandler(errModel)
                    }
                    return
                }
                
                if let responseData = data {
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                    
                    let feetModel = try! decoder.decode(FeetModel.self, from: responseData)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        successHandler(feetModel)
                    }
                }
            })
        } catch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                failedHandler(ErrorModel(message: "서버에러입니다.", type: ""))
            }
            
        }
        
    }
}

