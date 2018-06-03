//
//  MJRefresh+Rx.swift
//  MJRefresh+Rx
//
//  Created by Archer on 2018/6/3.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Foundation

class Target: NSObject, Disposable {
    private var retainSelf: Target?
    override init() {
        super.init()
        self.retainSelf = self
    }
    func dispose() {
        self.retainSelf = nil
    }
}

private final
class MJRefreshTarget<Component: MJRefreshComponent>: Target {
    weak var component: Component?
    let refreshingBlock: MJRefreshComponentRefreshingBlock
    
    init(_ component: Component , refreshingBlock: @escaping MJRefreshComponentRefreshingBlock) {
        self.refreshingBlock = refreshingBlock
        self.component = component
        super.init()
        component.setRefreshingTarget(self, refreshingAction: #selector(onRefeshing))
    }
    
    @objc func onRefeshing() {
        refreshingBlock()
    }
    
    override func dispose() {
        super.dispose()
        self.component?.refreshingBlock = nil
    }
}

extension Reactive where Base: MJRefreshComponent {
    var refresh: ControlProperty<MJRefreshState> {
        let source: Observable<MJRefreshState> = Observable.create { [weak component = self.base] observer  in
            MainScheduler.ensureExecutingOnScheduler()
            guard let component = component else {
                observer.on(.completed)
                return Disposables.create()
            }

            observer.on(.next(component.state))

            let observer = MJRefreshTarget(component) {
                observer.on(.next(component.state))
            }
            return observer
            }.takeUntil(deallocated)
        
        let bindingObserver = Binder<MJRefreshState>(self.base) { (component, state) in
            component.state = state
        }
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}
