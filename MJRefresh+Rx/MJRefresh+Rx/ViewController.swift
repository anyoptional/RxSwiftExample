//
//  ViewController.swift
//  MJRefresh+Rx
//
//  Created by Archer on 2018/6/3.
//  Copyright © 2018年 Archer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let v = UITableView()
        v.mj_header = MJRefreshNormalHeader()
        v.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return v
    }()
    
    private let dataSouce: RxTableViewSectionedReloadDataSource<SectionModel<String, String>> = {
        return RxTableViewSectionedReloadDataSource(configureCell: { (ds, tv, ip, item) in
            let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip)
            cell.textLabel?.text = item
            return cell
        })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "下拉试试"
        
        let x: CGFloat = 0
        let y = navigationController?.navigationBar.frame.maxY ?? 64
        let w = view.bounds.width
        let h = view.bounds.height - y
        tableView.frame =  CGRect(x: x, y: y, width: w, height: h)
        view.addSubview(tableView)
        
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        // ReactorKit 建议view的reactor在外部设置
        // 设置reactor会调用bind(ractor: Reactor)方法
        // 所以在viewdidload设置右边按钮 时间上就落后了 这里提前一点设置
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewController: View {
    func bind(reactor: ViewControllerReactor) {
        // 如果发出一个refreshing事件，就发起请求
        // 这里就是用户下拉tableview了
        tableView.mj_header
            .rx.refresh
            .filter { $0 == .refreshing }
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 点击按钮转换成发出refreshing事件 refreshing已绑定到Reactor.Action.Refresh
        // 触发mj_header刷新 然后请求数据
        navigationItem.rightBarButtonItem?.rx.tap
            .map { MJRefreshState.refreshing }
            .bind(to: tableView.mj_header.rx.refresh)
            .disposed(by: disposeBag)
        
        // 绑定tableview数据源
        reactor.state
            .map { $0.sectionModels }
            .bind(to: tableView.rx.items(dataSource: dataSouce))
            .disposed(by: disposeBag)
        
        // 根据返回的状态控制mj_header的状态
        reactor.state
            .map { $0.refreshingState }
            .bind(to: tableView.mj_header.rx.refresh)
            .disposed(by: disposeBag)
    }
}
