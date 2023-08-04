//
//  LogInViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 1/10/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var forgotPWLabel: UILabel!
    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backImgView: UIImageView!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    let searchStackUnderView = UIView(frame: CGRect(x: 0, y: 43, width: UIScreen.main.bounds.width / 2, height: 2))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = .light
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        emailTextField.tag = 0
        passwordTextField.tag = 1
        emailTextField.becomeFirstResponder()
        logInBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        
        backImgView.isUserInteractionEnabled = true
        let backAction = UITapGestureRecognizer(target: self, action: #selector(back))
        backImgView.addGestureRecognizer(backAction)
        
        forgotPWLabel.isUserInteractionEnabled = true
        let forgot = UITapGestureRecognizer(target: self, action: #selector(goToForgot))
        forgotPWLabel.addGestureRecognizer(forgot)
        
        phoneBtn.setTitleColor(.darkGray, for: .normal)
        searchStackUnderView.removeFromSuperview()
 
            emailBtn.setTitleColor(.black, for: .normal)
            searchStackUnderView.backgroundColor = .black
        
        searchStackUnderView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        searchStackUnderView.frame.origin.x = 0

        print("\( searchStackUnderView.frame.origin.x) is searchStackUnderView x")
        stackView.addSubview(searchStackUnderView)
        // Do any additional setup after loading the view.
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
    
    @objc func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func goToForgot(){
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "ForgotPWVC") as! ForgotPasswordViewController
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
    
    @IBAction func logInAction(_ sender: Any) {
          ProgressHUD.show()
          FirestoreManager.loginUser(email: emailTextField.text, password: passwordTextField.text) { error in
              if let error = error {
                  ProgressHUD.dismiss()
                  self.showError(error)// showError(error.localizedDescription)
                  return
              }
              let storyboard = UIStoryboard(name: "Main", bundle: nil)
              let next = storyboard.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
              next.modalPresentationStyle = .fullScreen
              self.present(next, animated: true, completion: nil)
              ProgressHUD.dismiss()
          }
//        ProgressHUD.show()
//
//        FirestoreManager.loginUser(email: emailTextField.text, password: passwordTextField.text) {
//            err in
//
//            if let err = err {
//                return ProgressHUD.showError(err)
//            }
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//         //   var next = storyboard.instantiateViewController(withIdentifier: "TabBarVC2") as! TabBarViewController2
//            var next = storyboard.instantiateViewController(withIdentifier: "LaunchVC") as! LaunchViewController
//            next.modalPresentationStyle = .fullScreen
//            self.present(next, animated: true, completion: nil)
//            ProgressHUD.dismiss()
//
//        }
    }
    
    var activeTextField = UITextField()

       // Assign the newly active text field to your activeTextField variable
    func textFieldDidBeginEditing(_ textField: UITextField) {

            self.activeTextField = textField
       }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("\(String(describing: emailTextField.text)) is EM text field text")
//        print("\(String(describing: passwordTextField.text)) is PW text field text")
//        if activeTextField == passwordTextField {
//            if textField.text?.isEmpty == false && (passwordTextField.text?.count)! >= 6 && (emailTextField.text?.count)! > 0 && (emailTextField.text)! != "" {
//                self.logInBtn.isEnabled = true
//                self.logInBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
//                self.logInBtn.setTitleColor(UIColor.white, for: .normal)
//            }
//        }
//
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == passwordTextField || textField == emailTextField {
            let updatedCount = passwordTextField.text!.count + string.count - range.length
            if updatedCount >= 6 && emailTextField.isValidEmail() {
                logInBtn.isEnabled = true
                logInBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
                logInBtn.setTitleColor(.white, for: .normal)
            } else if !emailTextField.isValidEmail() {
                logInBtn.isEnabled = false
                logInBtn.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 242/255, alpha: 1.0)
                logInBtn.setTitleColor(.lightGray, for: .normal)
            }
        }
        return true
    }


    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if emailTextField.isValidEmail() && passwordTextField.isValidPassword() {
            logInBtn.isEnabled = true
            logInBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
            logInBtn.setTitleColor(.white, for: .normal)
        } else {
            logInBtn.isEnabled = false
            logInBtn.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 242/255, alpha: 1.0)
            logInBtn.setTitleColor(.lightGray, for: .normal)
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
    
}

extension UITextField {
    func isValidPassword() -> Bool {
        guard let text = text else { return false }
        return text.count >= 6
    }

    func isValidEmail() -> Bool {
        guard let text = text else { return false }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: text)
    }
}
