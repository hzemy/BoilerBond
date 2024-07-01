//
//  ProfileViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/11/21.
//
import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase


class ProfileViewController: UIViewController, CellDelegate, UIAdaptivePresentationControllerDelegate {
    func comments(commentList: [String], aPost: Post) {
        self.currentPost = aPost
        self.commentList = commentList
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
                if(segmentationBar.selectedSegmentIndex == 0){
                    indexChanged(self)
                }
            }
        }
    }
    
    func savePost(postId: String) {
        currentUser?.toggleSavedPost(postId: postId)
        if(segmentationBar.selectedSegmentIndex == 2){
            indexChanged(self)
        }
    }
    
    func likePost(postId: String) {
        currentUser?.toggleLikedPost(postId: postId)
        if(segmentationBar.selectedSegmentIndex == 1){
            indexChanged(self)
        }
    }
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var major: UILabel!
    @IBOutlet weak var createPostButton: UIButton!
    
    @IBOutlet weak var segmentationBar: UISegmentedControl!
    @IBOutlet weak var coursesButton: UIButton!
    var currentUser: User? = nil
    var currentPost: Post? = nil
    var storage: Storage!
    var profilePosts: [Post] = []
    var path: String = ""
    var firstCommentUN: String = ""
    var firstCommentText: String = ""
    var commentList: [String] = []
   // var currPost: Post? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        User.getCurrentUser(completion: getUser)
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.rowHeight = 420
        profileTableView.estimatedRowHeight = 420
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        User.getCurrentUser(completion: getUser)
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.rowHeight = 420
        profileTableView.estimatedRowHeight = 420
    }
    
    func getUser(currentUser: User) {
        self.currentUser = currentUser
        major.text = currentUser.major
        username.text = currentUser.username
        name.text = currentUser.fName + " " + currentUser.lName
        let path = "media/" + (currentUser.email) + "/" +  "profile.jpeg"
        let ref = Storage.storage().reference(withPath: path)
        
        ref.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                self.profilePicture.image = UIImage(data: data!)
            }
        }
        if (segmentationBar.selectedSegmentIndex == 0) {
            profilePosts.removeAll()
            currentUser.getCreatedPostsArray(addPost: addPost)
        }
        if (segmentationBar.selectedSegmentIndex == 1) {
            profilePosts.removeAll()
            currentUser.getLikedPosts(addPost: addPost)
        }
        if (segmentationBar.selectedSegmentIndex == 2) {
            profilePosts.removeAll()
            currentUser.getSavedPosts(addPost: addPost)
        }
    }
    func addPost(post: Post){
        //print(post)
        if(profilePosts.contains(post) == false) {
            profilePosts.append(post)
            profileTableView.reloadData()
        }
    }
    func addPostArray(postArray: [Post]) {
        for post in postArray {
            if(profilePosts.contains(post) == false) {
                profilePosts.append(post)
                profileTableView.reloadData()
            }
        }
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
        if segue.identifier == "mySegue" {
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
    var currPost: Post? = nil
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currPost = profilePosts[indexPath.row]
        self.performSegue(withIdentifier: "toSinglePost", sender: self)
    }
    public func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController)
      {
        viewWillAppear(true)
      }
    @IBAction func createPostButtonClicked(_ sender: Any) {
    }
    
    @IBAction func viewCoursesClicked(_ sender: Any) {
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentationBar.selectedSegmentIndex{
        case 0:
            //Created Posts
            profilePosts.removeAll()
            //User.getCreatedPosts(email: (currentUser?.email)!, completion: addPostArray)
            currentUser!.getCreatedPostsArray(addPost: addPost)
            profileTableView.reloadData()
        case 1:
            //Liked Posts
            profilePosts.removeAll()
            currentUser!.getLikedPosts(addPost: addPost)
            profileTableView.reloadData()
        case 2:
            //Saved Posts
            profilePosts.removeAll()
            currentUser!.getSavedPosts(addPost: addPost)
            profileTableView.reloadData()
        default:
            profilePosts.removeAll()
            //User.getCreatedPosts(email: (currentUser?.email)!, completion: addPostArray)
            currentUser!.getCreatedPostsArray(addPost: addPost)
            profileTableView.reloadData()
        }
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
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profilePosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        profilePosts.sort(by: { (first: Post, second: Post) -> Bool in
                   first.timestamp > second.timestamp
        })

        let cell : PostTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Profile", for: indexPath) as! PostTableViewCell
        //print(indexPath.row)
        let post = profilePosts[indexPath.row]

        cell.username?.text = post.creatorId
        cell.postTitle?.text = post.title
        cell.caption?.text = post.body
        cell.courseName?.text = post.course
        cell.delegate = self
        cell.id = post.postId
        cell.post = post
        //currPost = post
        // COMMENTS
        if post.comments.isEmpty{
            firstCommentUN = ""
            firstCommentText = ""
        }else{
        let firstComment: String = post.comments[0]
            firstCommentUN = firstComment.components(separatedBy: ": ")[0]
            firstCommentText = firstComment.components(separatedBy: ": ")[1]
        }
        cell.commentUsername?.text = firstCommentUN
        cell.commentText?.text = firstCommentText
        //END COMMENTS
        cell.commentList = post.comments
        //commentList.removeAll()
        //commentList = post.comments
        if (currentUser?.createdPosts.contains(post.postId) == true) {
            cell.deleteButton.isHidden = false
        }
        else{
            cell.deleteButton.isHidden = true
        }
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
}
