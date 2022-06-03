//
//  LaundryItemCell.swift
//  JustClean
//
//  Created by wuchang on 2022/6/3
//
//

import Foundation
import SnapKit
import UIKit

final class LaundryItemCell: BaseTableViewCell {
    var model: V2.LaundryItem? {
        didSet {
            setUpData()
        }
    }

    func setUpData() {
        if let name = model?.name {
            nameLabel.text = name
        }

        if let price = model?.price {
            priceLabel.text = "\(price)"
        }
    }

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "nickNameLabel"
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "priceLabel"
        return label
    }()

    override func setUpSubviews() {
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(25)
        }
        
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(25)
        }
    }
}
