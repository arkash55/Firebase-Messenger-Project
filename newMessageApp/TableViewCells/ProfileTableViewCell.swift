//
//  ProfileTableViewCell.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 12/05/2021.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    static let identifier = "ProfileTableViewCell"
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        return titleLabel
    }()
    
    private let valueLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = .label
        return valueLabel
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.frame.size.width/3 - 10
        
        titleLabel.frame = CGRect(x: 5,
                                  y: 5,
                                  width: size,
                                  height: contentView.frame.size.height - 10)
        
        valueLabel.frame = CGRect(x: titleLabel.frame.maxX + 5,
                                  y: 5,
                                  width: contentView.frame.size.width - size - 5,
                                  height: contentView.frame.size.height - 10)
    }
    
    
    public func configure(with model: ProfileModel) {
        self.titleLabel.text = model.title
        self.valueLabel.text = model.label
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.valueLabel.text = nil
    }
    
}
