//
//  UserTableViewCell.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 4/3/21.
//

import UIKit
import FirebaseAuth
import BRYXBanner
import FirebaseFirestore
import CodableFirebase
import FirebaseStorage

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var username: UILabel!
    var db: Firestore!
    var associatedEmail:String? = nil
    var createdPosts: [Post] = []
    var delegate: CellDelegateDelete?
    @IBAction func deleteClicked(_ sender: Any) {
        //delete user
        User.getUser(email: username.text!, completion: afterGetUser)
    }
    
    func afterGetUser(theUser: User) {
        User.deleteUser(user: theUser)
        updateUI()
    }
    func updateUI() {
        delegate?.update()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
