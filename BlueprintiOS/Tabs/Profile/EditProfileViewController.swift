//
//  EditProfileViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 8/10/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
import FirebaseFirestore
//import SCLAlertView
import FirebaseAuth
import FirebaseStorage
//import SDWebImage
import Photos
import ProgressHUD

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changePhotoBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    //private let userUid: String
    var user: User!
    private var profileImageChanged = false
    private var profileImageDeleted = false
    let db = Firestore.firestore()
    private let imagePicker        = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser == nil {
            view.isUserInteractionEnabled = false
            navigationController?.popViewController(animated: false)
        }
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        view.overrideUserInterfaceStyle = .light
      //  navigationController?.toolbar.isHidden = true
        
        navigationController?.isToolbarHidden = true
      //  setupView()
        reloadData()
    //    updateUI()
        // Do any additional setup after loading the view.
    }
    
     func reloadData() {
         if Auth.auth().currentUser != nil {
           
         ProgressHUD.show()
        view.isUserInteractionEnabled = false
        
       // let group = DispatchGroup()
        
        // ---------------------- user ----------------------
      //  group.enter()
         FirestoreManager.getUser(Auth.auth().currentUser!.uid) { user in
            guard let user = user else {
                return print("Could not get User")
            }
            self.user = user
             self.usernameTextField.text = user.username
          //   bioInput.text = user.bio
             
             self.nameTextField.placeholder = "Name"
             self.nameTextField.text = user.name
             self.view.isUserInteractionEnabled = true
        //    group.leave()
        }
        
        // ---------------------- image ----------------------
    //    group.enter()
             StorageManager.getProPic(Auth.auth().currentUser?.uid ?? "eUWpeKULDhN1gZEyaeKvzPNkMEk1") { image in
            self.profileImageView.image = image
           // group.leave()
        }
         ProgressHUD.dismiss()
        
//        group.notify(queue: .main) {
//            self.updateUI()
//        }
         }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          // Try to find next responder
          if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
             nextField.becomeFirstResponder()
          } else {
             // Not found, so remove keyboard.
             textField.resignFirstResponder()
          }
          // Do not add a line break
          return false
       }
    
//     func updateUI() {
//
//     //   activityIndicator.stopAnimating()
//
//        usernameTextField.text = user.username
//     //   bioInput.text = user.bio
//
//        nameTextField.placeholder = User.properName(user.name)
//     //   emailInput.placeholder = user.email
//      //  dateInput.placeholder = DateFormatter.getShortStr(user.date)
//
//        view.isUserInteractionEnabled = true
//    }
    
    private func checkPermissions() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in () })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthroizationHandler)
        }
    }
    
    private func requestAuthroizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("We have access to photos")
        } else {
            print("We dont have access to photos")
        }
    }
    
    @objc func presentImagePicker() {
        self.checkPermissions()
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = true
        self.present(self.imagePicker, animated:  true, completion:  nil)
    }
    
    @IBAction func changePhotoAction(_ sender: Any) {
        self.presentImagePicker()
//        let alert = UIAlertController(title: "Change proile picture", message: nil, preferredStyle: .actionSheet)
//
//        alert.addAction(UIAlertAction(title: "Choose from photo library", style: .default, handler: { _ in
//            self.presentImagePicker()
//        }))
//
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//        present(alert, animated: true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let user = user else {
            return
        }
        
        // no changes made
        if (usernameTextField.text?.lowercased() == user.username) && (nameTextField.text == user.name) {
            navigationController?.popViewController(animated: true)
        }
        
        ProgressHUD.show()
        
        // lowercase username
        usernameTextField.text = usernameTextField.text?.lowercased()
        
        // ----------  validate fields ----------
        if !validateFields() { return }
        
        let trimmedUN = self.usernameTextField.text!.trimmingCharacters(in: .whitespaces)

        
        checkUsername(field: trimmedUN) { (success) in
            if success == true && (self.usernameTextField.text?.lowercased() != user.username) {
                 let alertController = UIAlertController(title: "Error", message: "Username is taken, please choose another.", preferredStyle: UIAlertController.Style.alert)
                 let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                 alertController.addAction(defaultAction)
                 
                 self.present(alertController, animated: true, completion: nil)
                 return
                 ProgressHUD.dismiss()

             } else {
                 
             
                
        // ---------- create update doc ----------
        var updateDoc = [String:Any]()
                 if self.usernameTextField.text != user.username {
            //updateDoc[user.username] = usernameTextField.text
            
           let docRef = self.db.collection("users").document(Auth.auth().currentUser!.uid)

           docRef.updateData([
            "username": self.usernameTextField.text?.lowercased()
           ])
       }
        
                 if self.nameTextField.text != user.name {
            //updateDoc[user.username] = usernameTextField.text
            
           let docRef = self.db.collection("users").document(Auth.auth().currentUser!.uid)

           docRef.updateData([
            "name": self.nameTextField.text
           ])
       }
                          
                       
                   
            
        
//        if usernameTextField.text != user.bio {
//            updateDoc[User.BIO] = bioInput.text
//        }
        
        // ---------- update ----------
        let group = DispatchGroup()
        
        // user info
        group.enter()
        FirestoreManager.updateUser(updateDoc) { success in
            
            if !success {
                return self.alertAndDismiss("We're sorry, your profile cannot be updated at this time. Please try again")
            }
            
            group.leave()
        }
        
        // profile image changed
                 if self.profileImageChanged, let data = self.profileImageView.image?.jpegData(compressionQuality: 0.5) {
            
            group.enter()
            StorageManager.updateProfilePicture(withData: data) { success in
                
                if (success == nil) {
                    return self.alertAndDismiss("We're sorry, your profile cannot be updated at this time. Please try again")
                }
                
                group.leave()
            }
        }
        
        // profile image deleted
                 if self.profileImageDeleted {
            StorageManager.getProPic(Auth.auth().currentUser!.uid) { image in
                
                if image != UIImage(named: "nouser") {
                    
                    group.enter()
                    StorageManager.deleteProPic(self.user.uid) { success in
                        if !success {
                            return self.alertAndDismiss("We're sorry, your profile cannot be updated at this time. Please try again")
                        }
                        
                        group.leave()
                    }
                }
            }
        }
        
        
        
       // group.notify(queue: DispatchQueue.main) {
            
       //     self.activityIndicator.isHidden = true
        ProgressHUD.dismiss()
            
                    
//            let profileVC = self.navigationController?.viewControllers.first as? ProfileViewController
        let profileVC = self.navigationController?.viewControllers.first as? UserProfileViewController
           // profileVC?.collectionView.refreshControl?.beginRefreshing()
          //  profileVC?.reloadData()
            self.navigationController?.popViewController(animated: true)
    //    }
             }}
    }
    
    private func alertAndDismiss(_ message: String) {
        
        //activityIndicator.stopAnimating()
        ProgressHUD.dismiss()
        
        view.isUserInteractionEnabled = true
        
        let alert = UIAlertController(title: "Uh oh!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func validateFields() -> Bool {

        // ------- username -------
        guard let username = usernameTextField.text, username != "" else {
            alertAndDismiss("Username cannot be empty")
            return false
        }
        
        if username.contains(" ") {
            alertAndDismiss("Username cannot contain spaces")
            return false
        }
        
        if username.lowercased() != username {
            alertAndDismiss("Username must be all lowercase")
            return false
        }
        
        
            if username.count > 20 {
                alertAndDismiss("Username must be less than 20 characters")
                return false
            
        }
        
        
//        checkUsername(field: trimmedUN) { (success) in
//             if success == true {
//                 let alertController = UIAlertController(title: "Error", message: "Username is taken", preferredStyle: UIAlertController.Style.alert)
//                 let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                 alertController.addAction(defaultAction)
//
//                 self.present(alertController, animated: true, completion: nil)
//                 return
//             } else {
//
//             }}
        
        return true
    
    }
    
    func checkUsername(field: String, completion: @escaping (Bool) -> Void) {
        let collectionRef = db.collection("users")
        collectionRef.whereField("username", isEqualTo: field).getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting document: \(err)")
            } else if (snapshot?.isEmpty)! {
                completion(false)
            } else {
                for document in (snapshot?.documents)! {
                    if document.data()["username"] != nil {
                        completion(true)
                    }
                }
            }
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageChanged = true
            profileImageView.image = image
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
