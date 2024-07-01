//
//  CoursePostsViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 3/16/21.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase

class CoursePostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellDelegate, UIAdaptivePresentationControllerDelegate {
    func comments(commentList: [String], aPost: Post) {
        self.commentList = commentList
        self.currentPost = aPost
        self.performSegue(withIdentifier: "toComment", sender: self)
    }
    func deletePost(postId: String) {
        let db = Firestore.firestore()
        //retrieve post object from database to get it's course name
        db.collection("posts").document(postId).getDocument() { [self] (doc, error) in
            if error != nil  {
                print("error getting post document in FeedViewController.swift")
                return
            } else {
                let thePost = try! FirestoreDecoder().decode(Post.self, from: doc!.data()!)
                let courseName = thePost.course
                currentUser?.deletePost(postId: postId, courseName: courseName)
            }
        }
    }
    
    func savePost(postId: String) {
        currentUser?.toggleSavedPost(postId: postId)
    }
    
    func likePost(postId: String) {
        currentUser?.toggleLikedPost(postId: postId)
    }
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var postsTableView: UITableView!
    var course: Course? = nil
    var currentUser: User? = nil
    var posts: [Post] = []
    var firstCommentUN: String = ""
    var firstCommentText: String = ""
    var commentList: [String] = []
    var currPost: Post? = nil
    var currentPost: Post? = nil 
    
    override func viewDidLoad() {
        posts.removeAll()
        super.viewDidLoad()
        postsTableView.delegate = self
        postsTableView.dataSource = self
        User.getCurrentUser(completion: getUser)
        postsTableView.rowHeight = 420
        postsTableView.estimatedRowHeight = 420
        self.postsTableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        User.getCurrentUser(completion: getUser)
    }
    
    func getUser(currentUser: User) {
        self.currentUser = currentUser
        posts.sort(by: {$0.timestamp > $1.timestamp})
        postsTableView.reloadData()
        addPosts()
    }
    func addPosts() {
        course?.getPosts { (post) in
            if(self.posts.contains(post) == false) {
                self.posts.append(post)
                self.postsTableView.reloadData()
            }
        }
        courseName.text = course?.title
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currPost = posts[indexPath.row]
        self.performSegue(withIdentifier: "toSinglePost", sender: self)
    }
    public func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController)
      {
        viewDidLoad()
      }
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?)
      {
        if segue.destination is CommentViewController
        {
            let vc = segue.destination as? CommentViewController
            vc?.comments = commentList
            vc?.post = currentPost
            segue.destination.presentationController?.delegate = self;
        }
        if segue.identifier == "toSinglePost" {
            let viewController = segue.destination as! SinglePostViewController
            if currPost!.comments.isEmpty{
                firstCommentUN = ""
                firstCommentText = ""
            }else{
            let firstComment: String = (currPost?.comments[0])!
                firstCommentUN = firstComment.components(separatedBy: ": ")[0]
                firstCommentText = firstComment.components(separatedBy: ": ")[1]
            }
            viewController.courseNameText = currPost!.course
            viewController.usernameText = currPost!.creatorId
            viewController.commentsList = currPost!.comments
            viewController.postCaptionText = currPost!.body
            viewController.postTitleText = currPost!.title
            viewController.DisplayedCommentUserNameText = firstCommentUN
            viewController.DisplayedCommentTextText = firstCommentText
            viewController.postID = currPost!.postId
            viewController.currentPost = currPost
            segue.destination.presentationController?.delegate = self;
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Sort the posts by timestamp
        posts.sort(by: { (first: Post, second: Post) -> Bool in
                   first.timestamp > second.timestamp
               })
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoursePosts", for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.username?.text = post.creatorId
        cell.postTitle?.text = post.title
        cell.caption?.text = post.body
        cell.courseName?.text = post.course
        cell.delegate = self
        cell.id = post.postId
        cell.post = post
        if post.comments.isEmpty{
            firstCommentUN = ""
            firstCommentText = ""
        }else{
        let firstComment: String = post.comments[0]
            firstCommentUN = firstComment.components(separatedBy: ": ")[0]
            firstCommentText = firstComment.components(separatedBy: ": ")[1]
        }
        cell.commentList = post.comments
        //commentList.removeAll()
        //commentList = post.comments
        cell.commentUsername?.text = firstCommentUN
        cell.commentText?.text = firstCommentText
        cell.deleteButton.isHidden = true
        let ref2 = Storage.storage().reference(withPath: "media/" + post.creatorId + "/" + "profile.jpeg")
        ref2.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                cell.profilePicture?.image = UIImage(data: data!)
            }
        }
        return cell
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
