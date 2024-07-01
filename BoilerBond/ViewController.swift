//
//  ViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/7/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase

class ViewController: UIViewController {
    var db : Firestore!
        var storage: Storage!
    override func viewDidLoad() {
        super.viewDidLoad()
        let firestoreSettings = FirestoreSettings()
                Firestore.firestore().settings = firestoreSettings
                db = Firestore.firestore()
                storage = Storage.storage()
        // Do any additional setup after loading the view.
       // submit()
    }
    // emaple of writing to the database
    func submit() {
        let writeableUser = User.init(fname: "Hannah", lname: "Shiple", username: "HannahS", email: "shiple@purdue.edu", major: "CS", year: "Junior")
        
        let dataToWrite = try! FirestoreEncoder().encode(writeableUser)
        self.db.collection("users").document("shiple@purdue.edu").setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document")
            }
        }
    }
}


