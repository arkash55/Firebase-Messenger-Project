//
//  DatabaseManager.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 05/05/2021.
//

import Foundation
import FirebaseDatabase
import MessageKit
import CoreLocation

public typealias RetrieveUserInfomation = (Result<Any, Error>) -> Void
public typealias GetAllUsers = (Result<[[String: String]], Error>) -> Void


final class DatabaseManager {
    
    private let database = Database.database().reference()
    static let shared = DatabaseManager()
    
    ///Function to check if user exists
    public func userExists(email: String, completion: @escaping((Bool) -> Void)) {
        let safeEmail = email.safeDatabaseKey()
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? [[String: String]] != nil else {
                completion(false)
                return
            }
            print("user already exists")
            completion(true)
        }
    }
    
    ///Function to insert user into database
    public func insertNewUser(email: String, username: String, password: String, completion: @escaping((Bool) -> Void)) {
        let safeEmail = email.safeDatabaseKey()
        database.child(safeEmail).setValue(["email": email, "username": username]) { error, _ in
            guard error == nil else {
                print("failed to insert user node")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    ///Function to insert user into users collection
    public func insertIntoUsersCollection(email: String, username: String, completion: @escaping((Bool) -> Void)) {
        let safeEmail = email.safeDatabaseKey()
        let newElement: [String: Any] = ["email": safeEmail, "username": username]
        
        database.child("users/").observeSingleEvent(of: .value) { [weak self] snapshot in
            //collection exists
            if var usersCollection = snapshot.value as? [[String: Any]] {
                usersCollection.append(newElement)
                self?.database.child("users/").setValue(usersCollection, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        print("could not insert into users collection (collection exists)")
                        completion(false)
                        return
                    }
                    completion(true)
                })
            } else {
                self?.database.child("users/").setValue([newElement], withCompletionBlock: { error, _ in
                    guard error == nil else {
                        print("could not insert into users collection (collection does not exist)")
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
        }
    }
    
    
    ///function to get information at a specific path
    public func retrieveUserInfo(path: String, completion: @escaping RetrieveUserInfomation) {
        database.child(path).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value  else {
                print("failed to retrieve user info")
                completion(.failure(MyErrors.failedToGetData))
                return
            }
            completion(.success(value))
        }
    }
    
    
    ///Function to get all users
    public func getAllUsers(completion: @escaping GetAllUsers) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(MyErrors.failedToGetData))
                return
            }
            completion(.success(value))
        }
    }
}


extension DatabaseManager {
    
    ///function to create a new conversation and send a message
    public func createNewConversation(sendersName: String, otherUsersEmail: String, otherUsersName: String, conversationId: String, firstMessage: Message, completion: @escaping(Bool) -> Void) {
        //this involves two parts
        // - creating a root conversation node that holds all the messages sent within the conversation
        // - a conversation node for each user, which holds the latest message and other simple data of each conversation they are apart of
        
        guard let cachedEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeCachedEmail = cachedEmail.safeDatabaseKey()
        
        let messageId = firstMessage.messageId
        let sentDate = ChatViewController.dateFormatter.string(from: firstMessage.sentDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(let mediaItem):
            guard let photoUrlString = mediaItem.url?.absoluteString else {
                return
            }
            message = photoUrlString
        case .video(let mediaItem):
            guard let videoUrlString = mediaItem.url?.absoluteString else {
                return
            }
            message = videoUrlString
        case .location(let locationItem):
            let latitude = locationItem.location.coordinate.latitude
            let longitude = locationItem.location.coordinate.longitude
            
            let locationMessage = "\(latitude),\(longitude),"
            message = locationMessage
            
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let conversationMessageData: [String: Any] = [
            "senderEmail": safeCachedEmail,
            "otherUsersEmail": otherUsersEmail,
            "content": message,
            "messageId": messageId,
            "type":firstMessage.kind.messageKindString,
            "date": sentDate,
            "isRead": false
        ]
        
        let senderMessageData: [String: Any] = [
            "conversationId": conversationId,
            "senderEmail": safeCachedEmail,
            "otherUsersEmail": otherUsersEmail,
            "sendersName": sendersName,
            "otherUsersName": otherUsersName,
            "latestMessage":[
                "message": message,
                "date": sentDate,
                "isRead": false
            ]
        ]
        
        let otherUsersMessageData: [String: Any] = [
            "conversationId": conversationId,
            "senderEmail": otherUsersEmail,
            "otherUsersEmail": safeCachedEmail,
            "sendersName": otherUsersName,
            "otherUsersName": sendersName,
            "latestMessage":[
                "message": message,
                "date": sentDate,
                "isRead": false
            ]
        ]
        
        createRootConversationNode(otherUsersEmail: otherUsersEmail, conversationId: conversationId, conversationMessageData: conversationMessageData) { [weak self] success in
            if success {
                self?.appendToUserConversationKey(usersEmail: safeCachedEmail, messageData: senderMessageData, completion: { [weak self] success in
                    if success {
                        self?.appendToUserConversationKey(usersEmail: otherUsersEmail, messageData: otherUsersMessageData, completion: completion)
                    } else {
                        print("could not append message data to users conversation key")
                    }
                })
            } else {
                print("could not create root conversation node")
            }
        }
    }
    
    
    
    ///function to create a root conversation node for a new conversation
    private func createRootConversationNode(otherUsersEmail: String, conversationId: String, conversationMessageData: [String: Any], completion: @escaping(Bool) -> Void) {
        database.child(conversationId).setValue(["messages":[conversationMessageData]]) { error, _ in
            guard error == nil else {
                print("could not create conversation root node")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    ///function to append a new conversation to the individual users conversations node
    private func appendToUserConversationKey(usersEmail: String, messageData: [String: Any], completion: @escaping(Bool) -> Void) {
        let safeEmail = usersEmail.safeDatabaseKey()
        
        database.child("\(safeEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
            if var conversationsNode = snapshot.value as? [[String: Any]] {
                //conversations key exists (append)
                conversationsNode.append(messageData)
                self?.database.child("\(safeEmail)/conversations").setValue(conversationsNode, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                })
            } else {
                //conversation key does not exist, (create)
                self?.database.child("\(safeEmail)/conversations").setValue([messageData]) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    
    ///listen for and retrieve all user conversations
    public func listenForConversations(email: String, completion: @escaping(Result<[ConversationModel], Error>) -> Void) {
        let safeEmail = email.safeDatabaseKey()
        database.child("\(safeEmail)/conversations").observe(.value) { snapshot in
            guard let conversations = snapshot.value as? [[String: Any]] else {
                completion(.failure(MyErrors.failedToGetData))
                print("failed to get all users conversations")
                return
            }
            
            let mappedConversations: [ConversationModel] = conversations.compactMap { dictionary in
                guard let conversationId = dictionary["conversationId"] as? String,
                      let otherUsersEmail = dictionary["otherUsersEmail"] as? String,
                      let otherUsersName = dictionary["otherUsersName"] as? String,
                      let senderEmail = dictionary["senderEmail"] as? String,
                      let senderName = dictionary["sendersName"] as? String,
                      let latestMessage = dictionary["latestMessage"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["isRead"] as? Bool else {
                    print("failed to unwrap conversation mappings")
                    completion(.failure(MyErrors.failedToGetData))
                    return nil
                }
                
                let latestMessageObject = LatestMessage(message: message,
                                                        date: date,
                                                        isRead: isRead)
                
                
                let finalConversationModel = ConversationModel(conversationId: conversationId,
                                                               otherUsersEmail: otherUsersEmail,
                                                               otherUsersName: otherUsersName,
                                                               latestMessage: latestMessageObject)
                return finalConversationModel
            }
            
            completion(.success(mappedConversations))
            
        }
    }
    
    
    ///function to listen to and retrieve all messages within a conversation
    public func listenForMessages(conversationId: String, completion: @escaping(Result<[Message], Error>)-> Void) {
        database.child("\(conversationId)/messages").observe(.value) { snapshot in
            guard let messagesArray = snapshot.value as? [[String: Any]] else {
                completion(.failure(MyErrors.failedToGetData))
                print("failed to retrieve all messages")
                return
            }
            let mappedMessages: [Message] = messagesArray.compactMap { dictionary in
                guard let content = dictionary["content"] as? String,
                      let messageId = dictionary["messageId"] as? String,
                      let otherUsersEmail = dictionary["otherUsersEmail"] as? String,
                      let senderEmail = dictionary["senderEmail"] as? String,
                      let type = dictionary["type"] as? String,
                      let isRead = dictionary["isRead"] as? Bool,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                    print("failed to unwrap")
                    completion(.failure(MyErrors.failedToGetData))
                    return nil
                }
                
                guard let photoUrl = URL(string: content),
                      let placholderImage = UIImage(systemName: "plus"),
                      let videoUrl = URL(string: content) else {
                    return nil
                }
                
                let photoMediaItem = Media(url: photoUrl,
                                      image: nil,
                                      placeholderImage: placholderImage,
                                      size: CGSize(width: 250, height: 250))
                
                
                let videoMediaItem = Media(url: videoUrl,
                                           image: nil,
                                           placeholderImage: placholderImage,
                                           size: CGSize(width: 300, height: 300))
                

                
                var kind: MessageKind?
                if type == "text" {
                    kind = .text(content)
                } else if type == "photo" {
                    kind = .photo(photoMediaItem)
                } else if type == "video" {
                    kind = .video(videoMediaItem)
                } else if type == "location" {
                    let locationComponents = content.components(separatedBy: ",")
                    guard let latitude = Double(locationComponents[0]),
                          let longitutde = Double(locationComponents[1]) else {
                        print("failed to split components")
                        return nil
                    }
                    
                    
                    let locationItem = location(location: CLLocation(latitude: latitude, longitude: longitutde),
                                                size: CGSize(width: 250,
                                                             height: 250))
                    kind = .location(locationItem)
                }
                
                guard let finalKind = kind else {
                    print("failed to unwrap kind")
                    return nil                }
                
                let senderObject = Sender(senderId: senderEmail,
                                          displayName: "",
                                          profilePicUrl: nil)
                
                let finalMessage = Message(sender: senderObject,
                                           messageId: messageId,
                                           sentDate: date,
                                           kind: finalKind)
                return finalMessage
            }
            completion(.success(mappedMessages))
        }
    }
    
    
    ///function to send a message
    public func sendMessage(otherUserEmail: String, otherUsersName: String, conversationId: String, message: Message, completion:@escaping(Bool) -> Void) {
        
        guard let cachedEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let cachedUsersName = UserDefaults.standard.value(forKey: "username") as? String else {
            completion(false)
            return
        }
        let safeCachedEmail = cachedEmail.safeDatabaseKey()
        let sentDate = ChatViewController.dateFormatter.string(from: message.sentDate)
        
        var messageContent = ""
        
        switch message.kind {
        case .text(let messageText):
            messageContent = messageText
        case .photo(let mediaItem):
            guard let photoUrlString = mediaItem.url?.absoluteString else {
                return
            }
            messageContent = photoUrlString
        case .video(let mediaItem):
            guard let videoUrlString = mediaItem.url?.absoluteString else {
                return
            }
            messageContent = videoUrlString
        case .location(let locationItem):
            let latitude = locationItem.location.coordinate.latitude
            let longitude = locationItem.location.coordinate.longitude
            
            let locationMessage = "\(latitude),\(longitude),"
            messageContent = locationMessage
        default:
            break

        }
        
        let conversationNodeData: [String: Any] = [
            "content": messageContent,
            "date": sentDate,
            "isRead": false,
            "messageId": message.messageId,
            "otherUsersEmail": otherUserEmail,
            "senderEmail": safeCachedEmail,
            "type": message.kind.messageKindString
        ]
        
        let cachedUserMessageData: [String: Any] = [
            "conversationId": conversationId,
            "senderEmail": safeCachedEmail,
            "otherUsersEmail": otherUserEmail,
            "sendersName": cachedUsersName,
            "otherUsersName": otherUsersName,
            "latestMessage":[
                "message": messageContent,
                "date": sentDate,
                "isRead": false
            ]
        ]
        
        let otherUserMessageData: [String: Any] = [
            "conversationId": conversationId,
            "senderEmail": otherUserEmail,
            "otherUsersEmail": safeCachedEmail,
            "sendersName": otherUsersName,
            "otherUsersName": cachedUsersName,
            "latestMessage":[
                "message": messageContent,
                "date": sentDate,
                "isRead": false
            ]
        ]
        
        
        //append message to conversation node
        appendToConversationNode(conversationId: conversationId, messageData: conversationNodeData) { [weak self] success in
            if success {
                //update each users conversation collection
                self?.updateConversationCollection(email: safeCachedEmail, conversationId: conversationId, newMessage: cachedUserMessageData,  completion: { [weak self] success in
                    if success {
                        self?.updateConversationCollection(email: otherUserEmail, conversationId: conversationId, newMessage: otherUserMessageData, completion: completion)
                    } else {
                        print("failed to update user conversation collection")
                    }
                })
            } else {
                print("could not append to conversationNode")
            }
        }
        
        
    }
    
    ///function to append message to conversationNode
    private func appendToConversationNode(conversationId: String, messageData: [String: Any], completion: @escaping(Bool) -> Void) {
        database.child("\(conversationId)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var messagesArray = snapshot.value as? [[String: Any]] else {
                completion(false)
                print("failed to get messageArray")
                return
            }
            messagesArray.append(messageData)
            self?.database.child("\(conversationId)/messages").setValue(messagesArray, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    print("failed to append to conversation Node")
                    return
                }
                completion(true)
            })
        }
    }
    
    
    ///function to update a users conversations latest message
    private func updateConversationCollection(email: String, conversationId: String, newMessage: [String: Any], completion: @escaping(Bool) -> Void) {
        let safeEmail = email.safeDatabaseKey()
        
        //first check if user has a conversations child node
        //if no conversation node, create and append data
        //if conversation node exists, check if the correct conversation dictionary exists
        //if doesnt exist append it
        //if exists update the dictionary's latest message sub dictionary
        
        database.child(safeEmail).observeSingleEvent(of: .value) { [weak self] snapshot in
            
            var finalCollection: [[String: Any]]?
            
            if var conversationsCollection = snapshot.value as? [[String: Any]] {
                //node exists, update it
                //find the correct dictionary
                var conversationDictionary: [String: Any]?
                var position = 0
                
                for dictionary in conversationsCollection {
                    position += 1
                    if dictionary["conversationId"] as? String == conversationId {
                        conversationDictionary = dictionary
                        break
                    }
                }
                
                if conversationDictionary != nil {
                    //update latest message
                    guard var finalDictionary = conversationDictionary else {
                        print("failed to unwrap final dictionary")
                        return
                    }
                    finalDictionary["latestMessage"] = newMessage["latestMessage"]
                    conversationsCollection[position] = finalDictionary
                    finalCollection = conversationsCollection
                } else {
                    //append new dictionary
                    conversationsCollection.append(newMessage)
                    finalCollection = conversationsCollection
                }
                
                self?.database.child("\(safeEmail)/conversations").setValue(finalCollection, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        print("could not set update latest message for user")
                        return
                    }
                    completion(true)
                })
                
            } else {
                //conversation node does not exist
                self?.database.child("\(safeEmail)/conversations").setValue([newMessage], withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        print("failed to create new conversation node when sending in a pre existing conversation")
                        return
                    }
                    completion(true)
                })
            }
        }
    }
    
    
    ///function to check if conversation exists and pass back conversationId
    public func checkIfConversationExists(otherUsersEmail: String, completion: @escaping(Result<String, Error>) -> Void) {
        guard let cachedEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeCachedEmail = cachedEmail.safeDatabaseKey()
        let otherUserSafeEmail = otherUsersEmail.safeDatabaseKey()
        
        database.child("\(safeCachedEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
            guard let conversationArray = snapshot.value as? [[String: Any]] else {
                completion(.failure(MyErrors.failedToGetData))
                return
            }
            var targetDictionary: [String: Any]?
            
            for conversationDictionary in conversationArray {
                if let dictionaryEmail = conversationDictionary["otherUsersEmail"] as? String, dictionaryEmail == otherUserSafeEmail {
                    targetDictionary = conversationDictionary
                    break
                }
            }
            
            if let targetDictionary = targetDictionary {
                guard let conversationId = targetDictionary["conversationId"] as? String else {
                    return
                }
                completion(.success(conversationId))
            } else {
                completion(.failure(MyErrors.failedToGetData))
            }
            
        }
    }
    
    
    ///function to delete conversation from a users conversation collection
    public func deleteConversation(email: String, conversationId: String, completion: @escaping(Bool) -> Void) {
        let safeUserEmail = email.safeDatabaseKey()
        database.child("\(safeUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var conversationCollection = snapshot.value as? [[String: Any]] else {
                print("failed to get conversationsArray")
                completion(false)
                return
            }
            var postion = 0

            for conversationDictionary in conversationCollection {
                if let targetConversationId = conversationDictionary["conversationId"] as? String, targetConversationId == conversationId {
                    break
                }
                postion += 1
            }
            
            conversationCollection.remove(at: postion)
            self?.database.child("\(safeUserEmail)/conversations").setValue(conversationCollection, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    print("failed to set new conversation collection")
                    return
                }
                completion(true)
            })
            
        }
    }
    
    
}


//    self?.database.child("\(safeUserEmail)/conversations").setValue(conversationCollection, withCompletionBlock: { error, _ in
//        guard error == nil else {
//            completion(false)
//            print("failed to set new conversation collection")
//            return
//        }
//        completion(true)
//    })
//
