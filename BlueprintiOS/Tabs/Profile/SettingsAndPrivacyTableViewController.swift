//
//  SettingsAndPrivacyTableViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 8/9/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsAndPrivacyTableViewController: UITableViewController {

    @IBOutlet weak var deleteAccountBtn: UIButton!
    @IBOutlet weak var goToEditProfileBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad() //tableView
        view.overrideUserInterfaceStyle = .light
      //  navigationItem.titleColor = UIColor.black //.titleView?.tintColor = .black
//        signUpBtn.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        if Auth.auth().currentUser != nil {
            signUpBtn.isHidden = true
         //   goToEditProfileBtn.isHidden = false
                //   goToEditProfileBtn.isEnabled = true
        } else {
          //  goToEditProfileBtn.isHidden = true
          //  goToEditProfileBtn.isEnabled = false
        }
        signUpBtn.layer.cornerRadius = 3
        signUpBtn.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        
        let view1 = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.67))
        view1.backgroundColor = UIColor.systemGray5
        view.addSubview(view1)
//        if #available(iOS 15.0, *) {
//            tableView.sectionHeaderTopPadding = 0
//        } else {
//            // Fallback on earlier versions
//        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if Auth.auth().currentUser != nil {
          return 5
        } else {
            return 4

        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if section == 0 {
            return 1
        } else if section == 1{
           return 1// return 4
        } else if section == 2 {
            return 2
        } else if section == 4{
            return 2
        }
        return 3
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
       let view = UIView()
       view.backgroundColor = UIColor.systemGray5
       return view
   }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.67
   }
    
    @objc func signUp(){
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpViewController
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
//    @objc func contacts(){
//        let fir = ContactsViewController()
//        fir.modalPresentationStyle = .fullScreen
//        self.present(fir, animated: true, completion: nil)
////        self.window?.rootViewController = UINavigationController(rootViewController: fir)
////        self.navigationController?.pushViewController(vc, animated: true)
//
//    }
    
    @IBAction func goToEditProfile(_ sender: Any) {
        if Auth.auth().currentUser != nil {
        } else {
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            var next = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpViewController
            next.modalPresentationStyle = .fullScreen
            self.present(next, animated: true, completion: nil)
        }
      
    }
    
    @objc private func logoutTapped() {
        
        let alert = UIAlertController(title: "Logout?", message: "Are you sure you want to logout of Blueprint?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { alert in
            
            FirebaseAuthHelper.signOut() {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
               // print("\(LaunchViewController.auth.currentUser?.uid) is the current user id")
                
                var next = storyboard.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
                next.modalPresentationStyle = .fullScreen
                self.present(next, animated: true, completion: nil)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func deleteTapped() {
        
        let alert = UIAlertController(title: "Delete Account?", message: "Are you sure you want to delete your account? This will delete all of your data :(", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete Account", style: .destructive, handler: { alert in
            
                FirestoreManager.deleteAccount { success in
                    FirebaseAuthHelper.signOut() {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    // print("\(LaunchViewController.auth.currentUser?.uid) is the current user id")
                    
                    var next = storyboard.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
                    next.modalPresentationStyle = .fullScreen
                    self.present(next, animated: true, completion: nil)
                }
            }}))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        logoutTapped()
    }
    
    @IBAction func deleteAccountAction(_ sender: Any) {
        deleteTapped()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}
