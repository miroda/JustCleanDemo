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
        // Long Press
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPressGesture)
        return tableView
    }()

    lazy var preView = UIImageView()

    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        // start preview
        if longPressGesture.state == .began {
            let p = longPressGesture.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: p)
            if indexPath == nil {
                print("Long press on table view, not row.")

            } else if longPressGesture.state == UIGestureRecognizer.State.began {
                print("Long press on row, at \(indexPath!.row)")
                let model: Laundry? = list?[indexPath!.row]
                preView.isHidden = false
                if let photo = model?.photo {
                    preView.image = UIImage(named: photo)
                }
            }
        } else if longPressGesture.state == .ended {
            // close preview
            preView.isHidden = true
        }
    }

    var list: [Laundry]? {
        return LaundryAPI.sharedInstance.getAllLaundrys()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateEventTableData), name: .updateEventTableData, object: nil)
        setSubView()

        // remove duplicate data
//        LaundryAPI.sharedInstance.deleteAllLaundrys()
//        RemoteReplicator.sharedInstance.fetchData()
    }

    @objc func updateEventTableData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.tableView.reloadData()
        }
    }

    func setSubView() {
        title = "JustClean"
        view.addSubview(tableView)

        view.addSubview(preView)
        preView.isHidden = true
        preView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return list?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model: Laundry? = list?[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: LaundryCell.self)
        cell.model = model
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model: Laundry? = list?[indexPath.row]
        let ctrl = LaundryDetailController()
        ctrl.model = model
        self.navigationController?.pushViewController(ctrl, animated: true)
    }

    // add laundry as favorite
    func tableView(_: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let model: Laundry? = list?[indexPath.row]

        let modifyAction = UIContextualAction(style: .normal, title: "Favorite", handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in

            if let favorite = model?.favorite, let id = model?.id {
                LaundryAPI.sharedInstance.updateLaundryFavoriteById(id, favorite: !favorite)
            }
            success(true)
        })
        modifyAction.backgroundColor = .blue
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
}
