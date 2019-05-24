//
//  ChatService.swift
//  Makestagram
//
//  Created by Basanta Chaudhuri on 5/23/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ChatService {
    static func create(from message: Message, with chat: Chat, completion: @escaping (Chat?) -> Void) {
        var membersDict = [String : Bool]()
        for uid in chat.memberUIDs {
            membersDict[uid] = true
        }
        
        let lastMessage = "\(message.sender.username): \(message.content)"
        chat.lastMessage = lastMessage
        let lastMessageSent = message.timestamp.timeIntervalSince1970
        chat.lastMessageSent = message.timestamp
        
        let chatDict: [String : Any] = ["title" : chat.title,
                                        "memberHash" : chat.memberHash,
                                        "members" : membersDict,
                                        "lastMessage" : lastMessage,
                                        "lastMessageSent" : lastMessageSent]
        
        let chatRef = DatabaseReference.toLocation(.chats(uid: User.current.uid))
        chat.key = chatRef.key
        
        var multiUpdateValue = [String : Any]()
        
        for uid in chat.memberUIDs {
            multiUpdateValue["chats/\(uid)/\(chatRef.key ?? "unknown")"] = chatDict
        }
        
        let messagesRef = DatabaseReference.toLocation(.messages(key: chatRef.key!)).childByAutoId()
        let messageKey = messagesRef.key
        
        multiUpdateValue["messages/\(chatRef.key ?? "unknown")/\(messageKey ?? "unknown")"] = message.dictValue
        
        let rootRef = DatabaseReference.toLocation(.root)
        rootRef.updateChildValues(multiUpdateValue) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            
            completion(chat)
        }
    }
    
    static func checkForExistingChat(with user: User, completion: @escaping (Chat?) -> Void) {
        let members = [user, User.current]
        let hashValue = Chat.hash(forMembers: members)
        
        let chatRef = DatabaseReference.toLocation(.chats(uid: User.current.uid)).childByAutoId()
        
        let query = chatRef.queryOrdered(byChild: "memberHash").queryEqual(toValue: hashValue)
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let chatSnap = snapshot.children.allObjects.first as? DataSnapshot,
                let chat = Chat(snapshot: chatSnap)
                else { return completion(nil) }
            
            completion(chat)
        })
    }
    
    static func sendMessage(_ message: Message, for chat: Chat, success: ((Bool) -> Void)? = nil) {
        guard let chatKey = chat.key else {
            success?(false)
            return
        }
        
        var multiUpdateValue = [String : Any]()
        
        for uid in chat.memberUIDs {
            let lastMessage = "\(message.sender.username): \(message.content)"
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessage"] = lastMessage
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessageSent"] = message.timestamp.timeIntervalSince1970
        }
        
        let messagesRef = DatabaseReference.toLocation(.messages(key: chatKey)).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["messages/\(chatKey)/\(messageKey ?? "unknown")"] = message.dictValue
        
        let rootRef = DatabaseReference.toLocation(.root)
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            
            success?(true)
        })
    }
}
