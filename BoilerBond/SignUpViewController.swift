//
//  SignUpViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/9/21.
//

import UIKit
import FirebaseFirestore
import BRYXBanner
import FirebaseAuth
import EmailValidator
class SignUpViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var fname: String = ""
    var lname: String = ""
    var emailText: String = ""
    var passwordText: String = ""
    var passwordConfirm: String = ""
    var usernameText: String = ""
    
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        let passwordNoMatchBanner = Banner(title: "Your password and confirm password must match!", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        passwordNoMatchBanner.dismissesOnTap = true
        
        let usedUsernameBanner = Banner(title: "You have entered a username that is already being used.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        usedUsernameBanner.dismissesOnTap = true
        
        let invalidUsernameBanner = Banner(title: "Username must be alphanumeric and 6-30 characters long.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        usedUsernameBanner.dismissesOnTap = true
        
        
        let invalidPasswordBanner = Banner(title: "Password is too weak!", subtitle: "Password must be at least 8 characters, contain at least one uppercase and at least one lowercase character, and one special character!", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        invalidPasswordBanner.dismissesOnTap = true
        
        let usedEmailBanner = Banner(title: "The email you entered is already linked to another account.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        usedEmailBanner.dismissesOnTap = true
        
        let invalidEmailBanner = Banner(title: "The email you entered is invalid, please use a @purdue email.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        invalidEmailBanner.dismissesOnTap = true
        
        let missingField = Banner(title: "Make sure to fill out each required field.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        missingField.dismissesOnTap = true
        
        if (firstName.text == "" || lastName.text == "" || email.text == "" || username.text == "" || password.text == "" || confirmPassword.text == "") {
            self.errorMessage(banner: missingField)
            return
        }
        fname = (firstName.text?.trimmingCharacters(in: .whitespaces))!
        lname = (lastName.text?.trimmingCharacters(in: .whitespaces))!
        emailText = (email.text?.trimmingCharacters(in: .whitespaces))!
        passwordText = (password.text?.trimmingCharacters(in: .whitespaces))!
        passwordConfirm = (confirmPassword.text?.trimmingCharacters(in: .whitespaces))!
        usernameText = (username.text?.trimmingCharacters(in: .whitespaces))!
        
        //check for valid username
        let usernameRegex = try! NSRegularExpression(pattern: "[a-zA-Z0-9]{6,30}")
        let range = NSRange(location: 0, length: (usernameText.utf16.count))
        if (usernameRegex.firstMatch(in: usernameText, options: [], range: range) == nil) {
            self.errorMessage(banner: invalidUsernameBanner)
            return 
        }
        
        //check if username already exists
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("error getting documents in sign up")
                return
            } else {
                for document in querySnapshot!.documents {
                    if(document.get("username") as! String == self.usernameText) {
                        self.errorMessage(banner: usedUsernameBanner)
                        return
                    }
                }
            }
        }
        
        //check for valid email
        if(!emailText.contains("@purdue") || !EmailValidator.validate(email: emailText, allowTopLevelDomains: true, allowInternational: true)) {
            self.errorMessage(banner: invalidEmailBanner)
            return
        }
        
        //check for valid password
        let passwordRegex = try! NSRegularExpression(pattern: "(?=.*[^A-Za-z0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}")
        let range2 = NSRange(location: 0, length: (passwordText.utf16.count))
        if (passwordRegex.firstMatch(in: passwordText, options: [], range: range2) == nil) {
            self.errorMessage(banner: invalidPasswordBanner)
            return
        }
        
        //check if password fields match
        if (!(passwordText.elementsEqual(passwordConfirm))) {
            self.errorMessage(banner: passwordNoMatchBanner)
            return
        }
        
        //if all fields are valid, create the user
        Auth.auth().createUser(withEmail: emailText, password: passwordText) { (authResult,error) in
            if (error != nil) {
                let e = error!
                let errCode = AuthErrorCode(rawValue: e._code)
                switch(errCode) {
                case .emailAlreadyInUse:
                    self.errorMessage(banner: usedEmailBanner)
                    break
                case .invalidEmail:
                    self.errorMessage(banner: invalidEmailBanner)
                    break
                default:
                    print("unkown error in auth create user")
                    break
                }
                return
            } else {
                //no errors with creating a user
                self.performSegue(withIdentifier: "toProfilePic", sender: self)
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toProfilePic") {
            if let destVC = segue.destination as? ProfilePictureViewController {
                destVC.intermediaryUser = User(fname: fname, lname: lname, username: usernameText, email: emailText, major: "", year: "")
            }
        }
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "toMain", sender: self)
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
