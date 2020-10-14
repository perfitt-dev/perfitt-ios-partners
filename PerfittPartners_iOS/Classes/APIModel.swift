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
}

public struct ErrorModel: Codable {
    var message: String
    var type: String
}
