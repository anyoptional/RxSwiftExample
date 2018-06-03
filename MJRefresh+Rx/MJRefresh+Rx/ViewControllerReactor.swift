//
//  ViewControllerReactor.swift
//  MJRefresh+Rx
//
//  Created by Archer on 2018/6/3.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Foundation

class ViewControllerReactor: Reactor {
    // 一个action代表了当前视图可能的事件
    // 这里很简单 只有一个刷新事件
    enum Action {
        case refresh
    }
    
    // 对具体的事件修改状态
    enum Mutation {
        // 设置刷新状态  外部根据发出的值就可以控制刷新控件的状态了
        case setRefreshingState(refreshingState: MJRefreshState)
        // 请求的数据
        case response(sectionModels: [SectionModel<String, String>])
    }
    
    // 代表当前视图的状态
    struct State {
        var refreshingState = MJRefreshState.idle
        var sectionModels = [SectionModel<String, String>]()
    }
    
    // 一个初始状态
    var initialState = State()
    
    
    // 定义对具体action如何响应
    func mutate(action: ViewControllerReactor.Action) -> Observable<ViewControllerReactor.Mutation> {
        if action == .refresh {
            return fakePullingData()
        }
        return .empty()
    }
    
    // 定义对具体的更改如何反应到状态上
    func reduce(state: ViewControllerReactor.State, mutation: ViewControllerReactor.Mutation) -> ViewControllerReactor.State {
        var state = state
        switch mutation {
        case let .setRefreshingState(refreshingState):
            state.refreshingState = refreshingState
        case let .response(sectionModels):
            state.sectionModels = sectionModels
        }
        return state
    }
}

extension ViewControllerReactor {
    private func fakePullingData() -> Observable<Mutation> {
        // 通知MJRefreshHeader进入刷新状态
        let beginRefreshing = Observable.just(Mutation.setRefreshingState(refreshingState: .refreshing))
        // 延迟两秒订阅，模仿一下网络请求
        let pullingData = Observable.just(Mutation.response(sectionModels: [SectionModel(model: "", items:["hello", "world", "this", "is", "RxMJRefresh", "have func:)"])])).delaySubscription(2, scheduler: ConcurrentMainScheduler.instance)
        // 数据请求回来，通知MJRefreshHeader结束刷新
        let endReshing = Observable.just(Mutation.setRefreshingState(refreshingState: .idle))
        // 用concat按顺序连接上述Observables
        return Observable.concat([beginRefreshing, pullingData, endReshing])
    }
}
