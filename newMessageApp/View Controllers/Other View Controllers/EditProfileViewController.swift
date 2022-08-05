//
//  EditProfileViewController.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 07/05/2021.
//

import UIKit

class EditProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    //functions
    private func configureNavigationController() {
        navigationItem.title = "Edit Profile"
        navigationController?.navigationBar.prefersLargeTitles = true

    }

}
