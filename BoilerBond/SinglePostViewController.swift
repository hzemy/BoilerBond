//
//  SinglePostViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 4/11/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner

class SinglePostViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var savePost: UIButton!
    @IBOutlet weak var post: UIButton!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var commentUsername: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var viewAllComments: UIButton!
    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var commentTextbox: UITextField!
    @IBOutlet weak var caption: UILabel!
    var postID: String = ""
    var usernameText: String = ""
    var postCaptionText: String = ""
    var postTitleText: String = ""
    var DisplayedCommentUserNameText: String = ""
    var DisplayedCommentTextText: String = ""
    var courseNameText: String = ""
    var commentsList: [String] = []
    var currentPost: Post? = nil
    var currentUser: User? = nil
    @IBAction func savePostClicked(_ sender: Any) {
        currentUser?.toggleSavedPost(postId: postID)
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
            currentPost?.addComment(comment: publishedComment)
            commentsList = currentPost!.comments
            let postRef = db.collection("posts").document(postID)
            let dataToWrite = try! FirestoreEncoder().encode(currentPost)
            db.collection("posts").document(currentPost!.postId).setData(dataToWrite) { error in
                if (error != nil) {
                    print("error writing post to database in create post")
                    print("error: \(String(describing: error))")
                    self.commentTextbox.text = ""
                    return
                } else {
                    print("success writing post to database in create post")
                    self.commentTextbox.text = ""
                    return
                }
            }
            
        }
    }
    @IBAction func likePostClicked(_ sender: Any) {
        currentUser?.toggleLikedPost(postId: postID)
    }
    @IBAction func viewAllCommentsClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "toComment", sender: self)
        
    }
    func getUser(currentUser: User) {
        self.currentUser = currentUser
    }
    override func viewDidLoad() {
        User.getCurrentUser(completion: getUser)
        username.text = usernameText
        courseName.text = courseNameText
        caption.text = postCaptionText
        postTitle.text = postTitleText
        commentUsername.text = DisplayedCommentUserNameText
        commentText.text=DisplayedCommentTextText
        delete.isHidden = true
        let ref2 = Storage.storage().reference(withPath: "media/" + usernameText + "/" + "profile.jpeg")
        ref2.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                self.profilePicture?.image = UIImage(data: data!)
            }
        }
        super.viewDidLoad()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is CommentViewController
        {
            let vc = segue.destination as? CommentViewController
            vc?.comments = commentsList
            vc?.post = currentPost!
            segue.destination.presentationController?.delegate = self;
            
        }
    }
    public func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController)
      {
        viewDidLoad()
      }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
