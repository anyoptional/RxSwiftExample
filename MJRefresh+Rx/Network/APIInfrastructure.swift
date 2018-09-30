//
//  APIInfrastructure.swift
//  Networking+Rx
//
//  Created by Archer on 2018/9/30.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Moya
import YYKit
import Result

typealias JSONObject = Any
typealias APIHost = String
typealias APIPath = String
typealias APITask = Moya.Task
typealias APIMethod = Moya.Method
typealias APIParameter = [String : Any]
typealias APIResultType = Result<JSONObject, APIError>

protocol JSONObjectConvertible {
    static func object(withJSON json: JSONObject) -> Self?
}

protocol APIParameterConvertible {
    func toParameters() -> APIParameter
}

protocol APITargetType: Moya.TargetType {
    var host: APIHost { get }
    var parameters: APIParameter { get }
}

extension APITargetType {
    
    var baseURL: URL { return URL(string: host)! }
    
    var sampleData: Data { return Data() }
    
    var parameters: APIParameter { return [:] }
    
    var task: APITask {
        switch method {
        case .get:  return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .post: return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        default: return .requestParameters(parameters: parameters, encoding: JSONEncoding.default) }
    }
    
    var headers: [String : String]? { return ["Content-type": "application/json"] }
}

///
extension NSObject: YYModel {}
extension NSObject: JSONObjectConvertible {
    static func object(withJSON json: JSONObject) -> Self? {
        return model(withJSON: json)
    }
}
extension NSObject: APIParameterConvertible {
    func toParameters() -> APIParameter {
        let validJSON = modelToJSONObject()
        return (validJSON as? APIParameter) ?? [:]
    }
}

