//
//  APICache.swift
//  Networking+Rx
//
//  Created by Archer on 2018/9/30.
//  Copyright © 2018年 Archer. All rights reserved.
//

import YYKit

fileprivate var kAPICacheDirectoryPath: String {
    let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString?
    return docPath?.appendingPathComponent("com.example.cache") ?? ""
}

/// cache network response with URL & Parameter
struct APICache {
    // the underlying cache instance
    private static let _cache = YYCache(path: kAPICacheDirectoryPath)
    
    static func setObject(_ json: JSONObject, forTarget target: APITargetType) {
        let cacheKey = cacheKeyWithTarget(target)
        _cache?.setObject((json as! NSString), forKey: cacheKey, with: nil)
    }
    
    static func objectForTarget(_ target: APITargetType) -> JSONObject {
        let cacheKey = cacheKeyWithTarget(target)
        return _cache?.object(forKey: cacheKey) as JSONObject
    }
    
    private static func cacheKeyWithTarget(_ target: APITargetType) -> String {
        if target.parameters.isEmpty { return target.host + target.path }
        do {
            let paramData = try JSONSerialization.data(withJSONObject: target.parameters, options: [])
            if let paramString = String(data: paramData, encoding: .utf8) {
                return target.host + target.path + "\(paramString)"
            }
        } catch {
            fatalError("could not serialize patameters")
        }
        
        return target.host + target.path
    }
}
