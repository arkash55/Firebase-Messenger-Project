//
//  ComposeTableViewCell.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 16/05/2021.
//

import UIKit
import SDWebImage

class ComposeTableViewCell: UITableViewCell {

    static let identifier = "ComposeTableViewCell"
    
    private let profileView: UIImageView = {
        let profileView = UIImageView()
        profileView.backgroundColor = .systemGray
        profileView.contentMode = .scaleAspectFill
        profileView.layer.masksToBounds = true
        return profileView
    }()
    
    private let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        usernameLabel.textColor = .label
        usernameLabel.clipsToBounds = true
        return usernameLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(usernameLabel)
        contentView.addSubview(profileView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.frame.size.height - 10
        profileView.layer.cornerRadius = size/2
        profileView.frame = CGRect(x: 5,
                                   y: 5,
                                   width: size,
                                   height: size).integral
        
        usernameLabel.frame = CGRect(x: profileView.frame.maxX + 5,
                                     y: 5,
                                     width: contentView.frame.size.width - size - 15,
                                     height: size/2)
    }
    
    
    
    //functions
    public func configure(with model: ComposeChatModel) {
        usernameLabel.text = model.username
        StorageManager.shared.retrieveProfilePictureUrl(email: model.email) { result in
            switch result {
            case .success(let url):
                self.profileView.sd_setImage(with: url, completed: nil)
            case .failure(_):
                print("Unable to load profile picture")
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        profileView.image = nil
    }
    
}
