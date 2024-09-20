//
//  LoginViewController.swift
//  Makestagram
//
//  Created by Basanta Chaudhuri on 5/19/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseEmailAuthUI
import FirebaseFacebookAuthUI
import FirebaseGoogleAuthUI

typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let authUI = FUIAuth.defaultAuthUI() else { return }
        
        authUI.delegate = self
        
        // Configure Auth UI for email, Facebook, and Google login
        let providers: [FUIAuthProvider] = [FUIEmailAuth(), FUIFacebookAuth(authUI: authUI), FUIGoogleAuth(authUI: authUI)]
        authUI.providers = providers
        
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
    }
}

extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        if let error = error {
            assertionFailure("Error signing in: \(error.localizedDescription)")
            return
        }
        
        guard let user else { return }
        
        UserService.show(forUID: user.uid) { (user) in
            if let user = user {
                // handle existing user
                User.setCurrent(user, writeToUserDefaults: true)
                
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
            } else {
                // handle new user
                self.performSegue(withIdentifier: Constants.Segue.toCreateUsername, sender: self)
            }
        }
    }
}
