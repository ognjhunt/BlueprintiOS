//
//  ForgotPasswordViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 8/9/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase
import FirebaseAuth

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backImgView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        emailTextField.tag = 0
        emailTextField.becomeFirstResponder()
        backImgView.isUserInteractionEnabled = true
        let backAction = UITapGestureRecognizer(target: self, action: #selector(back))
        backImgView.addGestureRecognizer(backAction)
        sendBtn.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    @objc func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
    
    func alertWrongEmail() {
        let alert = UIAlertController(title: "Warning", message: "Email address is badly formatted", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    var activeTextField = UITextField()

       // Assign the newly active text field to your activeTextField variable
    func textFieldDidBeginEditing(_ textField: UITextField) {

            self.activeTextField = textField
       }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("\(String(describing: emailTextField.text)) is EM text field text")
       // print("\(String(describing: passwordTextField.text)) is PW text field text")
        if activeTextField == emailTextField {
            if textField.text?.isEmpty == false && (emailTextField.text?.count)! > 0 && (emailTextField.text)! != "" {
                self.sendBtn.isEnabled = true
                self.sendBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
                self.sendBtn.setTitleColor(UIColor.white, for: .normal)
            }
        }

    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    

    @IBAction func sendAction(_ sender: Any) {
        // Validation
        guard let email = emailTextField.text else {
            return ProgressHUD.showError("Please enter an email")
        }
        
        ProgressHUD.show()
        FirebaseAuthHelper.sendPasswordReset(email: email) { errStr in
            
            if let errStr = errStr {
                return ProgressHUD.showError(errStr)
            }
            
            ProgressHUD.dismiss()
            let alert = UIAlertController(title: "Email Sent!", message: "An email was sent to \(email) with a password reset link. Follow this link to change your password then try logging in again!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}
