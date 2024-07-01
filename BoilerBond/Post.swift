//
//  Post.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/7/21.
//

import Foundation
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

struct Post: Codable, Equatable {
    var postId: String
    var course: String
    var creatorId: String
    var title: String
    var body: String
    var comments: [String]
    var likes: Int
    var timestamp: String
    var madeAnon: Bool
    var isQuestion: Bool
    var realCreator: String?
    
    init(course: String, creatorId: String, title: String, body: String, madeAnonymously: Bool, isQuestion: Bool) {
        self.postId = UUID().uuidString
        self.title = title
        self.course = course
        self.comments = []
        self.creatorId = creatorId
        self.body = body
        self.likes = 0
        let today = Date()
        //let formatter1 = DateFormatter()
        //formatter1.dateStyle = .short
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy HH:mm:ss"
        //self.timestamp = formatter1.string(from: today)
        self.timestamp = dateFormatterGet.string(from: today)
        self.madeAnon = madeAnonymously
        self.isQuestion = isQuestion
        self.realCreator = ""
    }
    
    static func getPost(postId: String, completion: @escaping((Post) -> ())) {
        DispatchQueue.main.async {
            let db = Firestore.firestore()
            let topicRef = db.collection("posts")
            //var model: Topic?
            
            topicRef.document(postId).getDocument() { querySnapshot, error in
                if (error != nil) {
                    print("error getting document: \(String(describing: error))")
                    return
                }
                if (querySnapshot?.data() == nil) {
                    return
                } else {
                    let model = try! FirestoreDecoder().decode(Post.self, from: (querySnapshot?.data())!)
                    //print("Model:  \(String(describing: model))")
                    completion(model)
                    //completion(model)
                    //return model
                    
                }
            }
        }
        
    }
    
    mutating func addComment(comment: String) {
        self.comments.append(comment)
    }
    
    func getComments(addComment: @escaping(([String]) -> ())){
        //Get all Comments per Post
        //Refer to liked posts
        let db = Firestore.firestore()
        for comment in self.comments{
            let ref = db.collection("posts").document(comment)
            ref.getDocument { document, error in
                if let document = document {
                    if document.data() != nil {
                        let model = try! FirestoreDecoder().decode(Post.self, from: document.data()!)
                        addComment(model.comments)
                    }
                    else {
                        print("Document does not exist or has been deleted")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    //remove comment from a post
    mutating func deleteComment(comment: String) {
        print("comment:" + comment)
        print("comment array  \(self.comments)")
        let index: Int = self.comments.firstIndex(of: comment)!
        self.comments.remove(at: index)
        let auth = Auth.auth()
        let user = auth.currentUser
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(self.postId)
        postRef.updateData([
            "comments": FieldValue.arrayRemove([comment])
        ])
        
    }
    
    //delete post for admin
    static func deletePost(thePost: Post, theUser: User) {
        let auth = Auth.auth()
        var user: User? = theUser //user that created the post
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        let db = Firestore.firestore()
        
        //retrieve user from database
        let userRef = db.collection("users").document(thePost.creatorId)
       /* userRef.getDocument() { doc,error in
            if (error != nil) {
                print("error getting user in deletePost")
                return
            }
            if (doc == nil) {
                return
            }
            else {
                user = try! FirestoreDecoder().decode(User.self, from: (doc?.data())!)
                print("user that created post in deletePost: \(String(describing: user))")
            }
        }*/
        
        
        
        //delete post from user's createdPosts array
        user!.deleteCreatedPost(postId: thePost.postId)
        
        userRef.updateData([
            "createdPosts": FieldValue.arrayRemove([thePost.postId])
        ])
        
        //delete post from all user's metadata arrays
        let usersRef = db.collection("users")
        usersRef.whereField("likedPosts", arrayContains: thePost.postId).getDocuments()  { doc, error in
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
                        "likedPosts": FieldValue.arrayRemove([thePost.postId])
                    ])
                }
            }
        }
        usersRef.whereField("savedPosts", arrayContains: thePost.postId).getDocuments() { doc, error in
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
                        "savedPosts": FieldValue.arrayRemove([thePost.postId])
                    ])
                }
            }
        }
        
        //delete post from course's posts array
        let courseRef = db.collection("courses").document(thePost.course)
        courseRef.updateData([
            "posts": FieldValue.arrayRemove([thePost.postId])
        ])
        
        //delete post from firestore
        db.collection("posts").document(thePost.postId).delete() { err in
            if let err = err {
                print("error deleting post from database")
            } else {
                print("success deleting post from database")
            }
        }
        
    }
    
    mutating func addLike() {
        self.likes += 1
    }
    
    mutating func removeLike() {
        self.likes -= 1
    }
    
    func getLikes() -> Int {
        return self.likes;
    }
    
    
    
    
    
    
    
    
}
