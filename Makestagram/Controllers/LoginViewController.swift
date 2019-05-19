//
//  LoginViewController.swift
//  Makestagram
//
//  Created by Basanta Chaudhuri on 5/19/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - VC Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        print("login button tapped")
    }
}
