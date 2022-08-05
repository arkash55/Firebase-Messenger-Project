//
//  ChatViewController.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 23/05/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVKit
import CoreLocation



struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var profilePicUrl: URL?
}


struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct location: LocationItem {
    var location: CLLocation
    var size: CGSize
}


extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

class ChatViewController: MessagesViewController {
    
    private var messageData = [Message]()
    
    private var sender: Sender? {
        guard let cachedEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeCachedEmail = cachedEmail.safeDatabaseKey()
        return Sender(senderId: safeCachedEmail,
                      displayName: "",
                      profilePicUrl: nil)
    }
    
    public var isNewConversation = false
    private let otherUsersEmail: String
    private let otherUsersName: String
    private var conversationId: String?
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.timeStyle = .long
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    init(otherUsersEmail: String, otherUsersName: String, conversationId: String?) {
        self.otherUsersName = otherUsersName
        self.otherUsersEmail = otherUsersEmail
        self.conversationId = conversationId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        configureNavigationBar()
        configureMessageInputBarButton()
        
        guard let id = conversationId else {
            return
        }
        listenForMessages(conversationId: id)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let id = conversationId else {
            return
        }
        listenForMessages(conversationId: id)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = otherUsersName
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func listenForMessages(conversationId: String) {
        DatabaseManager.shared.listenForMessages(conversationId: conversationId) { [weak self] result in
            switch result {
            case .success(let messageArray):
                DispatchQueue.main.async {
                    self?.messageData = messageArray
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    self?.messagesCollectionView.scrollToLastItem()
                }
            case .failure(_):
                print("failed to listen for messages")
            }
        }
    }
    
    private func configureMessageInputBarButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.addTarget(self, action: #selector(didTapMediaButton), for: .touchUpInside)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    
    private func didTapChoosePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = ["public.image"]
        present(picker, animated: true, completion: nil)
    }
    
    private func didTapTakePhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image"]
        present(picker, animated: true, completion: nil)
    }
    
    private func didTapChooseVideo() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = true
        picker.videoQuality = .typeHigh
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func didTapTakeVideo() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func didTapAttachPhoto() {
        let actionSheet = UIAlertController(title: "How would you like to attach a photo?",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.didTapTakePhoto()
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose from library",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.didTapChoosePhoto()
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        actionSheet.popoverPresentationController?.sourceView = view
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func didTapAttachVideo() {
        let actionSheet = UIAlertController(title: "How would you like to attach a video?",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take Video",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.didTapTakePhoto()
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose from library",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.didTapChooseVideo()
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        actionSheet.popoverPresentationController?.sourceView = view
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc private func didTapMediaButton() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.didTapAttachPhoto()
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Video",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.didTapAttachVideo()
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Location",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.configureLocationMessages()
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = view
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    private func configureLocationMessages() {
        let vc = LocationViewController(coordinates: nil)
        vc.title = "Location"
        vc.isPickable = true
        navigationController?.pushViewController(vc, animated: true)
        
        guard let messageId = createMessageId(),
              let conversationId = conversationId,
              let sender = sender else {
            return
        }
        
        vc.completion = { coordinates in
            let latitude = coordinates.latitude
            let longitude = coordinates.longitude
            
            let locationItem = location(location: CLLocation(latitude: latitude, longitude: longitude),
                                        size: .zero)
            
            let locationMessage = Message(sender: sender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .location(locationItem))
            
            DatabaseManager.shared.sendMessage(otherUserEmail: self.otherUsersEmail, otherUsersName: self.otherUsersName, conversationId: conversationId, message: locationMessage) { [weak self] success in
                if success {
                    self?.listenForMessages(conversationId: conversationId)
                } else {
                    print("failed to send location message")
                }
            }
            
        }
        
    }


}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageId = createMessageId(),
              let sender = sender,
              let conversationId = conversationId else {
            print("failed to unwrap whilst sending photo image")
            return
        }
        
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let photoMessageData = selectedImage.pngData() else {
                return
            }
            
            StorageManager.shared.uploadPhotoMessage(messageId: messageId, data: photoMessageData) { result in
                switch result {
                case .success(let photoUrlString):
                    guard let photoUrl = URL(string: photoUrlString),
                          let placeholderImage = UIImage(systemName: "plus") else {
                        return
                    }
                    
                  let mediaItem = Media(url: photoUrl,
                                        image: nil,
                                        placeholderImage: placeholderImage,
                                        size: .zero)
                    
                  let messageData = Message(sender: sender,
                                            messageId: messageId,
                                            sentDate: Date(),
                                            kind: .photo(mediaItem))
                    
                    DatabaseManager.shared.sendMessage(otherUserEmail: self.otherUsersEmail, otherUsersName: self.otherUsersName, conversationId: conversationId, message: messageData) { [weak self] success in
                        if success {
                            self?.listenForMessages(conversationId: conversationId)
                        } else  {
                            print("failed to send photo message")
                        }
                    }
                case .failure(let error):
                    print(error)
                    print("failed to upload photo message")
                }
            }
        } else if let selectedVideoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            StorageManager.shared.uploadVideoMessage(videoUrl: selectedVideoUrl, messageId: messageId) { result in
                switch result {
                case .success(let videoUrl):
                    guard let placeholderImage = UIImage(systemName: "plus") else {
                        return
                    }
                    
                    let mediaItem = Media(url: videoUrl,
                                          image: nil,
                                          placeholderImage: placeholderImage,
                                          size: .zero)
                    
                    let videoMessageData = Message(sender: sender,
                                                   messageId: messageId,
                                                   sentDate: Date(),
                                                   kind: .video(mediaItem))
                    
                    DatabaseManager.shared.sendMessage(otherUserEmail: self.otherUsersEmail, otherUsersName: self.otherUsersName, conversationId: conversationId, message: videoMessageData) { [weak self] success in
                        if success {
                            self?.listenForMessages(conversationId: conversationId)
                        } else {
                            print("failed to send video messaage")
                        }
                    }
                    
                case .failure(_):
                    print("failed to send upload video message")
                }
            }
        }
        
        

        
        
            
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK: -- MESSAGE COLLECTIONVIEW STUFF
extension ChatViewController: MessagesLayoutDelegate, MessagesDisplayDelegate, MessagesDataSource {
    func currentSender() -> SenderType {
        guard let cachedSender = sender else {
            return Sender(senderId: "", displayName: "", profilePicUrl: nil)
        }
        return cachedSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let message = messageData[indexPath.section]
        return message
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageData.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let mediaItem):
            guard let photoUrl = mediaItem.url else {
                return
            }
            imageView.sd_setImage(with: photoUrl, completed: nil)
        default:
            break
        }
        
    }
    
}


//MARK: -- CONFIGURING PHOTO, VIDEO AND LOCATION MESSAGES
extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messageData[indexPath.section]
        switch message.kind {
        case .photo(let mediaItem):
            guard let photoUrl = mediaItem.url else {
                return
            }
            let vc = PhotoMessageViewController(photoUrl: photoUrl)
            vc.title = "Photo"
            vc.navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.pushViewController(vc, animated: true)
        case .video(let mediaItem):
            guard let videoUrl = mediaItem.url else {
                return
            }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            vc.title = "Video"
            present(vc, animated: true) {
                vc.player?.play()
            }
        default:
            break
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messageData[indexPath.section]
        switch message.kind {
        case .location(let locationItem):
            let latitude = locationItem.location.coordinate.latitude
            let longitude = locationItem.location.coordinate.longitude
            let messageCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let vc = LocationViewController(coordinates: messageCoordinates)
            vc.title = "Sent Location"
            vc.isPickable = false
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    

    
}



//MARK: -- SENDING A TEXT MESSAGE
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        guard let safeSender = sender,
              let messageId = createMessageId(),
              let cachedUsername = UserDefaults.standard.value(forKey: "username") as? String else {
            print("failed to unwrap sender and/or messageId")
            return
        }
        
        //check if conversation is new
        //send message
        let message = Message(sender: safeSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        
            
        if isNewConversation {
            //create new conversation database function
            let conversationId = "conversationId_\(messageId)"
            self.conversationId = conversationId
            
            DatabaseManager.shared.createNewConversation(sendersName: cachedUsername, otherUsersEmail: otherUsersEmail, otherUsersName: otherUsersName, conversationId: conversationId, firstMessage: message) { [weak self] success in
                if success {
                    self?.isNewConversation = false
                    self?.listenForMessages(conversationId: conversationId)
                } else {
                    print("failed to create new conversation")
                }
            }
            
        } else {
            //send message to existing conversation function
            guard let conversationId = conversationId else {
                return 
            }
            
            DatabaseManager.shared.sendMessage(otherUserEmail: otherUsersEmail, otherUsersName: otherUsersName, conversationId: conversationId, message: message) { [weak self] success in
                if success {
                    self?.listenForMessages(conversationId: conversationId)
                } else {
                    print("failed to send message")
                }
            }
        }
    }
    
    private func createMessageId() -> String? {
        //messageId = cachedUserSafeEmail_otherUserSafeEmail_date
        guard let cachedEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let cachedSafeEmail = cachedEmail.safeDatabaseKey()
        let dateString = Self.dateFormatter.string(from: Date())
        let messageId = "\(cachedSafeEmail)_\(otherUsersEmail)_\(dateString)"
        return messageId
    }

}


