//
//  ForgotPasswordViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/11/21.
//

import UIKit
import FirebaseFirestore
import BRYXBanner
import FirebaseAuth
import EmailValidator

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var sendEmailButtton: UIButton!
    var db : Firestore!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
    }
    
    @IBAction func sendEmailClicked(_ sender: Any) {
      let missingEmail = Banner(title: "Make sure to enter your email.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
          missingEmail.dismissesOnTap = true
      
        if (email.text == "") {
            self.errorMessage(banner: missingEmail)
            return
        }
      
        let emailText = (email.text?.trimmingCharacters(in: .whitespaces))!
      
        let invalidEmailBanner = Banner(title: "The email you entered is invalid, please enter your @purdue email.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        invalidEmailBanner.dismissesOnTap = true
      
        if(!emailText.contains("@purdue.edu") || !EmailValidator.validate(email: emailText, allowTopLevelDomains: true, allowInternational: true)) {
            self.errorMessage(banner: invalidEmailBanner)
            return
        }
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                //print("error getting documents in sign up")
                return
            } else {
                for document in querySnapshot!.documents {
                    if(document.get("email") as! String == emailText) {
                        //print("Func email: " + email)
                        self.resetPassword(email: emailText, onSuccess: self.onSuccess, onError: self.onError)
                        return;
                    }
                }
                let unUsedEmailBanner = Banner(title: "You have entered an email that is not used.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
                unUsedEmailBanner.dismissesOnTap = true
                self.errorMessage(banner: unUsedEmailBanner)
                return
            }
        }
    }
  
  func onSuccess() {
    self.view.endEditing(true)
    let alert = UIAlertController(title: "Check your inbox", message: "We have sent you a password reset email.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true)
    self.navigationController?.popViewController(animated: true)
  }
  
  func onError(errorMessage : String) {
      print("Error in sending email")
  }
  
  func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
    Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
      if error == nil {
        onSuccess()
      } else {
        onError(error!.localizedDescription)
      }
    })
    
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
