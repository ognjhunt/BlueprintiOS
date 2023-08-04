//
//  ChooseLogInViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 1/10/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
//import GoogleSignIn
import FirebaseAuth
import AuthenticationServices


class ChooseLogInViewController: UIViewController, UIGestureRecognizerDelegate { //, GIDSignInDelegate

    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
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
        
        xImgView.isUserInteractionEnabled = true
        let backAction = UITapGestureRecognizer(target: self, action: #selector(back))
        xImgView.addGestureRecognizer(backAction)
        
        facebookView.isUserInteractionEnabled = true
        appleView.isUserInteractionEnabled = true
        googleView.isUserInteractionEnabled = true
        let alertView = UITapGestureRecognizer(target: self, action: #selector(alert))
        let alertView1 = UITapGestureRecognizer(target: self, action: #selector(alert))
        let alertView2 = UITapGestureRecognizer(target: self, action: #selector(alert))

        facebookView.addGestureRecognizer(alertView)
        appleView.addGestureRecognizer(alertView1)
        googleView.addGestureRecognizer(alertView2)
        
        phoneOrEmailView.layer.borderWidth = 0.85
        phoneOrEmailView.layer.borderColor = UIColor.systemGray3.cgColor
        facebookView.layer.borderWidth = 0.85
        facebookView.layer.borderColor = UIColor.systemGray3.cgColor
        appleView.layer.borderWidth = 0.85
        appleView.layer.borderColor = UIColor.systemGray3.cgColor
        googleView.layer.borderWidth = 0.85
        googleView.layer.borderColor = UIColor.systemGray3.cgColor
        
//        let appleSignInButton = ASAuthorizationAppleIDButton()
//        appleSignInButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
//        view.addSubview(appleSignInButton)
        
     

         //In your viewDidLoad() function
//         GIDSignIn.sharedInstance()?.delegate = self
//         GIDSignIn.sharedInstance()?.presentingViewController = self
//         GIDSignIn.sharedInstance()?.signIn()
        
        let normalText1 = "By continuing, you agree to our "
        let boldText1 = "Terms of Service"
        let normalText2 = " and acknowledge that you have read our "
        let boldText2 = "Privacy Policy"
        let normalText3 = " to learn how we collect, use, and share your data."

//        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 11)]
//
//        let attributedString1 = NSMutableAttributedString(string:boldText1, attributes:attrs)
//        let attributedString2 = NSMutableAttributedString(string:boldText2, attributes:attrs)
//
//        let normalString1 = NSMutableAttributedString(string:normalText1)
//        let normalString2 = NSMutableAttributedString(string:normalText2)
//        let normalString3 = NSMutableAttributedString(string:normalText3)
//
//        attributedString1.append(normalString2)
//
//        let first = normalString1.append(attributedString1)
//        let second = first.append
//
//        termsLabel.text = normalString1.append(attributedString1)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func email(){
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInViewController
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
    
    @objc func google(){
       

       

    }
    
    @objc func back (){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func alert(){
        let alert = UIAlertController(title: "Feature Coming Soon", message: "Currently the only way to sign up for Blueprint is to use email. Added functionality for other platforms will be coming soon.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { action in
            //completionHandler(false)
            return
        })
        present(alert, animated: true)
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
    
}

// In your view controller, conform to the GIDSignInDelegate protocol
//extension ChooseLogInViewController: GIDSignInDelegate {
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//        if let error = error {
//            print("Error signing in with Google: \(error.localizedDescription)")
//            return
//        }
//        
//        guard let authentication = user.authentication else { return }
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                      accessToken: authentication.accessToken)
//        
//        // Sign in with Firebase using the credential
//        Auth.auth().signIn(with: credential) { (authResult, error) in
//            if let error = error {
//                print("Error signing in with Firebase: \(error.localizedDescription)")
//                return
//            }
//            
//            // Successfully signed in
//            print("Successfully signed in with Google!")
//        }
//    }
//}

extension ChooseLogInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Use the appleIDCredential to create and sign in the user
            // ...
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
    }
}
