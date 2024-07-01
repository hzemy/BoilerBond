//
//  InfoViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/9/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase
class InfoViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var yearSchool: UITextField!
    var intermediaryUserTwo = User(fname: "", lname: "", username: "", email: "", major: "", year: "")
    var intermediaryUserThree: User?
    var majorText: String?
    var yearText: String?
    var db : Firestore!
    var storage: Storage!
    @IBOutlet weak var major: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        storage = Storage.storage()
        //print("intermediaryUserTwo \(intermediaryUserTwo)")

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        // Show error messages if the text fields are empty
        let invalidYearBanner = Banner(title: "You must enter your year in school.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        invalidYearBanner.dismissesOnTap = true
        let invalidMajorBanner = Banner(title: "You must enter your major.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        invalidMajorBanner.dismissesOnTap = true
        // Example of showing error banner on screen
        //self.errorMessage(banner: invalidYearBanner)
        if (yearSchool.text == "") {
            self.errorMessage(banner: invalidYearBanner)
            return
        }
        if (major.text == "") {
            self.errorMessage(banner: invalidMajorBanner)
            return
        }
        if (yearSchool.text?.lowercased() != "freshman" && yearSchool.text?.lowercased() != "sophmore" && yearSchool.text?.lowercased() != "junior" && yearSchool.text?.lowercased() != "senior") {
            self.errorMessage(banner: invalidYearBanner)
            return
        }
        majorText = major.text!
        yearText = yearSchool.text!
        intermediaryUserThree = User(fname: intermediaryUserTwo.fName, lname: intermediaryUserTwo.lName, username: intermediaryUserTwo.username, email: intermediaryUserTwo.email, major: majorText!, year: yearText!)
        intermediaryUserThree?.pictureURL = intermediaryUserTwo.pictureURL
        
        //write user to database
        let dataToWrite = try! FirestoreEncoder().encode(intermediaryUserThree)
        self.db.collection("users").document(intermediaryUserThree!.email).setData(dataToWrite) { error in
            if (error != nil) {
                print("error writing user to database in register, info view controller")
                print("error: \(String(describing: error))")
                return
            } else {
                print("success writing user to database in register info view controller")
                self.performSegue(withIdentifier: "toEmailVerify", sender: self)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toEmailVerify") {
            if let destVC = segue.destination as? VerifyEmailViewController {
                destVC.intermediaryUserThree = self.intermediaryUserThree!
            }
        }
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "backPic", sender: self)
    }
    func errorMessage(banner : Banner){
        banner.show(duration: 3)
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
