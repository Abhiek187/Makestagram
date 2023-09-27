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
    
    var chat: Chat!
    var messages = [Message]()
    var messagesHandle: DatabaseHandle = 0
    var messagesRef: DatabaseReference?
    
//    var outgoingBubbleImageView: JSQMessagesBubbleImage = {
//        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
//            fatalError("Error creating bubble image factory.")
//        }
//
//        let color = UIColor.jsq_messageBubbleBlue()
//        return bubbleImageFactory.outgoingMessagesBubbleImage(with: color)
//    }()
//
//    var incomingBubbleImageView: JSQMessagesBubbleImage = {
//        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
//            fatalError("Error creating bubble image factory.")
//        }
//
//        let color = UIColor.jsq_messageBubbleLightGray()
//        return bubbleImageFactory.incomingMessagesBubbleImage(with: color)
//    }()
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMessagesViewController()
        tryObservingMessages()
    }
    
    func setupMessagesViewController() {
        title = chat.title
        
        // Remove attachment button
        //messageInputBar.contentView.leftBarButtonItem = nil
        
        // Remove avatars
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.textMessageSizeCalculator.messageLabelFont = .preferredFont(forTextStyle: .body)
        }
        
        // Change background color to match theme
//        if #available(iOS 13.0, *) {
//            messagesCollectionView.backgroundColor = .systemBackground
//            inputToolbar.contentView.textView.backgroundColor = .systemBackground
//            inputToolbar.contentView.textView.textColor = .label
//        } else {
//            // Fallback on earlier versions
//        }
        
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

//extension ChatViewController {
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
//    }
//
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
//        return nil
//    }
//
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
//        return messages[indexPath.item].jsqMessageValue
//    }
//
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
//        let message = messages[indexPath.item]
//        let sender = message.sender
//
//        if sender.uid == senderId {
//            return outgoingBubbleImageView
//        } else {
//            return incomingBubbleImageView
//        }
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let message = messages[indexPath.item]
//        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
//        cell.textView?.textColor = (message.sender.uid == senderId) ? .white : .black
//
//        return cell
//    }
//}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
      avatarView.isHidden = true
    }
}

// MARK: - Send Message

extension ChatViewController: InputBarAccessoryViewDelegate {
    func sendMessage(_ message: Message) {
        if chat?.key == nil {
            ChatService.create(from: message, with: chat, completion: { [weak self] chat in
                guard let chat = chat else { return }
                
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
//        finishSendingMessage()
//        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
    }
}
