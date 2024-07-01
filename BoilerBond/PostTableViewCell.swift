//
//  PostTableViewCell.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 3/12/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner
class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var viewAllCommentsButton: UIButton!
    @IBOutlet weak var savePostButton: UIButton!
    @IBOutlet weak var commentUsername: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var commentPostButton: UIButton!
    @IBOutlet weak var commentTextbox: UITextField!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    var currentUser: User? = nil
    var id: String? = nil
    var post: Post? = nil
    var commentList: [String] = []
    var delegate: CellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        User.getCurrentUser(completion: getUser)
    }
    
    func getUser(currentUser: User) {
        self.currentUser = currentUser
    }
    func showAndFocus(banner : Banner){
        banner.show(duration: 3)
    }
    @IBAction func postCommentClicked(_ sender: Any) {
        let empty = Banner(title: "Enter Text Into Comment", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        empty.dismissesOnTap = true
        if ((commentTextbox.text?.isEmpty) == true){
            self.showAndFocus(banner: empty)
            return
        }else{
            //currentUser?.addComment(postId: postID, comment: commentTextbox.text!)
            let publishedComment = "\(currentUser!.email): \(commentTextbox.text!)"
            let db = Firestore.firestore()
            post?.addComment(comment: publishedComment)
            commentList = post!.comments
            let postRef = db.collection("posts").document(id!)
            let dataToWrite = try! FirestoreEncoder().encode(post)
            db.collection("posts").document(post!.postId).setData(dataToWrite) { error in
                if (error != nil) {
                    print("error writing post to database in comment post")
                    print("error: \(String(describing: error))")
                    self.commentTextbox.text = ""
                    return
                } else {
                    print("success writing post to database in comment post")
                    self.commentTextbox.text = ""
                    return
                }
            }
            
        }
    }
    @IBAction func viewAllCommentsClicked(_ sender: Any) {
        delegate?.comments(commentList: commentList, aPost: post!)
    }
    @IBAction func likePostClicked(_ sender: Any) {
        delegate?.likePost(postId: id!)
        
    }
    @IBAction func savePostClicked(_ sender: Any) {
        delegate?.savePost(postId: id!)
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        //add delete post to cell delegate in feedViewController
        delegate?.deletePost(postId: id!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
