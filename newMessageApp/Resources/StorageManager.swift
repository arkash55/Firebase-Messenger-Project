//
//  StorageManager.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 05/05/2021.
//

import Foundation
import FirebaseStorage

enum MyErrors: Error {
    case failedToUploadData
    case failedToRetrieveUrl
    case failedToGetData
}

public typealias UploadProfilePictureCompletion = (Result<String, Error>) -> Void
public typealias RetrieveDownloadUrl = (Result<URL, Error>) -> Void


final class StorageManager {
    
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    
    ///Function to upload user profile picture
    public func uploadProfilePicture(email: String, imageData: Data, completion: @escaping UploadProfilePictureCompletion) {
        let safeEmail = email.safeDatabaseKey()
        let fileName = "\(safeEmail)_profile_picture.png"
        
        storage.child(fileName).putData(imageData, metadata: nil) { [weak self] _, error in
            guard error == nil else {
                print("failed to upload data")
                completion(.failure(MyErrors.failedToUploadData))
                return
            }
            //get download url
            self?.storage.child(fileName).downloadURL(completion: { url, error in
                guard let imageUrl = url, error == nil else {
                    print("failed to retrieve download url")
                    completion(.failure(MyErrors.failedToRetrieveUrl))
                    return
                }
                let urlString = imageUrl.absoluteString
                completion(.success(urlString))
                
            })
        }
    }
    
    
    ///Function to get users profile picture url
    public func retrieveProfilePictureUrl(email: String, completion: @escaping RetrieveDownloadUrl) {
        let safeEmail = email.safeDatabaseKey()
        let path = "\(safeEmail)_profile_picture.png"
        
        storage.child(path).downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(MyErrors.failedToRetrieveUrl))
                return
            }
            completion(.success(url))
        }
        
    }
    
    
    ///function to upload photo message
    public func uploadPhotoMessage(messageId: String, data: Data, completion: @escaping(Result<String, Error>) -> Void) {
        let photoPath: String = "photo_message_\(messageId).png"
        storage.child("messages_photos/\(photoPath)").putData(data, metadata: nil) { [weak self] _, error in
            guard error == nil else {
                print("failed to put photo message data")
                completion(.failure(MyErrors.failedToUploadData))
                return
            }
            
            self?.storage.child("messages_photos/\(photoPath)").downloadURL(completion: { url, error in
                guard let imageUrl = url, error == nil else {
                    completion(.failure(MyErrors.failedToRetrieveUrl))
                    print("failed to get photo message url")
                    return
                }
                let urlString = imageUrl.absoluteString
                completion(.success(urlString))
            })
            
            
        }
    }
    
    
    ///function to upload a video message
    public func uploadVideoMessage(videoUrl: URL, messageId: String, completion: @escaping(Result<URL, Error>) -> Void) {
        let videoPath = "video_message_\(messageId).mov"
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        guard let videoData = NSData(contentsOf: videoUrl) as Data? else {
            completion(.failure(MyErrors.failedToGetData))
            print("failed to conver video url to data")
            return
        }
        
        storage.child("messages_videos/\(videoPath)").putData(videoData, metadata: metadata) { [weak self] _, error in
            guard error == nil else {
                completion(.failure(MyErrors.failedToUploadData))
                print("failed to put video data")
                return
            }
            self?.storage.child("messages_videos/\(videoPath)").downloadURL(completion: { url, error in
                guard let videoUrl = url, error == nil else {
                    completion(.failure(MyErrors.failedToRetrieveUrl))
                    return
                }
                completion(.success(videoUrl))
            })
        }
    }
    
    
    
}
