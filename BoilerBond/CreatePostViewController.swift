//
//  CreatePostViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 3/8/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase

class CreatePostViewController: UIViewController {

    var db : Firestore!
    var storage: Storage!
    var currentUser: User?
    var newPost: Post?
    var anonFlag: Bool = false
    var isQuestion: Bool = false 
    
    @IBOutlet weak var question: UISwitch!
    @IBOutlet weak var anonymous: UISegmentedControl!
    @IBOutlet weak var post: UIButton!
    @IBOutlet weak var body: UITextField!
    @IBOutlet weak var course: UITextField!
    @IBOutlet weak var postTitle: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        storage = Storage.storage()
        User.getCurrentUser(completion: getUser)
        // Do any additional setup after loading the view.
    }
    
    func getUser(currentUser: User) {
       self.currentUser = currentUser
    }
    
    func errorMessage(banner : Banner){
        banner.show(duration: 3)
    }

    func courseExists(courseName: String, completion:@escaping((Bool) -> ()) ) {
        var courseExist: Bool = false
        let courseExistsBanner = Banner(title: "Course does not exist on the app.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        courseExistsBanner.dismissesOnTap = true
        let g = DispatchGroup()
        let courseRef = db.collection("courses").document(courseName)
         g.enter()
         courseRef.getDocument { (doc, error) in
             if let doc = doc, doc.exists {
                 print("course doc exist")
                 courseExist = true
                 g.leave()
                 //return
             }
             else {
                 print("course doc doesn't exist")
                 self.errorMessage(banner: courseExistsBanner)
                 self.course.text = ""
                 courseExist = false
                 g.leave()
                 //return
             }
         }
         g.notify(queue: .main) {
             print(courseExist)
             completion(courseExist)
         }
    }
    
    @IBAction func postClicked(_ sender: Any) {
        var courseExist = false
        let fieldEmptyBanner = Banner(title: "Make sure all fields are populated before creating post!", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        fieldEmptyBanner.dismissesOnTap = true
        let postLengthBanner = Banner(title: "Post body must be less than 300 characters.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        postLengthBanner.dismissesOnTap = true
        let courseExistsBanner = Banner(title: "Course does not exist on the app.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        courseExistsBanner.dismissesOnTap = true
        let oneCourseBanner = Banner(title: "Each post can have at most one course.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        oneCourseBanner.dismissesOnTap = true
        
        //check if fields are blank and show error banners
        if (body.text == "" || course.text == "" || postTitle.text == "") {
            self.errorMessage(banner: fieldEmptyBanner)
            return
        }
        
        let postName = postTitle.text
        let postBody = body.text
        let courseName:String = course.text!
        let count = courseName.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces).filter  {$0 != ""}.count
        
        //make sure post body is less than 300 chars
        if (postBody!.count > 300) {
            self.errorMessage(banner: postLengthBanner)
            body.text = ""
            return
        }
        
        //make sure only one course per post
        if (count > 1 || courseName.count > 7) {
            self.errorMessage(banner: oneCourseBanner)
            course.text = ""
            return
        }
        
        //make sure course name exists in the database
        courseExists(courseName: courseName) { [self] res in
            if (res == false) {
                course.text = ""
                courseExist = false
                return
            } else if (res == true) {
                courseExist = true
                //course exists, create post
                if (anonFlag == false) {
                    newPost = Post(course: courseName, creatorId: currentUser!.email, title: postName!, body: postBody!, madeAnonymously: anonFlag, isQuestion: isQuestion)
                }
                else {
                    newPost = Post(course: courseName, creatorId: "ANON_USER", title: postName!, body: postBody!, madeAnonymously: anonFlag, isQuestion: isQuestion)
                    newPost?.realCreator = currentUser!.email 
                }
                
                currentUser?.createPost(post: newPost!)
                
                let dataToWrite = try! FirestoreEncoder().encode(newPost)
                self.db.collection("posts").document(newPost!.postId).setData(dataToWrite) { error in
                    if (error != nil) {
                        print("error writing post to database in create post")
                        print("error: \(String(describing: error))")
                        self.body.text = ""
                        self.course.text = ""
                        self.postTitle.text = ""
                        return
                    } else {
                        print("success writing post to database in create post")
                        self.body.text = ""
                        self.course.text = ""
                        self.postTitle.text = ""
                        return
                    }
                }
                
                return
            }
        }
        
        if (courseExist == false) {
            return
        }
       
       /* let courseRef = db.collection("courses")
        courseRef.whereField("courseId", isEqualTo: courseName).getDocuments( completion: { [self]
            (doc, error) in
            if error != nil {
                print("Error in finding course in database")
                return
            } else {
                if ((doc!.isEmpty)) {
                    self.errorMessage(banner: courseExistsBanner)
                    course.text = ""
                    courseExist = false
                    return
                }
                print("course does exist")
            }
        }) */
        
    }
    
    @IBAction func questionChanged(_ sender: Any) {
        if question.isOn {
            //when switch is green
            isQuestion = true
            newPost?.isQuestion = true
        } else {
            //when switch is grey
            isQuestion = false
            newPost?.isQuestion = false
        }
        print("is question \(isQuestion)")
        
    }
    
    @IBAction func anonChanged(_ sender: Any) {
        if anonymous.selectedSegmentIndex == 0 { //off
            print("anon off")
            anonFlag = false
            newPost?.madeAnon = false
        } else if anonymous.selectedSegmentIndex == 1 { //on
            print("anon on")
            anonFlag = true
            newPost?.madeAnon = true
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
