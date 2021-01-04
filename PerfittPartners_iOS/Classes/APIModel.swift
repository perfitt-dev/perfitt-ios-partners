//
//  HackerModel.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/08.
//

import Foundation

public struct FootModel: Codable {
    var feetId: String?
    var averageSize: Int
    var nickName: String?
    var gender: String?
    var customerId: String?
}

public struct ErrorModel: Codable {
    var message: String
    var type: String
}

struct FeetBody: Codable {
    var left: FootModel?
    var right: FootModel?
    var sourceType: String?
    var averageSize: Int?
    
    struct FootModel: Codable {
        var image: String?
        var base: [Double]?
        var leftRect: [Double]?
        var rightRect: [Double]?
    }
}

struct FeetModel: Codable {
    var id: String
    var feet: Feet?
    
    struct Feet: Codable {
        var left: FeetResponse?
        var right: FeetResponse?
        
        struct FeetResponse: Codable {
            var uri: String?
            var length: Double?
            var width: Double?
        }
    }
}
