//
//  SettingsViewController.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 07/05/2021.
//

import UIKit
import JGProgressHUD
import SafariServices

struct SettingsCellModel {
    let title: String
    let handler: (() -> Void)
}

class SettingsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var models = [[SettingsCellModel]]()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Settings"
        view.addSubview(tableView)
        configureCells()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureCells() {
        models.append([
                        SettingsCellModel(title: "Edit Profile", handler: { [weak self] in
                            self?.didTapEditProfileCell()
                        }),
                        SettingsCellModel(title: "Invite Friends", handler: {
                            self.didTapInviteFriendsCell()
                        }),
                        SettingsCellModel(title: "Saved Photos", handler: {
                            self.didTapSavedPhotosCell()
                        })])
        
        models.append([
                        SettingsCellModel(title: "Help/Feedback", handler: { [weak self] in
                            self?.openSettingsUrl(type: .help)
                        }),
                        SettingsCellModel(title: "Terms Of Service", handler: { [weak self] in
                            self?.openSettingsUrl(type: .terms)
                        }),
                        SettingsCellModel(title: "Privacy Policies", handler: { [weak self] in
                            self?.openSettingsUrl(type: .privacy)
                        })])
        
        models.append([SettingsCellModel(title: "Log Out", handler: { [weak self] in
            self?.didTapSignOutButton()
        })])
        
    }
    
    private func didTapSignOutButton() {
        let actionsheet = UIAlertController(title: "Log Out",
                                            message: "Are you sure you want to log out?",
                                            preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Log Out",
                                            style: .destructive,
                                            handler: { _ in
                                                self.spinner.show(in: self.view)
                                                AuthManager.shared.logOutUser { [weak self] success in
                                                    if success {
                                                        UserDefaults.standard.setValue(nil, forKey: "email")
                                                        UserDefaults.standard.setValue(nil, forKey: "username")
                                                        UserDefaults.standard.setValue(nil, forKey: "newEmail")
                                                        DispatchQueue.main.async {
                                                            self?.tabBarController?.selectedIndex = 0
                                                            self?.navigationController?.popToRootViewController(animated: true)
                                                            self?.spinner.dismiss()
                                                        }
                                                        print("succesfully logged out")
                                                    } else {
                                                        print("failed to log out user")
                                                    }
                                                }
                                            }))
        
        actionsheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionsheet.popoverPresentationController?.sourceView = view
        actionsheet.popoverPresentationController?.sourceRect = view.bounds
        present(actionsheet, animated: true, completion: nil)
    }
    
    private func didTapEditProfileCell() {
        let vc = EditProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func didTapInviteFriendsCell() {
        
    }
    
    private func didTapSavedPhotosCell() {
        
    }
    
    enum SettingsUrlType {
        case terms
        case privacy
        case help
    }
    
    private func openSettingsUrl(type: SettingsUrlType) {
        let urlString: String
        switch type {
        case .terms: urlString = "https://www.facebook.com/terms.php"
        case .privacy: urlString = "https://www.facebook.com/help/325807937506242"
        case .help: urlString = "https://www.facebook.com/help/contact/268228883256323"
      }
        guard let url = URL(string: urlString) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)

    }
    
    

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return  models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.section][indexPath.row]
        model.handler()
        
    }
}
