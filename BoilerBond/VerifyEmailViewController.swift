//
//  VerifyEmailViewController.swift
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

class VerifyEmailViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var intermediaryUserThree: User?
    var activityIndicator = UIActivityIndicatorView()
    let invalidEmailBanner = Banner(title: "The email you entered was invalid.", subtitle: "Something appears to be wrong with the email address entered.", image: nil, backgroundColor: UIColor.orange, didTapBlock: nil)
    let unkownErrorBanner = Banner(title: "Something went wrong!", subtitle: "An unknown error occured.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
    let successBanner = Banner(title: "Successfully verified your email!", subtitle: "", image: nil, backgroundColor: UIColor.green, didTapBlock: nil)
    let bannerDisplayTime = 3.0
    var didVerifyEmail = false
    var timer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // print("intermediaryUserThree \(intermediaryUserThree)")
        invalidEmailBanner.dismissesOnTap = true
        unkownErrorBanner.dismissesOnTap = true
        successBanner.dismissesOnTap = true
        Auth.auth().languageCode = "en"
        Auth.auth().currentUser?.sendEmailVerification(completion: {
            (error) in
            if (error != nil) {
                let e = AuthErrorCode(rawValue: error!._code)
                switch(e) {
                case .invalidEmail:
                    self.invalidEmailBanner.show(duration: self.bannerDisplayTime)
                    break
                default:
                    self.unkownErrorBanner.show(duration: self.bannerDisplayTime)
                    break
                }
                return
            }
        })
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0,repeats: true) {
            (timer) in
            self.isEmailVerified()
        }
    
    }
    
    func isEmailVerified() {
        Auth.auth().currentUser?.reload(completion: { (error) in
            if error != nil {
                self.unkownErrorBanner.show(duration: self.bannerDisplayTime)
                return
            } else {
                self.didVerifyEmail = Auth.auth().currentUser!.isEmailVerified
                if (self.didVerifyEmail) {
                    self.successBanner.show(duration: self.bannerDisplayTime)
                    self.performSegue(withIdentifier: "toFeed", sender: self)
                }
            }
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "onBack", sender: self)
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
