//
//  SignUpViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 1/10/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var logInLabel: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backImgView: UIImageView!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    let searchStackUnderView = UIView(frame: CGRect(x: 0, y: 44, width: UIScreen.main.bounds.width / 2, height: 2))
    private let termsString = "https://termsfeed.com/terms-conditions/faf23cd7494e7eccca3c27770ee492c3"
    private let privacyString = "https://privacypolicies.com/privacy/view/91355dcc8ea9a848914259215ca31aef"
    var selectedImage: UIImage?
    var user: User!
    var activeId: String?
    
    let db = Firestore.firestore()
   // var REF_USERS = db.collection("anchors")// Database.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = .light
        emailTextField.delegate = self
    //    nameTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
//        nameTextField.tag = 0
        emailTextField.tag = 0
        passwordTextField.tag = 1
        emailTextField.becomeFirstResponder()
        
        backImgView.isUserInteractionEnabled = true
        let backAction = UITapGestureRecognizer(target: self, action: #selector(back))
        backImgView.addGestureRecognizer(backAction)
        
      //  stackView.addSubview(searchStackUnderView)
        
        signUpBtn.isEnabled = false
        
       // phoneAction()
        
        
        logInLabel.isUserInteractionEnabled = true
        let logInAction = UITapGestureRecognizer(target: self, action: #selector(goToLogin))
        logInLabel.addGestureRecognizer(logInAction)
        // Do any additional setup after loading the view.
        
        phoneBtn.setTitleColor(.darkGray, for: .normal)
        searchStackUnderView.removeFromSuperview()
 
            emailBtn.setTitleColor(.black, for: .normal)
            searchStackUnderView.backgroundColor = .black
        
        searchStackUnderView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        searchStackUnderView.frame.origin.x = 0

        print("\( searchStackUnderView.frame.origin.x) is searchStackUnderView x")
        stackView.addSubview(searchStackUnderView)
    }
    
    private func moveToMain() {
        ProgressHUD.dismiss()
        self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
       // var next = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
        var next = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let tryAgain = UIAlertAction(title: "Try Again", style: .default) { _ in
           // do your logic for try again
        }
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel)
        alert.addAction(tryAgain)
        alert.addAction(dismiss)
        present(alert, animated: true)
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        view.isUserInteractionEnabled = false
        ProgressHUD.show()
        self.validateFields()
        createProfile()
        ProgressHUD.dismiss()
        view.isUserInteractionEnabled = true
    }
    
    @objc func back (){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func goToLogin(){
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInViewController
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    @objc func goToUsername(){
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "CreateUsernameVC") as! CreateUsernameViewController
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func phoneAction(_ sender: Any) {
        phoneBtn.setTitleColor(.black, for: .normal)
        searchStackUnderView.removeFromSuperview()
 
            emailBtn.setTitleColor(.darkGray, for: .normal)
            searchStackUnderView.backgroundColor = .black
        searchStackUnderView.frame.origin.x =  UIScreen.main.bounds.width / 2
        searchStackUnderView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        print("\( searchStackUnderView.frame.origin.x) is searchStackUnderView x")
        stackView.addSubview(searchStackUnderView)
    }
    
    @IBAction func emailAction(_ sender: Any) {
        phoneBtn.setTitleColor(.darkGray, for: .normal)
        searchStackUnderView.removeFromSuperview()
 
            emailBtn.setTitleColor(.black, for: .normal)
            searchStackUnderView.backgroundColor = .black
        
        searchStackUnderView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        searchStackUnderView.frame.origin.x = 0

        print("\( searchStackUnderView.frame.origin.x) is searchStackUnderView x")
        stackView.addSubview(searchStackUnderView)
    }
    
    
//    private func validateFields() { //completion: @escaping () -> Void
//
//        guard let email = emailTextField.text, email != "" else {
//            return //showError("Must enter an email")
//        }
//
//        guard let password = passwordTextField.text, password != "" else {
//            return //showError("Please enter a password")
//        }
//
//        if (passwordTextField.text?.count)! < 6 {
//            let alertController = UIAlertController(title: "Error", message: "Password must be at least 6 characters", preferredStyle: UIAlertController.Style.alert)
//            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alertController.addAction(defaultAction)
//            self.present(alertController, animated: true, completion: nil)
//            return
//        }
//    }
    
    private func validateFields() -> Bool {
        guard let email = emailTextField.text, email.count > 0, email.contains("@") && email.contains(".") else {
            return false
        }

        guard let password = passwordTextField.text, password.count >= 6 else {
            return false
        }

        return true
    }
    
    var activeTextField = UITextField()

       // Assign the newly active text field to your activeTextField variable
    func textFieldDidBeginEditing(_ textField: UITextField) {

            self.activeTextField = textField
       }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == passwordTextField || textField == emailTextField {
            let updatedCount = passwordTextField.text!.count + string.count - range.length
            if updatedCount >= 6 && emailTextField.isValidEmail() {
                signUpBtn.isEnabled = true
                signUpBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
                signUpBtn.setTitleColor(.white, for: .normal)
            } else if !emailTextField.isValidEmail() {
                signUpBtn.isEnabled = false
                signUpBtn.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 242/255, alpha: 1.0)
                signUpBtn.setTitleColor(.lightGray, for: .normal)
            }
        }
        return true
    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if validateFields() {
            self.signUpBtn.isEnabled = true
            self.signUpBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
            self.signUpBtn.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.signUpBtn.isEnabled = false
            self.signUpBtn.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 242/255, alpha: 1.0)
            self.signUpBtn.setTitleColor(UIColor.lightGray, for: .normal)
        }
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("\(String(describing: emailTextField.text)) is EM text field text")
//        print("\(String(describing: passwordTextField.text)) is PW text field text")
//        if activeTextField == passwordTextField {
//            if textField.text?.isEmpty == false && (passwordTextField.text?.count)! >= 6 && (emailTextField.text?.count)! > 0 && (emailTextField.text)! != "" {
//                self.signUpBtn.isEnabled = true
//                self.signUpBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
//                self.signUpBtn.setTitleColor(UIColor.white, for: .normal)
//            }
//        }
//
//    }
    
    
//    private func registerUser() { //completion: @escaping () -> Void
//        guard let email = emailTextField.text, email != "" else {
//            return showError("Must enter a email")
//        }
//
//        guard let password = passwordTextField.text, password != "" else {
//            return showError("Please enter a password")
//        }
//
//        FirebaseAuthHelper.registerAuthUser(email: email, password: password) { err in
//            if let err = err {
//                return self.showError(err)
//            }
//
//            //completion()
//        }
//    }
//
//    private func saveUser() { //completion: @escaping () -> Void
//
//        guard let userUid = FirebaseAuthHelper.getCurrentUserUid() else {
//            self.showError("Please try again")
//            return print("user not stored locally in Auth")
//        }
//
//        let newUserDoc: [String: Any] = [
//            "uid": userUid,
//            "username": "",
//            "email": self.emailTextField.text!,
//            "name" : "",
//            "bio" : "",
//            "date" : Date(),
//            "location" : ""
//        ]
//
//        FirestoreManager.saveUser(withID: userUid, withData: newUserDoc) { err in
//            if err != nil {
//                self.showError("Please try again")
//                return print("Error saving user: \(err)")
//            }
//
//            self.goToUsername()
//        }
//    }
    func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func saveUser(){
        ProgressHUD.show()
        
       // let uid = Auth.auth().currentUser!.uid

       // let trimmedFN = nameTextField.text!.trimmingCharacters(in: .whitespaces)
        let trimmedEM = emailTextField.text!.trimmingCharacters(in: .whitespaces)
        let url1 = URL(string: "gs://blueprint-8c1ca.appspot.com/profileImages/meandryan.jpeg")
            
        guard let userUid = FirebaseAuthHelper.getCurrentUserUid() else {
            self.showError("Please try again" as! Error)
            return print("user not stored locally in Auth")
        }
        let referralCode = generateRandomString(length: 8)

        let newUserDoc: [String: Any] = [
            "uid": userUid,
            "name": "",
            "username": "",
            "points": 500,
            "amountEarned" : 0.0,
            "email": trimmedEM,
            "date" : Date(),
            "interactionCount": 0,
            "latitude": 0,
            "longitude": 0,
            "referralCode": referralCode,
            "modelTypeInteractionCount": 0,
            "webpageTypeInteractionCount": 0,
            "messageTypeInteractionCount": 0,
            "likedAnchorIDs" : [""],
            "historyNetworkIDs" : [""],
            "createdNetworkIDs" : [""],
            "collectedContentIDs" : [""],
            "photoTypeInteractionCount": 0,
            "numSessions": 1,
            "videoTypeInteractionCount": 0,
            "informationTypeInteractionCount": 0,
            "collectedContentCount": 0,
           // "profileImageUrl": url1?.absoluteString,
            "uploadedContentCount": 0,
        ]

        FirestoreManager.saveUser(withID: userUid, withData: newUserDoc) { err in
            if err != nil {
                self.showError(err as! Error)
                return print("Error saving user: \(err)")
            }}
        ProgressHUD.dismiss()
        self.goToUsername()
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
    

    
    func isValidPhone(testStr:String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: testStr)
        return result
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func createProfile() {
        ProgressHUD.show()
        
   //     let uid = Auth.auth().currentUser!.uid

       // let trimmedFN = nameTextField.text!.trimmingCharacters(in: .whitespaces)
        let trimmedEM = emailTextField.text!.trimmingCharacters(in: .whitespaces)
        let url1 = URL(string: "gs://blueprint-8c1ca.appspot.com/profileImages/meandryan.jpeg")

        
        FirebaseAuthHelper.registerAuthUser(email: trimmedEM, password: passwordTextField.text!) { err in
            
            if let err = err {
                ProgressHUD.dismiss()
                self.emailTextField.becomeFirstResponder()
            //    self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                return self.showAlert(err)
            }
            self.saveUser()
        }
      
    }
}
