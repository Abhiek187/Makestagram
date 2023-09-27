//
//  ChatViewController.swift
//  Makestagram
//
//  Created by Basanta Chaudhuri on 5/24/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import Foundation
import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseDatabase

class ChatViewController: MessagesViewController, MessagesLayoutDelegate {
    // MARK: - Properties
    
    var chat: Chat? = nil
    var messages = [Message]()
    var messagesHandle: DatabaseHandle = 0
    var messagesRef: DatabaseReference?
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMessagesViewController()
        tryObservingMessages()
    }
    
    func setupMessagesViewController() {
        title = chat?.title
        
        // Remove avatars
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.textMessageSizeCalculator.messageLabelFont = .preferredFont(forTextStyle: .body)
        }
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    func tryObservingMessages() {
        guard let chatKey = chat?.key else { return }
        
        messagesHandle = ChatService.observeMessages(forChatKey: chatKey, completion: { [weak self] (ref, message) in
            self?.messagesRef = ref
            
            if let message = message {
                self?.messages.append(message)
                //self?.finishReceivingMessage()
                self?.messagesCollectionView.reloadData()
            }
        })
    }
    
    deinit {
        messagesRef?.removeObserver(withHandle: messagesHandle)
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        // Identify current user
        return Sender(senderId: User.current.uid, displayName: User.current.username)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        // Put white text on a blue bubble and dark text on a white bubble
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .mgBlue : .mgLightGray
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
}

// MARK: - Send Message

extension ChatViewController: InputBarAccessoryViewDelegate {
    func sendMessage(_ message: Message) {
        guard let chat else { return }
        
        if chat.key == nil {
            ChatService.create(from: message, with: chat, completion: { [weak self] chat in
                guard let chat else { return }
                
                self?.chat = chat
                
                self?.tryObservingMessages()
            })
        } else {
            ChatService.sendMessage(message, for: chat)
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(content: text)
        sendMessage(message)
        messagesCollectionView.reloadData()
    }
}
