//
//  AdminPostViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 4/4/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner
protocol CellDelegate2 {
    func deletePost(postId: String)
    func comments(commentList: [String], aPost: Post)
    func update()
}
class AdminPostViewController: UIViewController, CellDelegate2, UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate {
    var currentPost: Post? = nil
    func comments(commentList: [String], aPost: Post) {
        self.currentPost = aPost
        self.commentList = commentList
        self.performSegue(withIdentifier: "toComment", sender: self)
    }
    func update() {
        posts.removeAll()
        viewWillAppear(true)
        self.postsTableView.reloadData()
        print("Update UI")
    }
    /*func afterGetDoc(aPost: aPost) {
        
    }*/
    
    func deletePost(postId: String) {
        //Post.deletePost(thePost: post)
        var thePost: Post? = nil
        let db = Firestore.firestore()
        let myGroup = DispatchGroup()
        //retrieve post object from database to get it's course name
       // db.collection("posts").document(postId).getDocument(completion: [Post] -> Void) {  (doc, error) in
        db.collection("posts").document(postId).getDocument() {  (doc, error) in
            if error != nil  {
                print("error getting post document in AdminPostController.swift")
                return
            } else {
                thePost = try! FirestoreDecoder().decode(Post.self, from: doc!.data()!)
                self.deletePost2(thePost: thePost!)
                //completion(thePost)
                //Post.deletePost(thePost: thePost)
            }
        }
        
    }
    
    func deletePost2(thePost: Post) {
        let db = Firestore.firestore()
        var creator: String = ""
        if (thePost.madeAnon == true) {
            creator = thePost.realCreator!
        } else {
            creator = thePost.creatorId
        }
        db.collection("users").document(creator).getDocument() { (doc, error) in
            if error != nil {
                print("error getting user doc in AdminPostController")
                return
            } else {
                var theUser: User = try! FirestoreDecoder().decode(User.self, from: (doc?.data())!)
                Post.deletePost(thePost: thePost, theUser: theUser)
                print("success deleting post in admin")
                self.update()
                return
            }
        }
    }

    
    
    
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var courseName: UILabel!
 
    var course: Course? = nil
    //var currentPost: Post? = nil 
    var posts: [Post] = []
    var firstCommentUN: String = ""
    var firstCommentText: String = ""
    var commentList: [String] = []
    var currPost: Post? = nil
    
    override func viewDidLoad() {
        posts.removeAll()
        super.viewDidLoad()
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.rowHeight = 305
        postsTableView.estimatedRowHeight = 305
        self.postsTableView.reloadData()
        addPosts()
        posts.sort(by: {$0.timestamp > $1.timestamp})
    }
    override func viewWillAppear(_ animated: Bool) {
        addPosts()
        posts.sort(by: {$0.timestamp > $1.timestamp})
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Sort the posts by timestamp
        posts.sort(by: { (first: Post, second: Post) -> Bool in
                   first.timestamp > second.timestamp
               })
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoursePosts", for: indexPath) as! AdminPostTableViewCell
        let post = posts[indexPath.row]
        cell.username?.text = post.creatorId
        cell.postTitle?.text = post.title
        cell.caption?.text = post.body
        cell.courseName?.text = post.course
        cell.id = post.postId
        cell.post = currPost
        cell.delegate = self
        cell.post = post
        
        if post.comments.isEmpty{
            firstCommentUN = ""
            firstCommentText = ""
        }else{
        let firstComment: String = post.comments[0]
            firstCommentUN = firstComment.components(separatedBy: ": ")[0]
            firstCommentText = firstComment.components(separatedBy: ": ")[1]
        }
        cell.delegate = self
        cell.commentList = post.comments
        cell.firstCommentUN?.text = firstCommentUN
        cell.firstCommentText?.text = firstCommentText
        cell.deleteButton.isHidden = false
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
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?)
      {
        if segue.identifier == "toComment" {
            let vc = segue.destination as? AdminCommentViewController
            vc?.comments = commentList
            vc?.post = currentPost
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
