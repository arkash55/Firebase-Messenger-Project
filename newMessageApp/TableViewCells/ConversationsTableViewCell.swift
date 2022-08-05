//
//  ConversationsTableViewCell.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 14/06/2021.
//

import UIKit

class ConversationsTableViewCell: UITableViewCell {

    static let identifier = "ConversationsTableViewCell"
    
    private let profileView: UIImageView = {
        let profileView = UIImageView()
        profileView.backgroundColor = .secondaryLabel
        profileView.layer.masksToBounds = true
        return profileView
    }()
    
    private let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.textColor = .label
        usernameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        usernameLabel.numberOfLines = 1
        return usernameLabel
    }()
    
    private let latestMessageLabel: UILabel = {
        let latestMessageLabel = UILabel()
        latestMessageLabel.textColor = .label
        latestMessageLabel.font = .systemFont(ofSize: 13, weight: .regular)
        latestMessageLabel.numberOfLines = 2
        latestMessageLabel.clipsToBounds = true
        return latestMessageLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        addSubviews()
        
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
                                   height: size)
        
        usernameLabel.frame = CGRect(x: profileView.frame.maxX + 5,
                                     y: 5,
                                     width: contentView.frame.size.width - size - 15,
                                     height: size/2)
        
        let messageSize = latestMessageLabel.sizeThatFits(contentView.frame.size)
        latestMessageLabel.frame = CGRect(x: profileView.frame.maxX + 5,
                                          y: usernameLabel.frame.maxY,
                                          width: contentView.frame.size.width - size - 15,
                                          height: messageSize.height)
    }
    
    private func addSubviews() {
        contentView.addSubview(profileView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(latestMessageLabel)
    }
    
    public func configure(with model: ConversationModel) {
        usernameLabel.text = model.otherUsersName
        latestMessageLabel.text = model.latestMessage.message
        StorageManager.shared.retrieveProfilePictureUrl(email: model.otherUsersEmail) { [weak self] result in
            switch result {
            case .success(let profilePicUrl):
                self?.profileView.sd_setImage(with: profilePicUrl, completed: nil)
            case .failure(_):
                print("failed to retrieve profile pic url")
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        latestMessageLabel.text = nil
        profileView.image = nil
    }
    
}
