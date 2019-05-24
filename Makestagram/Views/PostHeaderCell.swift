//
//  PostHeaderCell.swift
//  Makestagram
//
//  Created by Basanta Chaudhuri on 5/21/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import Foundation
import UIKit

class PostHeaderCell: UITableViewCell {
    
    static let height: CGFloat = 54
    var didTapOptionsButtonForCell: ((PostHeaderCell) -> Void)?
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        didTapOptionsButtonForCell?(self)
    }
}
