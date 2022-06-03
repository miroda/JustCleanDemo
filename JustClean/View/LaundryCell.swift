//
//  LaundryCell.swift
//  JustClean
//
//  Created by wuchang on 2022/5/30
//  
//

import Foundation
import UIKit
import SnapKit

final class LaundryCell: BaseTableViewCell {
    
    private lazy var laundryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "nickNameLabel"
        return label
    }()
    
    private lazy var favoriteLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "favoriteLabel"
        return label
    }()
    
    var model: V1.Laundry? {
        didSet {
            setUpData()
        }
    }
    
    func setUpData() {
        if let photo = model?.photo {
            laundryImageView.image = UIImage(named: photo)
        }
        if let name = model?.name {
            nameLabel.text = name
        }
        if let favorite = model?.favorite {
            favoriteLabel.text = favorite ? "❤️":""
        }
    }
    
    override func setUpSubviews() {
        contentView.addSubview(laundryImageView)
        laundryImageView.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(laundryImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(25)
        }
        
        contentView.addSubview(favoriteLabel)
        favoriteLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(25)
        }
    }
}
