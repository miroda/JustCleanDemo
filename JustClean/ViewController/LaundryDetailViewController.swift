//
//  HomeViewController.swift
//  JustClean
//
//  Created by Derek on 2022/5/30
//
//

import UIKit

class LaundryDetailController: UIViewController {
    var model: Laundry?
    var quantity = 0
    var quantityDictionary = [String: Int]()

    var items:[LaundryItem]? {
        return model?.items?.allObjects as? [LaundryItem]
    }
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tableView.accessibilityIdentifier = "tableView"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LaundryItemCell.self, forCellReuseIdentifier: LaundryItemCell.reuseIdentifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRightButton()
        title = "Laundry Detail"
        view.addSubview(tableView)
    }

    @objc func addTapped() {}

    func setUpRightButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cart", style: .plain, target: self, action: #selector(addTapped))
    }

    func updateUpRightButton() {
        var q = 0
        for (_, value) in quantityDictionary {
            q += value
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cart:\(q)", style: .plain, target: self, action: #selector(addTapped))
    }
}

extension LaundryDetailController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        // Laundry name
        let label = UILabel()
        headerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(5)
            make.width.equalTo(150)
            make.height.equalTo(20)
        }
        label.text = model?.name ?? ""
        label.font = .systemFont(ofSize: 16)
        label.textColor = .red
        // Laundry shop picture
        let laundryImageView = UIImageView()
        headerView.addSubview(laundryImageView)
        laundryImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.top.equalTo(label.snp.bottom).offset(5)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }

        laundryImageView.contentMode = .scaleAspectFit
        if let photo = model?.photo {
            laundryImageView.image = UIImage(named: photo)
        }

        return headerView
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 100
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: LaundryItem? = items?[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: LaundryItemCell.self)

        cell.model = item

        return cell
    }

    // add quantity by the name of the item
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: LaundryItem? = items?[indexPath.row]
        item?.price
        let value = quantityDictionary[item?.name ?? ""] ?? 0
        let addValue = value + 1
        quantityDictionary[item?.name ?? ""] = addValue
        updateUpRightButton()
    }

    // Delete quantity by the name of the item
    func tableView(_: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let item: LaundryItem? = items?[indexPath.row]
        let modifyAction = UIContextualAction(style: .normal, title: "Delete", handler: { [weak self] (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in

            if let value = self?.quantityDictionary[item?.name ?? ""], value > 0 {
                self?.quantityDictionary[item?.name ?? ""] = value - 1
            }
            self?.updateUpRightButton()
            success(true)
        })
        modifyAction.backgroundColor = .red

        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
}
