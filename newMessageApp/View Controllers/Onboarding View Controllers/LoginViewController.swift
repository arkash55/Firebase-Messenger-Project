//
//  LoginViewController.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 04/05/2021.
//

import UIKit
import SafariServices
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let logoView: UIImageView = {
        let logoView = UIImageView()
        logoView.contentMode = .scaleAspectFit
        logoView.clipsToBounds = true
        logoView.image = UIImage(named: "logoview")
        logoView.layer.masksToBounds = true
        return logoView
    }()
    
    private let emailField: UITextField = {
        let emailField = UITextField()
        emailField.placeholder = "Email Address..."
        emailField.backgroundColor = .secondarySystemBackground
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        emailField.leftViewMode = .always
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        emailField.returnKeyType = .next
        emailField.textColor = .label
        emailField.layer.borderWidth = 1.0
        emailField.layer.borderColor = UIColor.label.cgColor
        emailField.layer.masksToBounds = true
        emailField.layer.cornerRadius = 8.0
        return emailField
    }()
    
    private let passwordField: UITextField = {
        let passwordField = UITextField()
        passwordField.placeholder = "Password..."
        passwordField.backgroundColor = .secondarySystemBackground
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordField.leftViewMode = .always
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        passwordField.returnKeyType = .next
        passwordField.textColor = .label
        passwordField.layer.borderWidth = 1.0
        passwordField.layer.borderColor = UIColor.label.cgColor
        passwordField.layer.masksToBounds = true
        passwordField.layer.cornerRadius = 8.0
        return passwordField
    }()
    
    private let loginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 19, weight: .semibold)
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor.link.cgColor
        loginButton.layer.backgroundColor = UIColor.link.cgColor
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 12.0
        return loginButton
    }()
    
    private let termsButton: UIButton = {
        let termsButton = UIButton()
        termsButton.setTitle("Terms Of Service", for: .normal)
        termsButton.setTitleColor(.label, for: .normal)
        termsButton.titleLabel?.font = .systemFont(ofSize: 18)
        termsButton.layer.masksToBounds = true
        termsButton.layer.cornerRadius = 8.0
        return termsButton
    }()
    
    private let privacyButton: UIButton = {
        let privacyButton = UIButton()
        privacyButton.setTitle("Privacy Policies", for: .normal)
        privacyButton.setTitleColor(.label, for: .normal)
        privacyButton.layer.masksToBounds = true
        privacyButton.titleLabel?.font = .systemFont(ofSize: 18)
        privacyButton.layer.cornerRadius = 8.0
        return privacyButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviews()
        addTargets()
        configureNavigationBar()
        addDelegates()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = view.frame.size.width/3
        let fieldWith = view.frame.size.width - 40
        let misc = view.frame.size.width
        logoView.frame = CGRect(x: view.frame.midX - size/2,
                                y: view.safeAreaInsets.top + 50,
                                width: size,
                                height: size)
        
        emailField.frame = CGRect(x: 20,
                                  y: logoView.frame.maxY + 55,
                                  width: fieldWith,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 20,
                                     y: emailField.frame.maxY + 10,
                                     width: fieldWith,
                                     height: 52)
        
        loginButton.frame = CGRect(x: view.frame.midX - size/2,
                                   y: passwordField.frame.maxY + 30,
                                   width: size,
                                   height: 45)
        
        termsButton.frame = CGRect(x: view.frame.midX - misc/2,
                                   y: loginButton.frame.maxY + 150,
                                   width: misc,
                                   height: 40)
        
        privacyButton.frame = CGRect(x: view.frame.midX - misc/2,
                                     y: termsButton.frame.maxY + 5,
                                     width: misc,
                                     height: 40)
 
    }
    
    //functions
    private func addSubviews() {
        view.addSubview(logoView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
    }
    
    private func addTargets() {
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacyButton), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTermsButton), for: .touchUpInside)
    }
    
    private func addDelegates() {
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Sign in"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegisterButton))
    }
    
    private func showErrorAlert(text: String) {
        let alert = UIAlertController(title: "Could not Login User",
                                      message: text,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //@objc methods
    @objc private func didTapLoginButton() {
        //get rid of keyboards
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        //make sure fields are filled
        guard let email = emailField.text?.replacingOccurrences(of: " ", with: ""), !email.isEmpty,
              let password = passwordField.text?.replacingOccurrences(of: " ", with: ""), !password.isEmpty else {
            showErrorAlert(text: "Please fill in all fields")
            return
        }
        
        self.spinner.show(in: view)
        AuthManager.shared.loginUser(email: email, password: password) { [weak self] success in
            if success {
                DatabaseManager.shared.retrieveUserInfo(path: email.safeDatabaseKey()) { result in
                    switch result {
                    case .success(let userInfo):
                        guard let userDictionary = userInfo as? [String: Any],
                              let cachedUsername = userDictionary["username"] as? String else {
                            return
                        }
                        UserDefaults.standard.setValue(cachedUsername, forKey: "username")
                    case .failure(_):
                        print("failed to cache username at login")
                    }
                }
                UserDefaults.standard.setValue(email, forKey: "email")
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                }
            } else {
                self?.showErrorAlert(text: "Something went wrong...")
                print("could not sign in user")
            }
        }
        
    }
    
    @objc private func didTapRegisterButton() {
        let vc = RegistrationViewController()
        vc.title = "Register"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapTermsButton() {
        guard let url = URL(string: "https://www.facebook.com/terms.php") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func didTapPrivacyButton() {
        guard let url = URL(string: "https://www.facebook.com/help/325807937506242") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            didTapLoginButton()
        }
        return true
    }
}
