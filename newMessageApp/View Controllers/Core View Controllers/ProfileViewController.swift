//
//  ProfileViewController.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 04/05/2021.
//

import UIKit
import SDWebImage

struct ProfileModel {
    let title: String
    let label: String
}

class ProfileViewController: UIViewController {
    
    private var models = [ProfileModel]()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationController()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeaderView()
        
        view.addSubview(tableView)
        getUserData()
        configureCells()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //functions
    private func configureNavigationController() {
        navigationItem.title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSettingsButton))
    }
    
    private func getUserData() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = email.safeDatabaseKey()
        
        DatabaseManager.shared.retrieveUserInfo(path: safeEmail) { result in
            switch result {
            case .success(let data):
                guard let userDictionary = data as? [String: Any],
                      let username = userDictionary["username"] as? String,
                      let email = userDictionary["email"] as? String else {
                    print("failed to unwrap")
                    return
                }
                
                UserDefaults.standard.setValue(username, forKey: "username")
                UserDefaults.standard.setValue(email, forKey: "newEmail")
                
            case .failure(_):
                print("failed to retrieve user info")
            }
        }
  
    }
    
    
    private func configureCells() {
        guard let email = UserDefaults.standard.value(forKey: "newEmail") as? String,
              let username = UserDefaults.standard.value(forKey: "username") as? String else {
            return
        }
        print("Email: \(email), Username: \(username) ")
        
        models.append(ProfileModel(title: "Email:",
                                   label: email))
        
        models.append(ProfileModel(title: "Username:",
                                   label: username))
        
        print("configured cells")
        
        
    }
    
    private func createTableHeaderView() -> UIView? {
        let header = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: view.frame.size.width,
                                          height: view.frame.size.height/3))
        
        let size = view.frame.size.width/2.5
        let profileView = UIImageView(frame: CGRect(x: header.frame.midX - size/2,
                                                    y: header.frame.midY - size/2,
                                                    width: size,
                                                    height: size).integral)
        
        profileView.layer.cornerRadius = size/2
        profileView.layer.borderWidth = 2.0
        profileView.layer.borderColor = UIColor.secondaryLabel.cgColor
        profileView.layer.masksToBounds = true
        profileView.backgroundColor = .systemBackground
        profileView.contentMode = .scaleAspectFill
        profileView.image = UIImage(systemName: "person.circle")
        profileView.tintColor = .secondaryLabel
        
        
        //get users profile picture
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        StorageManager.shared.retrieveProfilePictureUrl(email: email) { result in
            switch result {
            case .success(let profilePictureUrl):
                DispatchQueue.main.async {
                    profileView.sd_setImage(with: profilePictureUrl, completed: nil)
                }
            case .failure(_):
                print("failed to retrieve profile picture url")
            }
        }
        
        header.backgroundColor = .link
        header.addSubview(profileView)
        return header
    }
    
    //@objc methods
    @objc private func didTapSettingsButton() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    
    

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier,
                                                 for: indexPath) as! ProfileTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
