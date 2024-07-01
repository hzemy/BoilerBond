//
//  FeedViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 3/14/21.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase

protocol CellDelegate {
    func savePost(postId: String)
    func likePost(postId: String)
    func deletePost(postId: String)
    func comments(commentList: [String], aPost: Post)
}

class FeedViewController: UIViewController, CellDelegate, UIAdaptivePresentationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func comments(commentList: [String], aPost: Post) {
        self.commentList = commentList
        self.currentPost = aPost
        self.performSegue(withIdentifier: "toComment", sender: self)
    }
    func savePost(postId: String) {
        currentUser?.toggleSavedPost(postId: postId)
    }
    
    func likePost(postId: String) {
        currentUser?.toggleLikedPost(postId: postId)
    }
    
    //delete post from the database
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
    

    @IBOutlet weak var sortBar: UIPickerView!
    @IBOutlet weak var filterBar: UIPickerView!
    @IBOutlet weak var feedTableView: UITableView!
    var currentUser: User? = nil
    var storage: Storage!
    var profilePosts: [Post] = []
    var courses: [Course] = []
    var path: String = ""
    var firstCommentUN: String = ""
    var firstCommentText: String = ""
    var picker1Options:[String] = [String]()
    var picker2Options:[String] = [String]()
    var postsFinal: [Post] = []
    var selectedFilter:String = "All"
    var selectedSort:String = "Time"
    var curPost: Post? = nil
    var commentList: [String] = []
    var currPost: Post? = nil
    var currentPost: Post? = nil
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == filterBar {
             selectedFilter = picker1Options[row]
        } else {
             selectedSort = picker2Options[row]
        }
        if(selectedFilter != "All") {
            postsFinal.removeAll()
            for p in profilePosts {
                if(p.course == selectedFilter) {
                    postsFinal.append(p);
                }
            }
        }
        if(selectedFilter == "All") {
            postsFinal.removeAll()
            postsFinal = profilePosts
        }
        if(selectedFilter == "Questions") {
            postsFinal.removeAll()
            for p in profilePosts {
                if(p.isQuestion) {
                    postsFinal.append(p);
                }
            }
        }
        feedTableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        User.getCurrentUser(completion: getUser)
        feedTableView.delegate = self
        feedTableView.dataSource = self
        feedTableView.rowHeight = 420
        feedTableView.estimatedRowHeight = 420
        self.sortBar.delegate = self
        self.sortBar.dataSource = self
        self.filterBar.delegate = self
        self.filterBar.dataSource = self
        picker2Options = ["Time", "Likes", "Comments"]
        // TODO: Need to add all the courses the current user is in to this list picker1Options
        picker1Options = ["All", "Questions"]
        // Do any additional setup after loading the view.
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == filterBar {
                return picker1Options.count
            } else {
                return picker2Options.count
            }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == filterBar {
                return "\(picker1Options[row])"
            } else {
                return "\(picker2Options[row])"
            }
    }
    override func viewWillAppear(_ animated: Bool) {
        User.getCurrentUser(completion: getUser)
    }
    
    func getUser(currentUser: User) {
        self.currentUser = currentUser
        profilePosts.removeAll()
        currentUser.getEnrolledCourses(addCourse: addCourse)
        postsFinal = profilePosts
        for course in currentUser.enrolledCourses {
            if (picker1Options.contains(course)){
                
            } else {
                picker1Options.append(course)
            }
        }
        filterBar.reloadAllComponents()
        //User.getCreatedPosts(email: currentUser.email, completion: addPostArray)

    }
    func addCourse(course: Course) {
        courses.append(course)
        course.getPosts(completion: addPost)
        //print(course.title)
        feedTableView.reloadData()
    }
    func addPost(post: Post){
        //print(post)
        if(profilePosts.contains(post) == false) {
            profilePosts.append(post)
            postsFinal.append(post)
        }
        if(selectedFilter != "All") {
            postsFinal.removeAll()
            for p in profilePosts {
                if(p.course == selectedFilter) {
                    postsFinal.append(p);
                }
            }
        }
        if(selectedFilter == "All") {
            postsFinal.removeAll()
            postsFinal = profilePosts
        }
        if(selectedFilter == "Questions") {
            postsFinal.removeAll()
            for p in profilePosts {
                if(p.isQuestion) {
                    postsFinal.append(p);
                }
            }
        }
        feedTableView.reloadData()
    }
    func addPostArray(postArray: [Post]) {
        for post in postArray {
            if(profilePosts.contains(post) == false) {
                profilePosts.append(post)
                postsFinal.append(post)
                feedTableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currPost = postsFinal[indexPath.row]
        self.performSegue(withIdentifier: "toSinglePost", sender: self)
    }
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?)
      {
        if segue.identifier == "toComment" {
            let vc = segue.destination as? CommentViewController
            vc?.comments = commentList
            //print("curPost: " + curPost!.postId)
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
    public func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController)
      {
        viewWillAppear(true)
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
extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postsFinal.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Add if statements for other sorting options
        if(selectedFilter == "All") {
            postsFinal = profilePosts
        }
        
        if(selectedSort == "Time") {
            postsFinal.sort(by: { (first: Post, second: Post) -> Bool in
                   first.timestamp > second.timestamp
               })
        }
        if(selectedSort == "Likes") {
            postsFinal.sort(by: { (first: Post, second: Post) -> Bool in
                   first.likes > second.likes
               })
        }
        if(selectedSort == "Comments") {
            postsFinal.sort(by: { (first: Post, second: Post) -> Bool in
                first.comments.count > second.comments.count
               })
        }
        
        let cell : PostTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Feed", for: indexPath) as! PostTableViewCell
        //print(indexPath.row)
        let post = postsFinal[indexPath.row]
       // currPost = post
        cell.username?.text = post.creatorId
        cell.postTitle?.text = post.title
        cell.caption?.text = post.body
        cell.courseName?.text = post.course
        cell.delegate = self
        cell.id = post.postId
        cell.post = post 
        
        // COMMENTS
        if post.comments.isEmpty {
            firstCommentUN = ""
            firstCommentText = ""
        }else{
        let firstComment: String = post.comments[0]
            firstCommentUN = firstComment.components(separatedBy: ": ")[0]
            firstCommentText = firstComment.components(separatedBy: ": ")[1]
        }
        cell.commentList = post.comments
        cell.commentUsername?.text = firstCommentUN
        cell.commentText?.text = firstCommentText
        //END COMMENTS
        //commentList.removeAll()
        //commentList = post.comments
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
}
