//
//  APIConsts.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/18.
//

import Foundation

class APIConsts {
    public static let BASE_URL = "https://dev-api.perfitt.io"
    
    public static let API_VERSION =  "/v2"
    
    public static let CORE =  BASE_URL + "/core" + API_VERSION
        
    public static let FOOTDATA =  CORE + "/users"
    
    public static let SDK_VERSION = "0.1.1"
}

