//
//  Observable+API.swift
//  Networking+Rx
//
//  Created by Archer on 2018/9/30.
//  Copyright © 2018年 Archer. All rights reserved.
//

import RxSwift
import RxOptional

extension Observable where Element == APIResultType {
    /// app-based operation, filter error
    func mapError() -> Observable<APIError> {
        return mapErrorKeepOptional().filterNil()
    }
    
    func mapErrorKeepOptional() -> Observable<APIError?> {
        return map { (result) in
            result.analysis(ifSuccess: { _ -> APIError? in
                return nil
            }, ifFailure: { (error) in
                return error
            })
        }
    }
    
    /// app-based operation, map to intend object type
    func mapObject<_Tp: JSONObjectConvertible>(_ ObjCType: _Tp.Type) -> Observable<_Tp> {
        return mapObjectKeepOptional(ObjCType).filterNil()
    }
    
    func mapObjectKeepOptional<_Tp: JSONObjectConvertible>(_ ObjCType: _Tp.Type) -> Observable<_Tp?> {
        return map { (result) in
            result.analysis(ifSuccess: { (json)  in
                return ObjCType.object(withJSON: json)
            }, ifFailure: { _ in
                return nil
            })
        }
    }
}
