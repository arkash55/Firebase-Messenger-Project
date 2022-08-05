//
//  ComposeChatViewController.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 14/05/2021.
//

import UIKit
import JGProgressHUD

struct ComposeChatModel {
    let username: String
    let email: String
}

class ComposeChatViewController: UIViewController {
    
    public var completion: ((ComposeChatModel) -> Void)?
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var hasFetched = false
    
    private var users = [[String:String]]()
    private var results = [ComposeChatModel]()
    
    private let tableview: UITableView = {
        let tableview = UITableView()
        tableview.register(ComposeTableViewCell.self, forCellReuseIdentifier: ComposeTableViewCell.identifier)
        tableview.isHidden = true
        return tableview
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.placeholder = "Search User..."
        return searchBar
    }()
    
    private let noResultsLabel: UILabel = {
        let noResultsLabel = UILabel()
        noResultsLabel.text = "No Results"
        noResultsLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        noResultsLabel.textColor = .secondaryLabel
        noResultsLabel.isHidden = true
        noResultsLabel.textAlignment = .center
        return noResultsLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        tableview.delegate = self
        tableview.dataSource = self
        searchBar.delegate = self
        
        view.addSubview(tableview)
        view.addSubview(noResultsLabel)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
        let size = view.frame.size.width/2.5
        noResultsLabel.frame = CGRect(x: view.frame.midX - size/2,
                                      y: view.frame.size.height/2.5,
                                      width: size,
                                      height: 52)
        
    }
    
    //functions
    private func configureNavigationBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didPressCancel))
    }
    

  //@objc methods
    @objc private func didPressCancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}


///Configure Search Functionality
extension ComposeChatViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.replacingOccurrences(of: " ", with: "") else {
            return
        }
        spinner.show(in: view)
        results.removeAll()
        searchForUser(with: text)
    }
    
    private func searchForUser(with query: String) {
        if hasFetched {
            filterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.users = usersCollection
                    self?.hasFetched = true
                    self?.filterUsers(with: query)
                case .failure(_):
                    print("Failed to get usersCollection")
                }
            }
        }
    }
    
    private func filterUsers(with term: String) {
        guard hasFetched else {
            return
        }
        
        guard let cachedEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeCachedEmail = cachedEmail.safeDatabaseKey()
        
        let filteredResults: [[String: String]] = users.filter({
            guard let email = $0["email"],
                  email != safeCachedEmail else {
                return false
            }
            
            guard let username = $0["username"]?.lowercased() else {
                return false
            }
            
            return username.hasPrefix(term.lowercased())
        })
        
        let mappedResults: [ComposeChatModel] = filteredResults.compactMap({
            guard let username = $0["username"],
                  let email = $0["email"] else {
                return nil
            }
            return ComposeChatModel(username: username, email: email)
        })
        self.results = mappedResults
        updateUI()
        
    }
    
    private func updateUI() {
        if results.isEmpty {
            DispatchQueue.main.async {
                self.tableview.isHidden = true
                self.spinner.dismiss()
                self.noResultsLabel.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.tableview.isHidden = false
                self.spinner.dismiss()
                self.noResultsLabel.isHidden = true
                self.tableview.reloadData()
            }
        }
    }
    
    
    
}




///Configure Tableview
extension ComposeChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableview.dequeueReusableCell(withIdentifier: ComposeTableViewCell.identifier,
                                                 for: indexPath) as! ComposeTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        let selectedUser = results[indexPath.row]
        self.dismiss(animated: true) { [weak self] in
            self?.completion?(selectedUser)
        }
    }

}


