//
//  CreateAccountViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 1/10/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = .light
//        let alert = UIAlertController(title: "Logout?", message: "Are you sure you want to logout of Blueprint?", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { alert in
//
//            FirebaseAuthHelper.signOut() {
//                self.dismiss(animated: true, completion: nil)
//                let navController = UINavigationController(rootViewController: SignUpViewController())
//               // navController.modalPresentationStyle = .fullScreen
//              //  self.present(navController, animated: false, completion: nil)
//            }
//        }))
//        present(alert, animated: true, completion: nil)
        
//        FirebaseAuthHelper.getCurrentUser { user in
//          //  user.uid
//            if user.uid == nil || user.uid == "" {
//                return
//            } else {
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                var next = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
//               // next.modalPresentationStyle = .fullScreen
//                self.present(next, animated: true, completion: nil)
//            }
//            print("\(user.uid) is user uid")
//          //  user.emailStr
//            print("\(user.emailStr) is user email str")
//        }

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signUpAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
      //  var next = storyboard.instantiateViewController(withIdentifier: "ChooseSignUpVC") as! ChooseSignUpViewController
        var next = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpViewController
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    

}
