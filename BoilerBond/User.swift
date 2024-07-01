//
//  User.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/7/21.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase

struct User: Codable {
        var fName: String
        var lName: String
        var username: String
        var email: String
        var major: String
        var year: String
        var pictureURL: String
        var enrolledCourses: [String]
        var createdPosts: [String]
        var likedPosts: [String]
        var savedPosts: [String]
        var realUsername: String?
    
    init(fname: String, lname: String, username: String, email: String, major: String, year: String) {
        self.fName = fname
        self.lName = lname
        self.username = username
        self.email = email
        self.major = major
        self.year = year
        self.pictureURL = ""
        self.enrolledCourses = []
        self.createdPosts = []
        self.likedPosts = []
        self.savedPosts = []
    }
    func errorMessage(banner : Banner){
        banner.show(duration: 3)
    }
    static func getAllCoursesAdmin(allCourses: @escaping(([Course]) -> ())) {
        //get all the courses in the database
        let db = Firestore.firestore()
        db.collection("courses").getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("error getting all topics from firestore")
            }
            else {
                var allCoursesArray: [Course] = []
                for document in querySnapshot!.documents {
                    let model = try! FirestoreDecoder().decode(Course.self, from: document.data())
                    //print("topic model: \(model)")
                    allCoursesArray.append(model)
                }
                allCourses(allCoursesArray)
            }
        }
    }
    // Admin function to get all users on the app
    static func getAllUsersAdmin(allUsers: @escaping(([User]) -> ())) {
        //get all the topics in the database
        let db = Firestore.firestore()
        db.collection("users").getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("error getting all users from firestore")
            }
            else {
                var allUsersArray: [User] = []
                for document in querySnapshot!.documents {
                    let model = try! FirestoreDecoder().decode(User.self, from: document.data())
                    //print("user model: \(model)")
                    allUsersArray.append(model)
                }
                allUsers(allUsersArray)
            }
        }
    }
    //get current user object, object returned in completion method
    static func getCurrentUser(completion: @escaping((User) -> ())) {
        let auth = Auth.auth()
        let user = auth.currentUser
        let email = user?.email
        let db = Firestore.firestore()
        let ref = db.collection("users").document(email!)
        
        ref.getDocument { document, error in
            if let document = document {
                let model = try? FirestoreDecoder().decode(User.self, from: document.data()!)
                if (model == nil) {
                    print("currentUser object is nil")
                    fatalError()
                }
                completion(model!)
            } else {
                print("CurrentUser document does not exist")
            }
            
        }
    }
    static func getCreatedPosts(email: String, completion: @escaping(([Post]) -> ())) {
        let db = Firestore.firestore()
        db.collection("posts").whereField("creatorId", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var createdPosts: [Post] = []
                    for document in querySnapshot!.documents {
                        let model = try! FirestoreDecoder().decode(Post.self, from: document.data())
                        createdPosts.append(model)
                        print("\(document.documentID) => \(document.data())")
                    }
                    completion(createdPosts)
                }
            }
    }
    //get a user object given that user's email
    static func getUser(email: String, completion: @escaping((User) -> ())) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(email)
        
        ref.getDocument { document, error in
            if let document = document {
                let model = try? FirestoreDecoder().decode(User.self, from: document.data()!)
                if (model == nil) {
                    print("currentUser object is nil")
                    fatalError()
                }
                completion(model!)
            } else {
                print("CurrentUser document does not exist")
            }
        }
    }
    
    //add a post to user's likedPosts array
    mutating func addLikedPost(post: Post) {
        self.likedPosts.append(post.postId)
    }
    
    //add a post to user's savedPosts array
    mutating func addSavedPost(post: Post) {
        self.savedPosts.append(post.postId)
    }
    
    //addd a course to user's classesEnrolled array
    mutating func enrollCourse(course: String) {
        let alreadyEnroll = Banner(title: "You are already enrolled in this course.", subtitle: "Choose a different course to enroll in.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyEnroll.dismissesOnTap = true
        if self.enrolledCourses.contains(course) {
            self.errorMessage(banner: alreadyEnroll)
            return
        }
        self.enrolledCourses.append(course)
        //add user to course's classmates array
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        let db = Firestore.firestore()
        let dataToWrite = try! FirestoreEncoder().encode(self)
        db.collection("users").document(self.email).setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
        let courseRef = db.collection("courses").document(course)
        courseRef.updateData([
            "classmates": FieldValue.arrayUnion([self.email])
        ])
    }
    
    //retrieve the user's likedPosts array
    func getLikedPosts(addPost: @escaping((Post) -> ())) {
        let db = Firestore.firestore()
        for id in self.likedPosts {
            // get the post and convert to Post object
            let ref = db.collection("posts").document(id)
            ref.getDocument { document, error in
                if let document = document {
                    if document.data() != nil {
                        let model = try! FirestoreDecoder().decode(Post.self, from: document.data()!)
                        addPost(model)
                    }
                    else {
                        print("Liked post does not exist or has been deleted")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    //retrieve the user's savedPosts array
    func getSavedPosts(addPost: @escaping((Post) -> ())) {
        let db = Firestore.firestore()
        for postId in self.savedPosts {
            let ref = db.collection("posts").document(postId)
            ref.getDocument { document, error in
                if document?.data() != nil {
                    let model = try! FirestoreDecoder().decode(Post.self, from: (document?.data())!)
                    addPost(model)
                } else {
                    print("Saved post does not exist or error")
                }
                
            }
        }
    }
    
    //retrieve the user's classesEnrolled array
    func getEnrolledCourses(addCourse: @escaping((Course) -> ())) {
        let db = Firestore.firestore()
        for courseId in self.enrolledCourses {
            let ref = db.collection("courses").document(courseId)
            ref.getDocument { document, error in
                if document?.data() != nil {
                    let model = try! FirestoreDecoder().decode(Course.self, from: (document?.data())!)
                    addCourse(model)
                } else {
                    print("Enrolled course does not exist or error")
                }
                
            }
        }
    }
    
    //retrieve the user's createdPosts array
    func getCreatedPostsArray(addPost: @escaping((Post) -> ())) {
        let db = Firestore.firestore()
        for postId in self.createdPosts {
            let ref = db.collection("posts").document(postId)
            ref.getDocument { document, error in
                if document?.data() != nil {
                    let model = try! FirestoreDecoder().decode(Post.self, from: (document?.data())!)
                    addPost(model)
                } else {
                    print("Created post does not exist or error")
                }
                
            }
        }
    }
    
    //delete specific post from user's createdPosts array
    mutating func deleteCreatedPost(postId: String) {
        let index: Int = self.createdPosts.firstIndex(of: postId)!
        self.createdPosts.remove(at: index)
    }
    
    //delete specific post from user's likedPosts array
    mutating func deletelikedPost(postId: String) {
        let index: Int = self.likedPosts.firstIndex(of: postId)!
        self.likedPosts.remove(at: index)
    }
    
    //delete specific post from user's savedPosts array
    mutating func deleteSavedPost(postId: String) {
        let index: Int = self.savedPosts.firstIndex(of: postId)!
        self.savedPosts.remove(at: index)
    }
    
    mutating func removeClass(className: String) {
        let auth = Auth.auth()
        let user = auth.currentUser
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        let db = Firestore.firestore()
        
        let index: Int = self.enrolledCourses.firstIndex(of: className)!
        self.enrolledCourses.remove(at: index)
        
        let userRef = db.collection("users").document(self.email)
        userRef.updateData([
            "enrolledCourses": FieldValue.arrayRemove([className])
        ])
        
        let courseRef = db.collection("courses").document(className)
        courseRef.updateData([
            "classmates": FieldValue.arrayRemove([self.email])
        ])
    }
    
    //user creates a new post in database, adds post to user's created post array and course's posts array and creates a new course if it does not exist
    mutating func createPost(courseName: String, courseDept: String, postTitle: String, postBody: String, madeAnon: Bool, isQuestion: Bool) {
        var newPost: Post
        let auth = Auth.auth()
        let user = auth.currentUser
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        let db = Firestore.firestore()
        //create new post object
        if (madeAnon == true) {
            newPost = Post.init(course: courseName, creatorId: "ANON_USER", title: postTitle, body: postBody, madeAnonymously: madeAnon, isQuestion: isQuestion)
        } else {
            newPost = Post.init(course: courseName, creatorId: (self.email), title: postTitle, body: postBody, madeAnonymously: madeAnon, isQuestion: isQuestion)
        }
        //add new post object to user's createdPosts array
        self.createdPosts.append(newPost.postId)
        //write user's updated createdPosts array to database
        let userRef = db.collection("users").document(self.email)
        userRef.updateData([
            "createdPosts": FieldValue.arrayUnion([newPost.postId])
        ])
        //see if the course exists, if it does not --> create a new course
        let courseRef = db.collection("courses").document(newPost.course)
        courseRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //add new post to course's posts array since the course exists
                courseRef.updateData([
                    "posts": FieldValue.arrayUnion([newPost.postId])
                ])
            } else { //course does not exist, so create a new course and add the new post and the current user
                print("course does not exist, create a new course")
                var newCourse = Course.init(title: newPost.course, department: courseDept)
                newCourse.addPost(postId: newPost.postId)
                newCourse.addClassmate(email: (user?.email)!)
                let dataToWrite = try! FirestoreEncoder().encode(newCourse)
                db.collection("courses").document(newCourse.title).setData(dataToWrite)
            }
        }
        //add post to database
        let dataToWrite = try! FirestoreEncoder().encode(newPost)
        db.collection("posts").document(newPost.postId).setData(dataToWrite) { error in
            if (error != nil) {
                print("error writing new post to the database in createPost")
                return
            } else {
                print("success writing new post to firestore in createPost")
            }
        }
    }
    
    //create post when post object is already created
    mutating func createPost(post: Post) {
        var newPost: Post = post
        let auth = Auth.auth()
        let user = auth.currentUser
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        let db = Firestore.firestore()
        self.createdPosts.append(newPost.postId)
        let userRef = db.collection("users").document(self.email)
        userRef.updateData([
            "createdPosts": FieldValue.arrayUnion([newPost.postId])
        ])
        let courseRef = db.collection("courses").document(post.course)
        courseRef.updateData([
            "posts": FieldValue.arrayUnion([newPost.postId])
        ])
        
    }
    
    //deletes given post from database, user's createdPosts array, course's posts array
    mutating func deletePost(postId: String, courseName: String) {
        let auth = Auth.auth()
        let user = auth.currentUser
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        let db = Firestore.firestore()
        
        //delete post from user's createdPosts array
        self.deleteCreatedPost(postId: postId)
        let userRef = db.collection("users").document(self.email)
        userRef.updateData([
            "createdPosts": FieldValue.arrayRemove([postId])
        ])
        
        //delete post from all user's metadata arrays
        let usersRef = db.collection("users")
        usersRef.whereField("likedPosts", arrayContains: postId).getDocuments()  { doc, error in
            if (error != nil) {
                print("error getting users in deletePost")
                return
            }
            if (doc == nil) {
                return
            }
            else {
                for user in doc!.documents {
                    let model = try! FirestoreDecoder().decode(User.self, from: user.data())
                    let userRef = db.collection("users").document(model.email)
                    userRef.updateData([
                        "likedPosts": FieldValue.arrayRemove([postId])
                    ])
                }
            }
        }
        usersRef.whereField("savedPosts", arrayContains: postId).getDocuments() { doc, error in
            if (error != nil) {
                print("error getting users in deletePost")
                return
            }
            if (doc == nil) {
                return
            }
            else {
                for user in doc!.documents {
                    let model = try! FirestoreDecoder().decode(User.self, from: user.data())
                    let userRef = db.collection("users").document(model.email)
                    userRef.updateData([
                        "savedPosts": FieldValue.arrayRemove([postId])
                    ])
                }
            }
        }
        
        //delete post from course's posts array
        let courseRef = db.collection("courses").document(courseName)
        courseRef.updateData([
            "posts": FieldValue.arrayRemove([postId])
        ])
        
        //delete post from firestore
        db.collection("posts").document(postId).delete() { err in
            if let err = err {
                print("error deleting post from database")
            } else {
                print("success deleting post from database")
            }
        }
    }
    
    func addComment(postId: String, comment: String) {
        let publishedComment = "\(self.email): \(comment)"
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(self.email)
        let postRef = db.collection("posts").document(postId)
        
        postRef.getDocument { document, error in
            if let document = document {
                var model = try! FirestoreDecoder().decode(Post.self, from: document.data()!)
                print("Model: \(model)")
                // add the comment
                model.comments.append(publishedComment)
                // push to db
                let dataToWrite2 = try! FirestoreEncoder().encode(model)
                postRef.setData(dataToWrite2) { error in
                    if error != nil {
                        print("error happened when writing to firestore!")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    func getAllCourses(allCourses: @escaping(([Course]) -> ())) {
        //get all the courses in the database
        let db = Firestore.firestore()
        db.collection("courses").getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("error getting all topics from firestore")
            }
            else {
                var allCoursesArray: [Course] = []
                for document in querySnapshot!.documents {
                    let model = try! FirestoreDecoder().decode(Course.self, from: document.data())
                    //print("topic model: \(model)")
                    allCoursesArray.append(model)
                }
                allCourses(allCoursesArray)
            }
        }
    }
    
    mutating func toggleSavedPost (postId: String) {
          // Error Banners
        let alreadySaved = Banner(title: "Saved Post Removed", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadySaved.dismissesOnTap = true

        let db = Firestore.firestore()
          //Double-Click
        if self.savedPosts.contains(postId) {
            for i in 0..<self.savedPosts.count {
                if self.savedPosts[i] == postId {
                    self.savedPosts.remove(at: i)
                    break
                }
            }
            let dataToWrite = try! FirestoreEncoder().encode(self)
                db.collection("users").document(self.email).setData(dataToWrite) { error in
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                      } else {
                        print("successfully wrote document to firestore with document id )")
                      }
            }
          
            print("You have already saved this post!")
            //self.showAndFocus(banner: alreadyLike)
            self.errorMessage(banner: alreadySaved)
            return
        }
        self.savedPosts.append(postId)
        let dataToWrite = try! FirestoreEncoder().encode(self)
            db.collection("users").document(self.email).setData(dataToWrite) { error in
            
            if(error != nil) {
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
    }
    func addPost(postVar: Post) {
        var post: Post
        post = postVar
        if self.likedPosts.contains(post.postId) {
            post.likes = post.likes - 1
            print(post.likes)
        }
        else {
            post.likes = post.likes + 1
            print(post.likes)
        }
        let db = Firestore.firestore()
        let dataToWrite = try! FirestoreEncoder().encode(post)
        db.collection("posts").document(post.postId).setData(dataToWrite) { error in
                if(error != nil){
                    print("error happened when writing to firestore!")
                    print("described error as \(error!.localizedDescription)")
                    return
                  } else {
                    print("successfully wrote document to firestore with document id )")
                  }
        }
    }
    mutating func toggleLikedPost (postId: String) {
        Post.getPost(postId: postId, completion: addPost)
          // Error Banners
        let alreadyLiked = Banner(title: "Liked Post Removed", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyLiked.dismissesOnTap = true

        let db = Firestore.firestore()
          //Double-Click
        if self.likedPosts.contains(postId) {
            for i in 0..<self.likedPosts.count {
                if self.likedPosts[i] == postId {
                    self.likedPosts.remove(at: i)
                    break
                }
            }
            let dataToWrite = try! FirestoreEncoder().encode(self)
                db.collection("users").document(self.email).setData(dataToWrite) { error in
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                      } else {
                        print("successfully wrote document to firestore with document id )")
                      }
            }
          
            print("You have already liked this post!")
            //self.showAndFocus(banner: alreadyLike)
            self.errorMessage(banner: alreadyLiked)
            return
        }
        self.likedPosts.append(postId)
        let dataToWrite = try! FirestoreEncoder().encode(self)
            db.collection("users").document(self.email).setData(dataToWrite) { error in
            
            if(error != nil) {
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
    }
    
    static func deleteUser (user: User) {
        var user: User = user
        let db = Firestore.firestore()
        
        // Delete all created posts
        deleteUser1(user: user)
       /* for aPost in user.createdPosts {
            db.collection("posts").document(aPost).delete() { err in
                if let err = err {
                    print("error deleting post from database")
                } else {
                    print("success deleting post from database")
                }
            }
        } */
        // Un-enroll from all courses
        deleteUser2(user: user)
       /* for aCourse in user.enrolledCourses {
            user.removeClass(className: aCourse)
        }*/
        // Delete images from storage
        deleteUser3(user: user)
        /*
        let ref = Storage.storage().reference()
        let imageRef = ref.child("media/" + user.email + "/profile.jpeg")
        imageRef.delete { error in
            if let error = error {
                print("error deleting user profile from storage")
            } else {
                print("sucess deleting user profile from storage")
            }
        }
        // Delete user from database
        db.collection("users").document(user.email).delete() { error in
            if error != nil {
                print("error deleting user from firestore")
            } else {
                print("success deleting user from firestore")
            }
        } */
        // Delete user from auth
    }
    
   static func deleteUser1(user: User) {
        let db = Firestore.firestore()
        for aPost in user.createdPosts {
            db.collection("posts").document(aPost).delete() { err in
                if let err = err {
                    print("error deleting post from database")
                } else {
                    print("success deleting post from database")
                }
            }
        }
    }
    
    static func deleteUser2(user: User) {
        var user: User = user
        for aCourse in user.enrolledCourses {
            user.removeClass(className: aCourse)
        }
    }
    
    static func deleteUser3(user: User) {
        let db = Firestore.firestore()
        let ref = Storage.storage().reference()
        let imageRef = ref.child("media/" + user.email + "/profile.jpeg")
        imageRef.delete { error in
            if let error = error {
                print("error deleting user profile from storage")
            } else {
                print("sucess deleting user profile from storage")
            }
        }
        db.collection("users").document(user.email).delete() { error in
            if error != nil {
                print("error deleting user from firestore")
            } else {
                print("success deleting user from firestore")
            }
        }
    }
    
}
