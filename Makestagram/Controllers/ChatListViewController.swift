//
//  ChatListViewController.swift
//  Makestagram
//
//  Created by Basanta Chaudhuri on 5/23/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class ChatListViewController: UIViewController {
    
    // MARK: - Properties
    
    var chats = [Chat]()
    var userChatsHandle: DatabaseHandle = 0
    var userChatsRef: DatabaseReference?
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 71
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        
        userChatsHandle = UserService.observeChats { [weak self] (ref, chats) in
            self?.userChatsRef = ref
            self?.chats = chats
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    deinit {
        userChatsRef?.removeObserver(withHandle: userChatsHandle)
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }
}

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        
        let chat = chats[indexPath.row]
        cell.titleLabel.text = chat.title
        cell.lastMessageLabel.text = chat.lastMessage
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toChat", sender: self)
    }
}

// MARK: - Navigation

extension ChatListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toChat",
            let destination = segue.destination as? ChatViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            
            destination.chat = chats[indexPath.row]
        }
    }
}
