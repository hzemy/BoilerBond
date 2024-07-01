//
//  AdminPostTableViewCell.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 4/4/21.
//

import UIKit

class AdminPostTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var commentButton: UIButton!

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var firstCommentUN: UILabel!
    @IBOutlet weak var firstCommentText: UILabel!
    var delegate: CellDelegate2?
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var caption: UILabel!
    var id:String? = nil
    var post: Post? = nil 
    var currentUser: User? = nil
    var commentList: [String] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func viewCommentsClicked(_ sender: Any) {
        delegate?.comments(commentList: commentList, aPost: post!)
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
       // delegate?.deletePost(postId: id!)
        delegate?.deletePost(postId: id!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
