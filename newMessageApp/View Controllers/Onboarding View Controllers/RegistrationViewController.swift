//
//  RegistrationViewController.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 04/05/2021.
//

import UIKit
import JGProgressHUD

class RegistrationViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let profileView: UIImageView = {
        let profileView = UIImageView()
        profileView.image = UIImage(systemName: "person.circle")
        profileView.tintColor = .secondaryLabel
        profileView.layer.borderWidth = 1.0
        profileView.layer.borderColor = UIColor.secondaryLabel.cgColor
        profileView.layer.masksToBounds = true
        return profileView
    }()
    
    private let usernameField: UITextField = {
        let usernameField = UITextField()
        usernameField.placeholder = "Username..."
        usernameField.backgroundColor = .secondarySystemBackground
        usernameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        usernameField.leftViewMode = .always
        usernameField.autocorrectionType = .no
        usernameField.autocapitalizationType = .none
        usernameField.returnKeyType = .next
        usernameField.textColor = .label
        usernameField.layer.borderWidth = 1.0
        usernameField.layer.borderColor = UIColor.label.cgColor
        usernameField.layer.masksToBounds = true
        usernameField.layer.cornerRadius = 8.0
        return usernameField
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
    
    private let confirmPasswordField: UITextField = {
        let confirmPasswordField = UITextField()
        confirmPasswordField.placeholder = "Confirm Password..."
        confirmPasswordField.backgroundColor = .secondarySystemBackground
        confirmPasswordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        confirmPasswordField.leftViewMode = .always
        confirmPasswordField.autocorrectionType = .no
        confirmPasswordField.autocapitalizationType = .none
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.returnKeyType = .next
        confirmPasswordField.textColor = .label
        confirmPasswordField.layer.borderWidth = 1.0
        confirmPasswordField.layer.borderColor = UIColor.label.cgColor
        confirmPasswordField.layer.masksToBounds = true
        confirmPasswordField.layer.cornerRadius = 8.0
        return confirmPasswordField
    }()
    
    private let registerButton: UIButton = {
        let registerButton = UIButton()
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 19, weight: .semibold)
        registerButton.layer.borderWidth = 1.0
        registerButton.layer.borderColor = UIColor.link.cgColor
        registerButton.layer.backgroundColor = UIColor.link.cgColor
        registerButton.layer.masksToBounds = true
        registerButton.layer.cornerRadius = 12.0
        return registerButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviewsDelgates()
        addTargets()
        
    }
    
    override func viewDidLayoutSubviews() {
        let size = view.frame.size.width/3
        let fieldWith = view.frame.size.width - 40
        profileView.layer.cornerRadius = size/2
        
        profileView.frame = CGRect(x: view.frame.midX - size/2,
                                   y: view.safeAreaInsets.top + 50,
                                   width: size,
                                   height: size)
        
        usernameField.frame = CGRect(x: 20,
                                     y: profileView.frame.maxY + 55,
                                     width: fieldWith,
                                     height: 52)
        
        emailField.frame = CGRect(x: 20,
                                  y: usernameField.frame.maxY + 10,
                                  width: fieldWith,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 20,
                                     y: emailField.frame.maxY + 10,
                                     width: fieldWith,
                                     height: 52)
        
        confirmPasswordField.frame = CGRect(x: 20,
                                            y: passwordField.frame.maxY + 10,
                                            width: fieldWith,
                                            height: 52)
        
        registerButton.frame = CGRect(x: view.frame.midX - size/2,
                                      y: confirmPasswordField.frame.maxY + 50,
                                      width: size,
                                      height: 45)
        
    }
    
    
    //functions
    private func addSubviewsDelgates() {
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(confirmPasswordField)
        view.addSubview(registerButton)
        view.addSubview(profileView)
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }
    
    private func addTargets() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        profileView.addGestureRecognizer(gesture)
        profileView.isUserInteractionEnabled = true
        
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
    }
    
    private func takePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func choosePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        DispatchQueue.main.async {
            self.profileView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func showErrorAlert(text: String) {
        let alert = UIAlertController(title: "Could not Register User",
                                      message: text,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    //@objc methods
    @objc private func didTapProfileImage() {
        let actionsheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to choose your profile picture?",
                                            preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.takePhoto()
                                            }))
        
        actionsheet.addAction(UIAlertAction(title: "Choose Photo from Library",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.choosePhoto()
                                            }))
        
        actionsheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionsheet.popoverPresentationController?.sourceRect = view.bounds
        actionsheet.popoverPresentationController?.sourceView = view
        present(actionsheet, animated: true, completion: nil)
        
    }
    
    @objc private func didTapRegisterButton() {
        //dismiss keyboards
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        confirmPasswordField.resignFirstResponder()
        
        //check if textfields are filled
        guard let username = usernameField.text?.replacingOccurrences(of: " ", with: ""), !username.isEmpty,
              let email = emailField.text?.replacingOccurrences(of: " ", with: ""), !email.isEmpty,
              let password = passwordField.text?.replacingOccurrences(of: " ", with: ""), !password.isEmpty,
              let confirmPassword = confirmPasswordField.text?.replacingOccurrences(of: " ", with: ""), !confirmPassword.isEmpty else {
            showErrorAlert(text: "Please make sure all fields are filled")
            return
        }
        
        //check if email is an email
        guard email.contains("@") && email.contains(".") else {
            showErrorAlert(text: "Entered Email is invalid")
            return
        }
        
        //check if password fields match
        guard password == confirmPassword else {
            showErrorAlert(text: "Password Fields do not match")
            return
        }
        
        //get profile picture data
        guard let imageData = self.profileView.image?.pngData() else {
            return
        }
        //register user
        spinner.show(in: view)
        AuthManager.shared.registerNewUser(email: email, username: username, password: password) { [weak self] success in
            if success {
                //upload profile picture
                StorageManager.shared.uploadProfilePicture(email: email, imageData: imageData) { result in
                    switch result {
                    case .success(let urlString):
                        UserDefaults.standard.setValue(urlString, forKey: "profilePictureUrl")
                        UserDefaults.standard.setValue(email, forKey: "email")
                        UserDefaults.standard.setValue(username, forKey: "username")
                        print("user succesfully created")
                    case .failure(let error):
                        print("could not upload user profile picture error -> \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        self?.spinner.dismiss()
                        self?.navigationController?.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self?.showErrorAlert(text: "Whoops! Something went wrong...")
                print("could not register user")
            }
        }
        
    }
    


    

}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        } else if textField == confirmPasswordField {
            didTapRegisterButton()
        }
        return true
    }
}
