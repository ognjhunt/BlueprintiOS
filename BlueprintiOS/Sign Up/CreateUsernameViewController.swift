//
//  CreateUsernameViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 8/10/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth
import FirebaseFirestore

class CreateUsernameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var backImgView: UIImageView!
    @IBOutlet weak var signUpBtn: UIButton!
    
    var user: User!
    let db = Firestore.firestore()
//    var REF_USERS = self.db.collection("users") //Database.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        usernameTextField.tag = 0
        usernameTextField.becomeFirstResponder()
        backImgView.isUserInteractionEnabled = true
        let backAction = UITapGestureRecognizer(target: self, action: #selector(back))
        backImgView.addGestureRecognizer(backAction)
        
        signUpBtn.isEnabled = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        let uid = Auth.auth().currentUser!.uid
        let randUsername = self.randomString(length: 16)
        self.db.collection("users").getDocuments { (snapshot, err) in
               if let err = err {
                   print("Error getting documents: \(err)")
               } else {
                   for document in snapshot!.documents {
                        //let docId = document.documentID
                        let docRef = self.db.collection("users").document(uid)

                        docRef.updateData([
                            "username": randUsername
                        ])
                       
                       let storyboard = UIStoryboard(name: "Main", bundle: nil)
                      // var next = storyboard.instantiateViewController(withIdentifier: "TabBarVC2") as! TabBarViewController2
                       var next = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController

                       next.modalPresentationStyle = .fullScreen
                       self.present(next, animated: true, completion: nil)
                   }}}
    }
    
    @objc func back(){
        self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func signUpAction(_ sender: Any) {
        if (usernameTextField.text?.count)! > 20{
            let alertController = UIAlertController(title: "Error", message: "Limit username to 20 characters", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let trimmedUN = usernameTextField.text!.trimmingCharacters(in: .whitespaces)
        
        checkUsername(field: trimmedUN) { (success) in
             if success == true {
                 print("Username is taken")
                 self.signUpBtn.isEnabled = false
                 self.signUpBtn.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 242/255, alpha: 1.0)
                 self.signUpBtn.setTitleColor(UIColor.darkGray, for: .normal)
                 let alertController = UIAlertController(title: "Error", message: "Username is taken", preferredStyle: UIAlertController.Style.alert)
                 let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                 alertController.addAction(defaultAction)
                 
                 self.present(alertController, animated: true, completion: nil)
                 return
             } else {
                 print("Username is not taken")
                 // Perform some action
                
             
         
        
        ProgressHUD.show()
        
                 let trimmedUN = self.usernameTextField.text!.trimmingCharacters(in: .whitespaces)
        let uid = Auth.auth().currentUser!.uid
        
           
            self.db.collection("users").getDocuments { (snapshot, err) in
                   if let err = err {
                       print("Error getting documents: \(err)")
                   } else {
                       for document in snapshot!.documents {
                            //let docId = document.documentID
                            let docRef = self.db.collection("users").document(uid)

                            docRef.updateData([
                                "username": trimmedUN
                            ])
                       }}}
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
           // var next = storyboard.instantiateViewController(withIdentifier: "TabBarVC2") as! TabBarViewController2
            var next = storyboard.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController

            next.modalPresentationStyle = .fullScreen
            self.present(next, animated: true, completion: nil)
        ProgressHUD.dismiss()
             }}
    }
    
//    func checkIsUserNameTaken(userName: String, completion: @escaping (_ errorMsg: String?) -> ()) {
//        let REF_USERS = self.db.collection("users")
//        let query = REF_USERS.que .queryOrdered(byChild: "username").queryEqual(toValue: userName)
//        query.observe(.value) { snapshot in
//            completion(snapshot.childrenCount > 0 ? "Username is taken. Please choose another." : nil)
//        }
//    }
    
    var activeTextField = UITextField()

       // Assign the newly active text field to your activeTextField variable
       func textFieldDidBeginEditing(_ textField: UITextField) {

            self.activeTextField = textField
       }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == usernameTextField {
//            let currentText = textField.text ?? ""
//            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
//            
//            if prospectiveText.count >= 3 {
//                checkUsername(field: prospectiveText) { (success) in
//                    if success == true {
//                        print("Username is taken")
//                        self.signUpBtn.isEnabled = false
//                        self.signUpBtn.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 242/255, alpha: 1.0)
//                        self.signUpBtn.setTitleColor(UIColor.darkGray, for: .normal)
//                    } else {
//                        print("Username is not taken")
//                        self.signUpBtn.isEnabled = true
//                        self.signUpBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
//                        self.signUpBtn.setTitleColor(UIColor.white, for: .normal)
//                    }
//                }
//            }
//        }
//        return true
//    }

    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == usernameTextField {
//            checkUsername(field: textField.text!) { (success) in
//                 if success == true {
//                     print("Username is taken")
//                     // Perform some action
//                     self.signUpBtn.isEnabled = false
//                     self.signUpBtn.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 242/255, alpha: 1.0)
//                     self.signUpBtn.setTitleColor(UIColor.darkGray, for: .normal)
//                 } else {
//                     print("Username is not taken")
//                     // Perform some action
//                     self.signUpBtn.isEnabled = true
//                     self.signUpBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
//                     self.signUpBtn.setTitleColor(UIColor.white, for: .normal)
//                 }
//             }
//        }
//        return true
//    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == usernameTextField {
            checkUsername(field: textField.text!) { (success) in
                 if success == true && textField.text != ""{
                     print("Username is taken")
                     self.signUpBtn.isEnabled = false
                     self.signUpBtn.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 242/255, alpha: 1.0)
                     self.signUpBtn.setTitleColor(UIColor.darkGray, for: .normal)
                     let alertController = UIAlertController(title: "Error", message: "Username is taken", preferredStyle: UIAlertController.Style.alert)
                     let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                     alertController.addAction(defaultAction)
                     
                     self.present(alertController, animated: true, completion: nil)
                     return
                 } else {
                     print("Username is not taken")
                     self.signUpBtn.isEnabled = true
                     self.signUpBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
                     self.signUpBtn.setTitleColor(UIColor.white, for: .normal)
                 }
             }
        }
    }

    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if validateFields() {
//            self.signUpBtn.isEnabled = true
//            self.signUpBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
//            self.signUpBtn.setTitleColor(UIColor.white, for: .normal)
//        } else {
//            self.signUpBtn.isEnabled = false
//            self.signUpBtn.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 242/255, alpha: 1.0)
//            self.signUpBtn.setTitleColor(UIColor.lightGray, for: .normal)
//        }
//    }
    
   
    
//    func checkUsername(field: String, completion: @escaping (Bool) -> Void) {
//        let collectionRef = db.collection("users")
//        collectionRef.whereField("username", isEqualTo: field).getDocuments { (snapshot, err) in
//            if let err = err {
//                print("Error getting document: \(err)")
//            } else if (snapshot?.isEmpty)! {
//                completion(false)
//            } else {
//                for document in (snapshot?.documents)! {
//                    if document.data()["username"] != nil {
//                        completion(true)
//                    }
//                }
//            }
//        }
//    }
    
    //USES INDEX
    func checkUsername(field: String, completion: @escaping (Bool) -> Void) {
        let collectionRef = db.collection("users")
        let query = collectionRef.whereField("username", isEqualTo: field).limit(to: 1) // limit the query to only return 1 result
        query.getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting document: \(err)")
                completion(false) // Return false if there is an error
            } else {
                if snapshot?.count ?? 0 > 0 {
                    completion(true) // Return true if there is at least 1 result returned
                } else {
                    completion(false) // Return false if no result returned
                }
            }
        }
    }

    
    
    
    
    
    
}
