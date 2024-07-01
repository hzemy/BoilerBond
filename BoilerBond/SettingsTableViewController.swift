//
//  SettingsTableViewController.swift
//  BoilerBond
//
//  Created by Vanshika Ramesh on 2/10/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var logout: UIButton!
    @IBOutlet weak var submitPassword: UIButton!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var submitProfilePic: UIButton!
    @IBOutlet weak var uploadProfilePic: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var submitUserSettings: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var major: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    var db : Firestore!
    var storage: Storage!
  
    var image: UIImage? = nil
    var currentUser: User? = nil
    @objc func openSelector() {
      let selector = UIImagePickerController()
      selector.sourceType = .photoLibrary
      selector.allowsEditing = true
      selector.delegate = self
      self.present(selector, animated: true, completion: nil)
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let firestoreSettings = FirestoreSettings()
                Firestore.firestore().settings = firestoreSettings
                db = Firestore.firestore()
                storage = Storage.storage()
        currentPassword.isSecureTextEntry = true
        newPassword.isSecureTextEntry = true
        confirmPassword.isSecureTextEntry = true
        profilePic.isUserInteractionEnabled = true
        User.getCurrentUser(completion: getUser)
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSelector))
        profilePic.addGestureRecognizer(tap)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    func getUser(currentUser: User) {
       self.currentUser = currentUser
    }
    @IBAction func submitUserSettingsClicked(_ sender: Any) {
        let usedUsernameBanner = Banner(title: "You have entered a username that is already being used.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        usedUsernameBanner.dismissesOnTap = true
        
        let invalidUsernameBanner = Banner(title: "Username must be alphanumeric and 6-30 characters long.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        usedUsernameBanner.dismissesOnTap = true
        
        let invalidYearBanner = Banner(title: "Year must be freshman, sophomore, junior, senior or graduate", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        usedUsernameBanner.dismissesOnTap = true
        
        
        // get string for the input fields
        let newUsername = username.text!
        let yearString = year.text!
        let fName = firstName.text!
        let lName = lastName.text!
        let maj = major.text!
        
        let collection = Firestore.firestore().collection("users")
        
        // check if first name has been modified
        if (fName != "") {
            collection.document(currentUser!.email).updateData([
                "fName": fName,
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    self.currentUser!.fName = fName
                    self.firstName.text = ""
                    //print("Document successfully updated")
                }
            }
        }
        
        // check if last name has been modiffied
        if (lName != "") {
            collection.document(currentUser!.email).updateData([
                "lName": lName,
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    self.currentUser!.lName = lName
                    self.lastName.text = ""
                    //print("Document successfully updated")
                }
            }
        }
        
        // check if major has been modified
        if (maj != "") {
            collection.document(currentUser!.email).updateData([
                "major": maj,
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    self.currentUser!.major = maj
                    self.major.text = ""
                    //print("Document successfully updated")
                }
            }
        }
        
        // check if year has been modified
        if (yearString != "") {
            if (yearString == "freshman" || yearString == "sophomore" || yearString == "junior" || yearString == "senior" || yearString == "graduate") {
                collection.document(currentUser!.email).updateData([
                    "year": yearString,
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        self.currentUser!.year = yearString
                        self.year.text = ""
                        //print("Document successfully updated")
                    }
                }
            } else {
                self.errorMessage(banner: invalidYearBanner)
                return
            }
        }
        //check for valid username
        if (newUsername != "") {
            let usernameRegex = try! NSRegularExpression(pattern: "[a-zA-Z0-9]{6,30}")
            let range = NSRange(location: 0, length: (newUsername.utf16.count))
            if (usernameRegex.firstMatch(in: newUsername, options: [], range: range) == nil) {
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
                        if(document.get("username") as! String == newUsername) {
                            self.errorMessage(banner: usedUsernameBanner)
                            return
                        }
                    }
                    collection.document(self.currentUser!.email).updateData([
                        "username": newUsername,
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            self.currentUser!.username = newUsername
                            self.username.text = ""
                            //print("Document successfully updated")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func uploadProfilePicClicked(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerController.SourceType.photoLibrary
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        profilePic.image = self.image
    }
  
    @IBAction func submitProfilePic(_ sender: Any) {
      guard let photoSelected = self.image else {
        return
      }
      
      guard let data = photoSelected.jpegData(compressionQuality: 1.0) else {
        return
      }
      
      let ref = Storage.storage().reference(withPath: "media/" + (Auth.auth().currentUser?.email)! + "/" + "profile.jpeg")
      let metaData = StorageMetadata()
      metaData.contentType = "image/jpg"
      
      ref.putData(data, metadata: metaData) { (metaData, error) in
        if error != nil  {
          // do something
          return
        }
      }
      
      
      let alert = UIAlertController(title: "Success", message: "Succesfully updated profile picture.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true)
      self.profilePic.image = nil
    }
    @IBAction func submitPasswordClicked(_ sender: Any) {
        let passwordNoMatchBanner = Banner(title: "Your password and confirm password must match!", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        passwordNoMatchBanner.dismissesOnTap = true
        
        let invalidPasswordBanner = Banner(title: "Password is too weak!", subtitle: "Password must be at least 8 characters, contain at least one uppercase and at least one lowercase character, and one special character!", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        invalidPasswordBanner.dismissesOnTap = true
        
        let badPasswordBanner = Banner(title: "Your current password is incorrect", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        invalidPasswordBanner.dismissesOnTap = true
        
        let emptyFieldBanner = Banner(title: "Make sure that Current Password, New Password and Confirm Password are input", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        invalidPasswordBanner.dismissesOnTap = true
        
        // Send an error if one of the fields is empty
        if (currentPassword.text == "" || newPassword.text == "" || confirmPassword.text == "") {
            self.errorMessage(banner: emptyFieldBanner)
            return
        }
        
        // obtain email to validate currentPassword
        let email: String = (Auth.auth().currentUser?.email)!
        
        let curPassword = currentPassword.text!
        let nPassword = newPassword.text!
        let conPassword = confirmPassword.text!
        // Authenticate current password is valid
        Auth.auth().signIn(withEmail: email, password: curPassword) { (authResult, error) in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                    case .wrongPassword:
                        // Error: The password is incorrect
                        self.errorMessage(banner: badPasswordBanner)
                        return
                    default:
                        self.errorMessage(banner: badPasswordBanner)
                        return
                }
            } else {
                let passwordRegex = try! NSRegularExpression(pattern: "(?=.*[^A-Za-z0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}")
                let range2 = NSRange(location: 0, length: (nPassword.utf16.count))
                
                // check if the new password and confirm passwords match, if they do check the regex
                if (nPassword != conPassword) {
                    self.errorMessage(banner: passwordNoMatchBanner)
                    return
                } else if (passwordRegex.firstMatch(in: nPassword, options: [], range: range2) == nil) {
                    self.errorMessage(banner: invalidPasswordBanner)
                    return
                } else {
                    Auth.auth().currentUser?.updatePassword(to: nPassword) {
                        error in
                        if (error != nil) {
                            print("error updating password")
                        }
                    }
                    self.currentPassword.text = ""
                    self.newPassword.text = ""
                    self.confirmPassword.text = ""
                }
            }
        }
        
        // if isCorrectPassword, then check to make sure the new passwords match and are valid

        
        
        
    }
    @IBAction func logoutClicked(_ sender: Any) {
        do {
                    try Auth.auth().signOut()
                    self.performSegue(withIdentifier: "toHome", sender: self)
                }
                catch let error as NSError {
                    print("Error logging out user" + error.localizedDescription)
                }
    }
    @IBAction func deleteClicked(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertController.Style.alert)
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [self] (action: UIAlertAction!) in
            //delete user profile pic from storage
            let ref = Storage.storage().reference()
            let imageRef = ref.child("media/" + (self.currentUser?.email)! + "/profile.jpeg")
            imageRef.delete { error in
                if let error = error {
                    print("error deleting user from storage \(error)")
                } else {
                    print("sucess deleting user from stroage")
                }
            }
            
            //delete all user's post from posts collection in database
            //delete all user's posts from their enrolledCourses' posts array
            for post in currentUser!.createdPosts {
                //retrieve post object from database
                let ref = db.collection("posts").document(post)
                ref.getDocument { document, error in
                    if let document = document {
                        let model = try? FirestoreDecoder().decode(Post.self, from: document.data()!)
                        if (model == nil) {
                            print("post object is nil")
                            fatalError()
                        } else {
                            //get the course name and call User.deletePost()
                            let courseName = model?.course
                            currentUser?.deletePost(postId: post, courseName: courseName!)
                        }
                    } else {
                        print("CurrentUser document does not exist")
                    }
                    
                }
               
            }
    
            //remove user from all courses in database that they were enrolled in
            for course in currentUser!.enrolledCourses {
                let courseRef = db.collection("courses").document(course)
                courseRef.updateData([
                    "classmates": FieldValue.arrayRemove([self.currentUser!.email])
                ])
                
            }
            
            let user = Auth.auth().currentUser
            self.db.collection("users").document((self.currentUser?.email)!).delete() {
                error in
                if (error != nil) {
                    print("error deleting user from firestore \(String(describing: error))")
                } else {
                    print("success deleting user from firestore")
                }
            }
            user?.delete { error in
                if let error = error {
                    print("Error deleting user \(error)")
                } else {
                    self.db.collection("users").document((self.currentUser?.email)!).delete()
                    self.performSegue(withIdentifier: "toHome", sender: self)
                }
            }
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            //user does not want to delete their account
            deleteAlert.dismiss(animated: true, completion: nil)
        }))
        present(deleteAlert, animated: true, completion: nil)
    }
    func errorMessage(banner : Banner){
        banner.show(duration: 3)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
  

}

extension SettingsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let photo = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      image = photo
      profilePic.image = photo
    }
    
    if let photoOrig = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      profilePic.image = photoOrig
      image = photoOrig
    }
    
    picker.dismiss(animated: true, completion: nil)
  }
}
