//
//  ProfilePictureViewController.swift
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
class ProfilePictureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var db : Firestore!
    var storage: Storage!
    var defaultImage: UIImage!
    var image:UIImage?
    var imageExt: String?
    var photoURL: String?
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    var intermediaryUser = User(fname: "", lname: "", username: "", email: "", major: "", year: "")
    var intermediaryUserTwo: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        storage = Storage.storage()
        defaultImage = UIImage(systemName: "person.crop.circle")
        intermediaryUserTwo = User(fname: self.intermediaryUser.fName, lname: self.intermediaryUser.lName, username: self.intermediaryUser.username, email: self.intermediaryUser.email, major: self.intermediaryUser.major, year: self.intermediaryUser.year)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func uploadClicked(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerController.SourceType.photoLibrary
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        profilePic.image = self.image
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage
        if let userImage = info[.editedImage] as? UIImage {
            image = userImage
        } else if let userImage = info[.originalImage] as? UIImage {
            image = userImage
        } else {
            return
        }
        self.image = image
        self.profilePic.image = image
        self.imageExt = ".png"
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        //upload profile pic to storage
        photoURL = ""
        self.profilePic.image = self.image
        self.uploadImage((self.image ?? defaultImage), completion: { [self]  (state, result) in
            if (!state) {
                print("error uploading profile pic in sign up")
                self.profilePic.image = nil
                return
            } else {
                self.photoURL = result
                intermediaryUserTwo?.pictureURL = result
                self.performSegue(withIdentifier: "toInfo", sender: self)
                return
            }
        })
        
        //intermediaryUserTwo?.pictureURL = (self.photoURL ?? "person.crop.circle")
       // self.performSegue(withIdentifier: "toInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        intermediaryUserTwo?.pictureURL = (self.photoURL ?? "person.crop.circle")
        if(segue.identifier == "toInfo") {
            if let destVC = segue.destination as? InfoViewController {
                destVC.intermediaryUserTwo = self.intermediaryUserTwo!
            }
        }
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (_ hasFinished: Bool, _ url: String) -> Void) {
        let data: Data = image.jpegData(compressionQuality: 1.0)!
        let ref = Storage.storage().reference(withPath: "media/" + self.intermediaryUser.email + "/" + "profile.jpeg")
        ref.putData(data, metadata:nil, completion: { (meta, error) in
            if error == nil {
                //return url
                ref.downloadURL(completion: { (url, error) in
                    if (error != nil) {
                        print("some error happened here \(String(describing: error))")
                        completion(false, "")
                    } else {
                        completion(true, url!.absoluteString)
                    }
                })
            }
            
        })
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "toReg", sender: self)
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
