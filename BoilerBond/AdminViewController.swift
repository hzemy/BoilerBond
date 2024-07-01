//
//  AdminViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 4/3/21.
//

import UIKit
import Foundation
import UIKit
import FirebaseFirestore
import BRYXBanner
import FirebaseAuth
import EmailValidator

class AdminViewController: UIViewController {

    @IBOutlet weak var logout: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logoutPressed(_ sender: Any) {
        do {
            
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toMain", sender: self)
            
        }
            
        catch let error as NSError
            
        {
            
            print("Error logging out user" + error.localizedDescription)
            
        }
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
