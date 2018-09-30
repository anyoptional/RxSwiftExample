//
//  APIProvider.swift
//  Networking+Rx
//
//  Created by Archer on 2018/9/30.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Moya
import Result
import RxSwift
import SwiftyJSON

/// 全局的请求发起者
let APIProvider = Moya.MoyaProvider<Moya.MultiTarget>()

/// extends reactive proxy
extension MoyaProvider: ReactiveCompatible {}

/// reactive extension for MoyaProvider
extension Reactive where Base : Moya.MoyaProvider<Moya.MultiTarget> {
    /// start a request & share resources
    func request(_ token: APITargetType, cacheable: Bool = false) -> Observable<APIResultType> {
        return Observable.create { [weak base] observer in
            /// load cache first
            if cacheable { observer.onNext(Result(value: APICache.objectForTarget(token))) }
            /// send request
            let cancellableToken = base?.request(Base.Target(token), callbackQueue: nil, progress: nil) { result in
                debugPrint("---------------------->>>  request send")
                result.analysis(ifSuccess: { (response) in
                    do {
                        let response = try response.filterSuccessfulStatusCodes()
                        let jsonObject = try response.mapString()
                        let json = JSON(parseJSON: jsonObject)
                        if let errorCode = json["status"].string, let errorMessage = json["msg"].string {
                            if errorCode == APIError.okey {
                                observer.onNext(Result(value: jsonObject))
                                /// cache response data
                                if cacheable { APICache.setObject(jsonObject, forTarget: token) }
                            } else {
                                observer.onNext(Result(error: APIError(errorCode: errorCode, errorMessage: errorMessage)))
                            }
                        } else {
                            observer.onNext(Result(error: APIError.badRequest))
                        }
                    } catch  {
                        observer.onNext(Result(error: APIError.badRequest))
                    }
                }, ifFailure: { (error) in
                    observer.onNext(Result(error: APIError.badRequest))
                })
                /// unsubscribe
                observer.onCompleted()
            }
            
            return Disposables.create { cancellableToken?.cancel() }
            
        }.observeOn(MainScheduler.instance).retry(1).share(replay: 1, scope: .forever)
    }
}
