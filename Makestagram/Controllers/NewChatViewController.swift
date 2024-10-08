//
//  NewChatViewController.swift
//  Makestagram
//
//  Created by Basanta Chaudhuri on 5/23/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import Foundation
import UIKit

class NewChatViewController: UIViewController {
    
    // MARK: - Properties
    
    var following = [User]()
    var selectedUser: User?
    var existingChat: Chat?
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.isEnabled = false
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        
        UserService.following { [weak self] (following) in
            self?.following = following
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
        guard let selectedUser = selectedUser else { return }
        
        sender.isEnabled = false
        ChatService.checkForExistingChat(with: selectedUser) { (chat) in
            sender.isEnabled = true
            self.existingChat = chat
            
            self.performSegue(withIdentifier: "toChat", sender: self)
        }
    }
}

// MARK: - UITableViewDataSource

extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return following.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewChatUserCell") as? NewChatUserCell else { return UITableViewCell() }
        configureCell(cell, at: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: NewChatUserCell, at indexPath: IndexPath) {
        let follower = following[indexPath.row]
        cell.textLabel?.text = follower.username
        
        if let selectedUser = selectedUser, selectedUser.uid == follower.uid {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
}

// MARK: - UITableViewDelegate

extension NewChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        selectedUser = following[indexPath.row]
        cell.accessoryType = .checkmark
        
        nextButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        cell.accessoryType = .none
    }
}

// MARK: - Navigation

extension NewChatViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toChat", let destination = segue.destination as? ChatViewController, let selectedUser = selectedUser {
            let members = [selectedUser, User.current]
            destination.chat = existingChat ?? Chat(members: members)
        }
    }
}
