//
//  HomeViewController.swift
//  JustClean
//
//  Created by Derek on 2022/5/30
//  
//

import UIKit

class HomeViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tableView.accessibilityIdentifier = "tableView"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LaundryCell.self, forCellReuseIdentifier: LaundryCell.reuseIdentifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setSubView()
    }

    func setSubView() {
        view.addSubview(tableView)
    }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
//        return vm.records.count
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let recordModel = vm.records[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: LaundryCell.self)
        
//        cell.model = recordModel
//        cell.view.model = recordModel
//        cell.view.delegate = self
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let recordModel = vm.records[indexPath.row]
//        showCommentReplay(model: recordModel)
    }
}

