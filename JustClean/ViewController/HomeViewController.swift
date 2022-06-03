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
                let model: V2.Laundry? = list?[indexPath!.row]
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
    
    //combine favorites and notFavorites together,show favorites as higher priority
    var list: [V2.Laundry]? {
        var finalData = [V2.Laundry]()
        let favorites = try? JustClean.dataStack.fetchAll(From<V2.Laundry>(), Where<V2.Laundry>({ $0.$favorite == true }))
        let notFavorites = try? JustClean.dataStack.fetchAll(From<V2.Laundry>(), Where<V2.Laundry>({ $0.$favorite == false }))
        if let favorites = favorites {
            finalData.append(contentsOf: favorites)
        }
        if let notFavorites = notFavorites {
            finalData.append(contentsOf: notFavorites)
        }
        return finalData
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mockData()
        setSubView()
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
        let model: V2.Laundry? = list?[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: LaundryCell.self)
        cell.model = model
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model: V2.Laundry? = list?[indexPath.row]
        let ctrl = LaundryDetailController()
        ctrl.model = model
        self.navigationController?.pushViewController(ctrl, animated: true)
    }

    //add laundry as favorite
    func tableView(_: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let model: V2.Laundry? = list?[indexPath.row]
        let name = model?.name
        let modifyAction = UIContextualAction(style: .normal, title: "Favorite", handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in

            JustClean.dataStack.perform(asynchronous: { transaction in
                                            let laundry = try transaction.fetchOne(From<V2.Laundry>(), Where<V2.Laundry>({ $0.$name == name }))
                                            if let favorite = laundry?.favorite {
                                                laundry?.favorite = !favorite
                                            }
                                        },
                                        completion: { [weak self] _ in
                                            self?.tableView.reloadData()
                                        })

            success(true)
        })
        modifyAction.image = UIImage(named: "hammer")
        modifyAction.backgroundColor = .blue

        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
}
