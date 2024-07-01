//
//  CreateCourseViewController.swift
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

class CreateCourseViewController: UIViewController {

    var db : Firestore!
    var storage: Storage!
    var currentUser: User?
    var newCourse: Course?
    @IBOutlet weak var create: UIButton!
    @IBOutlet weak var department: UITextField!
    @IBOutlet weak var courseTitle: UITextField!
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
    
    @IBAction func createClicked(_ sender: Any) {
        var courseExist = false
        let fieldEmptyBanner = Banner(title: "Make sure all fields are populated before creating course!", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        fieldEmptyBanner.dismissesOnTap = true
        let courseExistsBanner = Banner(title: "Course already exists on the app.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        courseExistsBanner.dismissesOnTap = true
        let courseTitleBanner = Banner(title: "Course title must be in the format: DEPT####", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        courseTitleBanner.dismissesOnTap = true
        let wrongDeptBanner = Banner(title: "Department name must match with course title.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        wrongDeptBanner.dismissesOnTap = true
        
        //check if fields are blank and show error banners
        if (department.text == "" || courseTitle.text == "") {
            self.errorMessage(banner: fieldEmptyBanner)
            return
        }
        
        let dept = department.text
        let courseName = courseTitle.text
        
        //regex for course name should be DEPT####
        let courseRegex = try! NSRegularExpression(pattern: "[A-Z]{2,4}[0-9]{2,4}")
        let range = NSRange(location: 0, length: (courseName!.utf16.count))
        if (courseRegex.firstMatch(in: courseName!, options: [], range: range) == nil) {
            self.errorMessage(banner: courseTitleBanner)
            courseTitle.text = ""
            return
        }
        
        //make sure dept matches dept in courseName
        if(courseName?.contains(dept!) == false) {
            self.errorMessage(banner: wrongDeptBanner)
            department.text = ""
            return
        }
        
        //make sure course does not already exist in the database
        db.collection("courses").getDocuments() { [self] (querySnapshot, err) in
            if err != nil {
                print("error getting documents in create course")
                return
            } else {
                var count = 0
                for document in querySnapshot!.documents {
                    count += 1
                    if((document.get("courseId") as! String) == courseName) {
                        self.errorMessage(banner: courseExistsBanner)
                        self.courseTitle.text = ""
                        self.department.text = ""
                        courseExist = true
                        return
                    }
                    if (count == querySnapshot?.count) {
                        //no matching courses in database
                        //create course object and add to database
                        newCourse = Course(title: courseName!, department: dept!)
                        //when a user creates a new course, they will be enrolled in that course
                        currentUser?.enrolledCourses.append(newCourse!.title)
                        let courseRef = db.collection("users").document(currentUser!.email)
                        courseRef.updateData([
                            "enrolledCourses": FieldValue.arrayUnion([self.newCourse!.title])
                        ])
                        newCourse?.addClassmate(email: currentUser!.email)
                        let dataToWrite = try! FirestoreEncoder().encode(newCourse)
                        db.collection("courses").document(newCourse!.title).setData(dataToWrite) { error in
                            if (error != nil) {
                                print("error writing new course to database in create course")
                                return
                            } else {
                                print("success writing new course to database in create course")
                                self.courseTitle.text = ""
                                self.department.text = ""
                                return
                            }
                        }
                        
                    }
                }
            }
        }
        
        if (courseExist == true) {
            return
        }
        
        //create course object and add to database
        /*newCourse = Course(title: courseName!, department: dept!)
        //when a user creates a new course, they will be enrolled in that course
        newCourse?.addClassmate(email: currentUser!.email)
        let dataToWrite = try! FirestoreEncoder().encode(newCourse)
        db.collection("courses").document(newCourse!.title).setData(dataToWrite) { error in
            if (error != nil) {
                print("error writing new course to database in create course")
                return
            } else {
                print("success writing new course to database in create course")
                self.courseTitle.text = ""
                self.department.text = ""
                return
            }
        } */

        
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
