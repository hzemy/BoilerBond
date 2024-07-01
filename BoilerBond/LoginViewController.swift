//
//  LoginViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/9/21.
//

import UIKit
import FirebaseFirestore
import BRYXBanner
import FirebaseAuth
import EmailValidator
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var usernameoremail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        password.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    // Login method when login button is pressed
    @IBAction func loginPressed(_ sender: Any) {
        let noMatchPasswordBanner = Banner(title: "Incorrect Password!", subtitle: "Enter your correct password and try again.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        noMatchPasswordBanner.dismissesOnTap = true
        let noUserBanner = Banner(title: "No User Found", subtitle: "Ensure that you entered your username or email and password correctly.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        noUserBanner.dismissesOnTap = true
        let noEmailBanner = Banner(title: "Invalid email address", subtitle: "Ensure your email is entered correctly.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        noEmailBanner.dismissesOnTap = true
        
        // Example of showing error banner on screen
        //self.errorMessage(banner: noMatchPasswordBanner)
        let usernameOrEmail = usernameoremail.text ?? ""
        let pass = password.text ?? ""
        if(usernameoremail.text == "" || password.text == "") {
            self.errorMessage(banner: noUserBanner, field: self.password)
            return
        }
        if(usernameOrEmail.contains("@purdue.edu")) {
                    // signing with email address
            Auth.auth().signIn(withEmail: usernameOrEmail, password: pass) { (authResult, error) in
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                        case .wrongPassword:
                            // Error: The password is incorrect
                            self.errorMessage(banner: noMatchPasswordBanner, field: self.password)
                            return
                        case .invalidEmail:
                            // Error: Indicates the email address is malformed.
                            self.errorMessage(banner: noEmailBanner, field: self.usernameoremail)
                            return
                        case .userNotFound:
                            // no user
                            self.errorMessage(banner: noUserBanner, field: self.password)
                            return
                        default:
                            self.errorMessage(banner: noUserBanner, field: self.password)
                            return
                    }
                    } else {
                        if (usernameOrEmail == "admin@purdue.edu") {
                            self.performSegue(withIdentifier: "toAdmin", sender: self)
                        }
                        else {
                            self.performSegue(withIdentifier: "toFeed", sender: self)
                        }
                    }
            }
        } else {
            // sign-in with username
            let db = Firestore.firestore()
            
            var usersRef = db.collection("users").whereField("username", isEqualTo: usernameOrEmail)
            
            usersRef.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("error")
                } else {
                    var foundDoc: QueryDocumentSnapshot? = nil;
                    for document in querySnapshot!.documents {
                        if(document.get("username") as? String == self.usernameoremail.text){
                            foundDoc = document;
                            break
                        }
                    }
                    
                    if (foundDoc == nil){
                        //document wasn't found, no user with the given username
                        self.errorMessage(banner: noUserBanner, field: self.password)
                        return;
                    }
                    for document in querySnapshot!.documents {
                        //print(document.data()["email"])
                        Auth.auth().signIn(withEmail: document.data()["email"] as! String, password: pass) { (authResult, error) in
                            if let error = error as NSError? {
                                switch AuthErrorCode(rawValue: error.code) {
                                    case .wrongPassword:
                                        // Error: The password is incorrect
                                        self.errorMessage(banner: noMatchPasswordBanner, field: self.password)
                                        return
                                    case .userNotFound:
                                        // no user
                                        self.errorMessage(banner: noUserBanner, field: self.password)
                                        return
                                    default:
                                        self.errorMessage(banner: noUserBanner, field: self.password)
                                        return
                                }
                                } else {
                                        self.performSegue(withIdentifier: "toFeed", sender: self)
                                }
                        }
                    }
                }
            }
        }
    }
    
    func errorMessage(banner : Banner, field: UITextField){
        banner.show(duration: 3)
        field.becomeFirstResponder()
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
