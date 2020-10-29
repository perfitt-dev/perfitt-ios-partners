//
//  HackerModel.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/08.
//

import Foundation

public struct FootModel: Codable {
    var leftImage: String
    var rightImage: String
    var sourceType: String = ""
    var averageSize: Int
    var nickName: String?
    var gender: String?
}

public struct ErrorModel: Codable {
    var message: String
    var type: String
}
