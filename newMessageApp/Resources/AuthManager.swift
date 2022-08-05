//
//  AuthManager.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 05/05/2021.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    
    static let shared = AuthManager()
    
    ///Function to register user
    public func registerNewUser(email: String, username: String, password: String, completion: @escaping(Bool) -> Void) {
        let safeEmail = email.safeDatabaseKey()
        //check to see if user exists
        DatabaseManager.shared.userExists(email: safeEmail) { exists in
            guard !exists else {
                print("user exists")
                return
            }
            
            //insert user into database
            DatabaseManager.shared.insertNewUser(email: email, username: username, password: password) { success in
                guard success else {
                    print("could not insert new user into the database")
                    completion(false)
                    return
                }
                
                DatabaseManager.shared.insertIntoUsersCollection(email: safeEmail, username: username) { success in
                    guard success else {
                        print("could not insert new user into the users collection")
                        completion(false)
                        return
                    }
                    
                    //create user
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        guard authResult != nil, error == nil else {
                            print("could not add user to firebase authentication")
                            completion(false)
                            return
                        }
                        print("sucessfully create new user")
                        completion(true)
                    }
                }
            }
        }
    }
    
    ///Function to login user
    public func loginUser(email: String, password: String, completion: @escaping(Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard authResult != nil, error == nil else {
                print("could not login user")
                completion(false)
                return
            }
            print("logged in user")
            completion(true)
        }
    }
    
    
    ///Function to log out user
    public func logOutUser(completion: @escaping(Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        } catch {
            print("could not log out user")
            completion(false)
            return
        }
    }
    
    
    
}
