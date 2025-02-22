//
//  Message.swift
//  Makestagram
//
//  Created by Basanta Chaudhuri on 5/23/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MessageKit

class Message: MessageType {
    // MARK: - Properties
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var content: String
    
    var dictValue: [String : Any] {
        let userDict = ["username" : sender.displayName,
                        "uid" : sender.senderId]
        
        return ["sender" : userDict,
                "content" : content,
                "timestamp" : sentDate.timeIntervalSince1970]
    }
    
    // MARK: - Init
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["timestamp"] as? TimeInterval,
            let userDict = dict["sender"] as? [String : Any],
            let uid = userDict["uid"] as? String,
            let username = userDict["username"] as? String
            else { return nil }
        
        self.sender = Sender(senderId: uid, displayName: username)
        self.messageId = snapshot.key
        self.sentDate = Date(timeIntervalSince1970: timestamp)
        self.kind = .text(content)
        self.content = content
    }
    
    init(content: String) {
        self.sender = Sender(senderId: User.current.uid, displayName: User.current.username)
        self.messageId = UUID().uuidString
        self.sentDate = Date()
        self.kind = .text(content)
        self.content = content
    }
}
