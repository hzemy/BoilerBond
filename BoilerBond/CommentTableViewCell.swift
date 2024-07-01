//
//  CommentTableViewCell.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 4/9/21.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var comment: UILabel!
    var delegate: CellDelegate3?
    var thePost: Post? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func deleteClicked(_ sender: Any) {
        //delete comment
        var theComment = username.text!.components(separatedBy: ":")[1]
        let trimmed = theComment.trimmingCharacters(in: .whitespacesAndNewlines)
        print("the comment:" + username.text!)
        print("the post: " + thePost!.postId)
        thePost?.deleteComment(comment: username.text!)
        reloadInputViews()
        //print(thePost!.comments)
        delegate?.setComms(commentsNew: thePost!.comments)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
