//
//  ConversationsViewController.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 04/05/2021.
//

import UIKit
import FirebaseAuth

struct LatestMessage {
    let message: String
    let date: String
    let isRead: Bool
}

struct ConversationModel {
    let conversationId: String
    let otherUsersEmail: String
    let otherUsersName: String
    let latestMessage: LatestMessage
}

class ConversationsViewController: UIViewController {
    
    private var conversations = [ConversationModel]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ConversationsTableViewCell.self, forCellReuseIdentifier: ConversationsTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationController()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        listenForConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateUser()
//        listenForConversations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    //functions
    private func listenForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeCachedEmail = email.safeDatabaseKey()
        
        DatabaseManager.shared.listenForConversations(email: safeCachedEmail) { [weak self] result in
            switch result {
            case .success(let conversationsArray):
                DispatchQueue.main.async {
                    self?.conversations = conversationsArray
                    self?.tableView.reloadData()
                }
            case .failure(_):
                print("failed to listen for messages")
            }
        }
    }
    
    
    private func validateUser() {
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let navVc = UINavigationController(rootViewController: vc)
            navVc.modalPresentationStyle = .fullScreen
            present(navVc, animated: false, completion: nil)
        }
    }
    
    private func configureNavigationController() {
        navigationItem.title = "Conversations"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        
    }
    
    
    //@objc methods
    @objc private func didTapComposeButton() {
        let vc = ComposeChatViewController()
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true, completion: nil)
        
        vc.completion = { selectedUser in
            let otherUsersEmail = selectedUser.email
            let otherUsersName = selectedUser.username
            
            
            DatabaseManager.shared.checkIfConversationExists(otherUsersEmail: otherUsersEmail) { [weak self] result in
                switch result {
                case .success(let conversationId):
                    let vc = ChatViewController(otherUsersEmail: otherUsersEmail, otherUsersName: otherUsersName, conversationId: conversationId)
                    vc.isNewConversation = false
                    vc.navigationController?.navigationBar.prefersLargeTitles = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                case .failure(_):
                    let vc = ChatViewController(otherUsersEmail: otherUsersEmail, otherUsersName: otherUsersName, conversationId: nil)
                    vc.isNewConversation = true
                    vc.navigationController?.navigationBar.prefersLargeTitles = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            

        }

    }

    
}


extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationsTableViewCell.identifier,
                                                 for: indexPath) as! ConversationsTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let vc = ChatViewController(otherUsersEmail: model.otherUsersEmail, otherUsersName: model.otherUsersName, conversationId: model.conversationId)
        vc.isNewConversation = false
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let cachedEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let cachedSafeEmail = cachedEmail.safeDatabaseKey()
        let model = conversations[indexPath.row]
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            //delete conversation
            DatabaseManager.shared.deleteConversation(email: cachedSafeEmail, conversationId: model.conversationId) { [weak self] success in
                if success {
                    self?.listenForConversations()
                    self?.conversations.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .left)
                } else {
                    print("failed to delete conversation")
                }
            }
            tableView.endUpdates()
        }
    }
    
}
