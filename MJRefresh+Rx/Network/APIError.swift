
//
//  APIError.swift
//  Networking+Rx
//
//  Created by Archer on 2018/9/30.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Foundation

struct APIError: Error {
    var errorCode: String
    var errorMessage: String
}

extension APIError {
    // 请求成功
    static var okey: String { return "200" }
    
    // 请求失败
    static let badRequest = APIError(errorCode: "250", errorMessage: "请求失败")
}

