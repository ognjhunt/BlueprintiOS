//
//  ChooseSignUpViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 1/10/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth
//import GoogleSignIn
import FirebaseFirestore
import AuthenticationServices

class ChooseSignUpViewController: UIViewController, UIGestureRecognizerDelegate { //, GIDSignInDelegate, GIDSignInUIDelegate

    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var xImgView: UIImageView!
    @IBOutlet weak var phoneOrEmailView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var googleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = .light
        let email = UITapGestureRecognizer(target: self, action: #selector(email))
        email.delegate = self
        phoneOrEmailView.addGestureRecognizer(email)
        
        
        facebookView.isUserInteractionEnabled = true
        appleView.isUserInteractionEnabled = true
        googleView.isUserInteractionEnabled = true
        let alertView = UITapGestureRecognizer(target: self, action: #selector(alert))
        let alertView1 = UITapGestureRecognizer(target: self, action: #selector(alert))
        let alertView2 = UITapGestureRecognizer(target: self, action: #selector(alert))

        facebookView.addGestureRecognizer(alertView)
        appleView.addGestureRecognizer(alertView1)
        googleView.addGestureRecognizer(alertView2)
        
        xImgView.isUserInteractionEnabled = true
        let backAction = UITapGestureRecognizer(target: self, action: #selector(back))
        xImgView.addGestureRecognizer(backAction)
        
        phoneOrEmailView.layer.borderWidth = 0.85
        phoneOrEmailView.layer.borderColor = UIColor.systemGray3.cgColor
        facebookView.layer.borderWidth = 0.85
        facebookView.layer.borderColor = UIColor.systemGray3.cgColor
        appleView.layer.borderWidth = 0.85
        appleView.layer.borderColor = UIColor.systemGray3.cgColor
        googleView.layer.borderWidth = 0.85
        googleView.layer.borderColor = UIColor.systemGray3.cgColor
        
//        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
//        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().uiDelegate = self
        
        let appleSignInButton = ASAuthorizationAppleIDButton(type: .default, style: .black)
        appleSignInButton.frame = CGRect(x: 16, y: 16, width: view.frame.width - 32, height: 50)
        view.addSubview(appleSignInButton)
        
//        GIDSignInButton(fram)
        
//        termsLabel.attributedText =
//            NSMutableAttributedString()
//                .normal("By continuing, you agree to our ")
//                .bold("Terms of Service")
//                .normal(" and acknowledge that you have read our ")
        
//                .bold("Privacy Policy")
//                .normal(" to learn how we collect, use, and share your data.")
        // Do any additional setup after loading the view.
    }
    @objc func email(){
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpViewController
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    @objc func facebook(){
        
    }
    
    
    @objc func apple(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // In your view controller where you handle the Apple Sign In process

    func handleAppleSignUp(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (result, error) in
            if let error = error {
                // Handle error
                return
            }
            
            guard let authResult = result else { return }
            
            // Create a new user in Firestore
         //   self.saveUser()
//            let user = User(uid: authResult.user.uid, displayName: authResult.user.displayName, email: authResult.user.email)
//            Firestore.firestore().collection("users").document(authResult.user.uid).setData(user.dictionary) { (error) in
//                if let error = error {
//                    // Handle error
//                    return
//                }
//
//                // User has been successfully created in Firestore
//                // Perform any additional actions, such as navigating to the next view controller
//            }
        }
    }

//    func saveUser(){
//        ProgressHUD.show()
//
//       // let uid = Auth.auth().currentUser!.uid
//
////       // let trimmedFN = nameTextField.text!.trimmingCharacters(in: .whitespaces)
////        let trimmedEM = emailTextField.text!.trimmingCharacters(in: .whitespaces)
////        let url1 = URL(string: "gs://blueprint-8c1ca.appspot.com/profileImages/meandryan.jpeg")
//
//        guard let userUid = FirebaseAuthHelper.getCurrentUserUid() else {
//            self.showError("Please try again" as! Error)
//            return print("user not stored locally in Auth")
//        }
//        let referralCode = generateRandomString(length: 8)
//
//        let newUserDoc: [String: Any] = [
//            "uid": userUid,
//            "name": "",
//            "username": "",
//            "points": 500,
//            "amountEarned" : 0.0,
//            "email": authResult.user.email,
//            "date" : Date(),
//            "interactionCount": 0,
//            "latitude": 0,
//            "longitude": 0,
//            "referralCode": referralCode,
//            "modelTypeInteractionCount": 0,
//            "webpageTypeInteractionCount": 0,
//            "messageTypeInteractionCount": 0,
//            "likedAnchorIDs" : [""],
//            "historyNetworkIDs" : [""],
//            "createdNetworkIDs" : [""],
//            "collectedContentIDs" : [""],
//            "photoTypeInteractionCount": 0,
//            "videoTypeInteractionCount": 0,
//            "informationTypeInteractionCount": 0,
//            "collectedContentCount": 0,
//           // "profileImageUrl": url1?.absoluteString,
//            "uploadedContentCount": 0,
//        ]
//
//        FirestoreManager.saveUser(withID: userUid, withData: newUserDoc) { err in
//            if err != nil {
//                self.showError(err as! Error)
//                return print("Error saving user: \(err)")
//            }}
//        ProgressHUD.dismiss()
//        self.goToUsername()
//    }
//
//    @objc func google(){
//        GIDSignIn.sharedInstance().signIn()
//    }
    
    @objc func goToPrivacy() {
        ProgressHUD.show()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PrivacyVC")
        self.present(vc, animated: false, completion: nil)
        ProgressHUD.dismiss()
    }
    
    @objc func goToTerms() {
        ProgressHUD.show()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TermsVC")
        self.present(vc, animated: false, completion: nil)
        ProgressHUD.dismiss()
    }
    
    @objc func alert(){
        let alert = UIAlertController(title: "Feature Coming Soon", message: "Currently the only way to sign up for Blueprint is to use email. Added functionality for other platforms will be coming soon.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { action in
            //completionHandler(false)
            return
        })
        present(alert, animated: true)
    }
    
    @objc func back (){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func logInAction(_ sender: Any) {
    }
    
    @IBAction func termsAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "TermsVC") as! TermsAndConditionsViewController
       // next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    @IBAction func privacyAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyViewController
       // next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//            if let error = error {
//                print("Error signing in with Google: \(error.localizedDescription)")
//                return
//            }
//
//            guard let authentication = user.authentication else { return }
//            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                           accessToken: authentication.accessToken)
//
//            // Sign in to Firebase using the Google credential
//            Auth.auth().createUser(withEmail: user.profile.email, password: "") { (result, error) in
//                if let error = error {
//                    print("Error creating user: \(error.localizedDescription)")
//                    return
//                }
//                guard let user = result?.user else { return }
//                let changeRequest = user.createProfileChangeRequest()
//                changeRequest.displayName = user.profile.name
//                changeRequest.commitChanges(completion: { (error) in
//                    if let error = error {
//                        print("Error updating profile: \(error.localizedDescription)")
//                        return
//                    }
//                    print("User created and logged in with Google!")
//                    // Perform any additional setup for the new user here
//                })
//            }
//        }
//
//        func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//            // Perform any cleanup when the user disconnects from Google
//        }
}

extension ChooseSignUpViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Handle the successful Apple ID sign-in
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            // Use this information to create a new user in your system
            // and authenticate the user in your app
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle the error
    }
}

extension ChooseSignUpViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
