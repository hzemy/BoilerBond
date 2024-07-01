//
//  Course.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/7/21.
//

import Foundation
import UIKit
import SwiftUI
import Foundation
import FirebaseAnalytics
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase


struct Course: Codable {
    var courseId: String
    var title: String
    var posts: [String]
    var classmates: [String] //array of user emails
    var department: String
    
    init(title: String, department: String) {
        self.courseId = title
        self.title = title
        self.posts = []
        self.classmates = []
        self.department = department
    }
    
    //add post to course's posts array
    mutating func addPost(postId: String) {
        self.posts.append(postId)
    }
    //remove post from course's poss array
    mutating func removePost(postId: String) {
        let index: Int = self.posts.firstIndex(of: postId)!
        self.posts.remove(at: index)
    }
    //add classmate to courses's classmates array
    mutating func addClassmate(email: String) {
        self.classmates.append(email)
    }
    //remove classmate from course's classmate array
    mutating func removeClassmate(email: String) {
        let index: Int = self.classmates.firstIndex(of: email)!
        self.classmates.remove(at: index)
    }
    
    //add a new course to the database
    func addCourse(title: String, department: String) {
        var newCourse = Course.init(title: title, department: department)
        let db = Firestore.firestore()
        let dataToWrite = try! FirestoreEncoder().encode(newCourse)
        db.collection("courses").document(newCourse.title).setData(dataToWrite) { error in
            if (error != nil) {
                print("error writing new course to database in addCourse")
            } else {
                print("success writing new course to database in addCourse")
            }
        }
    }
    //get course's posts array
    func getPosts(completion: @escaping((Post) -> ())) {
        let db = Firestore.firestore()
        let postsref = db.collection("posts")
        
        for postId in self.posts {
            let ref = postsref.document(postId)
            ref.getDocument { document, error in
                if let document = document {
                    if document.data() == nil {
                        return
                    }
                    let model = try! FirestoreDecoder().decode(Post.self, from: document.data()!)
                    completion(model)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    //get course's classmates array
    func getClassmates() -> [String] {
        return self.classmates
    }
    func removeUser(courseName: String) {
        let auth = Auth.auth()
        let user = auth.currentUser
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        let db = Firestore.firestore()
        
        //remove course from all users' enrolledCourses array
        let usersRef = db.collection("users")
        usersRef.whereField("enrolledCourses", arrayContains: courseName).getDocuments() {
            doc, error in
            if (error != nil) {
                print("error getting users in deleteCourse")
                return
            }
            if (doc == nil) {
                return
            }
            else {
                for user in doc!.documents {
                    var model: User = try! FirestoreDecoder().decode(User.self, from: user.data())
                    let userRef = db.collection("users").document(model.email)
                    model.removeClass(className: courseName)
                    userRef.updateData([
                        "enrolledCourses": FieldValue.arrayRemove([courseName])
                    ])
                }
            }
        }
    }
    func removePost() {
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        for aPost in self.posts {
            let db = Firestore.firestore()
            //delete from every user's createdPosts array
            db.collection("posts").document(aPost).getDocument() { (doc, error) in
                if error != nil  {
                    print("error getting post document in FeedViewController.swift")
                    return
                } else {
                    if (doc?.data() == nil) {
                        return
                    }
                    let thePost = try! FirestoreDecoder().decode(Post.self, from: doc!.data()!)
                    let userRef = db.collection("users").document(thePost.creatorId)
                    userRef.updateData([
                                        "createdPosts": FieldValue.arrayRemove([aPost])
                    ])
                    db.collection("posts").document(aPost).delete()
                }
            }
        }
    }
    func removeCourse(courseName: String) {
        let db = Firestore.firestore()
        db.collection("courses").document(courseName).delete() { err in
            if let err = err {
                print("error deleting course from database")
            } else {
                print("success deleting course from database")
            }
            
        }
    }
    //delete course from database, de-enroll all students in the course, delete all posts in course
     func deleteCourse(course: String) {
        /*let auth = Auth.auth()
        let user = auth.currentUser
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        let db = Firestore.firestore()*/
        removeUser(courseName: course)
        removePost()
        removeCourse(courseName: course)
        
        /*
        //remove course from all users' enrolledCourses array
        let usersRef = db.collection("users")
        usersRef.whereField("enrolledCourses", arrayContains: course).getDocuments() {
            doc, error in
            if (error != nil) {
                print("error getting users in deleteCourse")
                return
            }
            if (doc == nil) {
                return
            }
            else {
                for user in doc!.documents {
                    var model: User = try! FirestoreDecoder().decode(User.self, from: user.data())
                    let userRef = db.collection("users").document(model.email)
                    model.removeClass(className: course)
                    userRef.updateData([
                        "enrolledCourses": FieldValue.arrayRemove([course])
                    ])
                }
            }
        }
        
        //delete every post in course's posts array from database and users' arrays
        for aPost in self.posts {
            let db = Firestore.firestore()
            //delete from every user's createdPosts array
            db.collection("posts").document(aPost).getDocument() { (doc, error) in
                if error != nil  {
                    print("error getting post document in FeedViewController.swift")
                    return
                } else {
                    let thePost = try! FirestoreDecoder().decode(Post.self, from: doc!.data()!)
                    let userRef = db.collection("users").document(thePost.creatorId)
                    userRef.updateData([
                                        "createdPosts": FieldValue.arrayRemove([aPost])
                    ])
                    db.collection("posts").document(aPost).delete()
                }
            }
        }
        
        
        //delete course from database
        db.collection("courses").document(course).delete() { err in
            if let err = err {
                print("error deleting course from database")
            } else {
                print("success deleting course from database")
            }
            
        }*/
        
        
    }
    
    
    
}
