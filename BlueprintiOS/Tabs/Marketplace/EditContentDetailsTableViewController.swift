//
//  EditContentDetailsTableViewController.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 12/26/22.
//

import UIKit
import FirebaseFirestore
import ProgressHUD
import FirebaseAuth

class EditContentDetailsTableViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var backBarButton: UIBarButtonItem!
    
    var modelUid  : String! //      : String
    var modelName = ""
    var model           : Model!
    //private let cloudStorage = Storage.storage()
    
    internal static func instantiate(with modelId: String) -> EditContentDetailsTableViewController {

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditContentDetailsTableVC") as! EditContentDetailsTableViewController
        vc.modelUid = modelId
        return vc
    }
    
    var price = -1
    var name = ""
    var descriptionText = ""
    var isPublic = true
    
    var newPrice = -1
    var newName = ""
    var newDescription = ""
    var newPublic = true
    
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = .light
     //   self.navigationController?.title = "Upload"
        
        let dismissKey = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissKey)
//        tableView.register(GeneratedContentImageTableViewCell.self, forCellReuseIdentifier: "contentImageCell")
        tableView.register(UploadContentTableViewCell.self, forCellReuseIdentifier: "saveContentCell")
       // tableView.register(ContentPromptTableViewCell.self, forCellReuseIdentifier: "contentPromptCell")
        tableView.register(ContentDescriptionTableViewCell.self, forCellReuseIdentifier: "contentDescriptionCell")
        tableView.register(ContentPriceTableViewCell.self, forCellReuseIdentifier: "contentPriceCell")
        tableView.register(ContentPublicTableViewCell.self, forCellReuseIdentifier: "contentPublicCell")
        tableView.register(ContentNameTableViewCell.self, forCellReuseIdentifier: "contentNameCell")
        tableView.register(DeleteContentTableViewCell.self, forCellReuseIdentifier: "deleteContentCell")
        //setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupView()
    }
    
    func setupView(){
        FirestoreManager.getModel(modelUid) { model in
            //let id = model?.id
            self.price = model?.price ?? 0
            self.name = model?.name ?? ""
            self.descriptionText = model?.description ?? ""
            self.isPublic = ((model?.isPublic) != nil)
            
            
            let index = IndexPath(row: 0, section: 0)
            guard let cell = self.tableView.cellForRow(at: index) as? ContentNameTableViewCell else {
               print("Error: Cell is nil")
               return
            }
//            let cell: ContentNameTableViewCell = self.tableView.cellForRow(at: index) as! ContentNameTableViewCell
            cell.nameTextField.text = self.name
            
            
            let index1 = IndexPath(row: 3, section: 0)
            let cell1: ContentPriceTableViewCell = self.tableView.cellForRow(at: index1) as! ContentPriceTableViewCell
            cell1.priceTextField.text = "\(self.price)"
           // self.price = Int(text)!
            
            let index2 = IndexPath(row: 1, section: 0)
            let cell2: ContentDescriptionTableViewCell = self.tableView.cellForRow(at: index2) as! ContentDescriptionTableViewCell
            cell2.descriptionTextView.text = self.descriptionText
            
            
            
        }
    }
    
    

    var activeTextField = UITextField()

       // Assign the newly active text field to your activeTextField variable
       func textFieldDidBeginEditing(_ textField: UITextField) {

            self.activeTextField = textField
       }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

//        if activeTextField == usernameTextField {
//            if textField.text?.isEmpty == false {
//               checkUsername(field: textField.text!) { (success) in
//                    if success == true {
//                        print("Username is taken")
//                        // Perform some action
//                        self.signUpBtn.isEnabled = false
//                        self.signUpBtn.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 242/255, alpha: 1.0)
//                        self.signUpBtn.setTitleColor(UIColor.darkGray, for: .normal)
//                    } else {
//                        print("Username is not taken")
//                        // Perform some action
//                        self.signUpBtn.isEnabled = true
//                        self.signUpBtn.backgroundColor = UIColor(red: 66/255, green: 126/255, blue: 250/255, alpha: 1.0)
//                        self.signUpBtn.setTitleColor(UIColor.white, for: .normal)
//                    }
//                }
//            }
//        }

    }
    
    @IBAction func publicAlert(_ sender: Any) {
        let alertController = UIAlertController(title: "Blueprint Marketplace", message: "Making your content public allows it to be shown on Blueprint's Marketplace for other users to find and use in their designs. Making it private, means that only you can see it within your profile.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (_) in
           
        })
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func priceAlert(_ sender: Any) {
        let alertController = UIAlertController(title: "Pricing", message: "This is the amount you decide to sell your created content for on Blueprint's Marketplace. Whenever a user purchases this content, you'll earn the set amount of credits.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (_) in
           

        })
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Optional"
            textView.textColor = UIColor.lightGray
        } else {
//            if self.modelBtn.backgroundColor == .systemBlue || self.imageBtn.backgroundColor == .systemBlue {
//                self.createBtn.backgroundColor = .tintColor
//            } else {
//                self.createBtn.backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1)
//            }
        }
    
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
        let index = IndexPath(row: 0, section: 0)
        let cell: ContentNameTableViewCell = self.tableView.cellForRow(at: index) as! ContentNameTableViewCell
        newName = cell.nameTextField.text ?? ""
        
        // ------- username -------
        guard let name = cell.nameTextField.text, name != "" else {
            alertAndDismiss("Item name cannot be empty")
            return false
        }
        
        
        
        return true
    
    }

    @objc func dismissKeyboard() {
      //  searchBar.isHidden = true
        view.endEditing(true)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 5
        }
        return 1
    }
    
    @objc func saveContent(){
        let index = IndexPath(row: 0, section: 0)
        let cell: ContentNameTableViewCell = self.tableView.cellForRow(at: index) as! ContentNameTableViewCell
        newName = cell.nameTextField.text ?? ""
        
        let index1 = IndexPath(row: 3, section: 0)
        let cell1: ContentPriceTableViewCell = self.tableView.cellForRow(at: index1) as! ContentPriceTableViewCell
        let pr = cell1.priceTextField.text
        newPrice = Int(pr ?? "")!
       // self.price = Int(text)!
        
        let index2 = IndexPath(row: 1, section: 0)
        let cell2: ContentDescriptionTableViewCell = self.tableView.cellForRow(at: index2) as! ContentDescriptionTableViewCell
        newDescription = cell2.descriptionTextView.text
        
        
        
        // no changes made
        if (self.newPrice == self.price) && (self.newDescription == self.descriptionText) && (self.newName == self.name){
            navigationController?.popViewController(animated: true)
            return
        }
        
        ProgressHUD.show()
        
       
        // ----------  validate fields ----------
        if !validateFields() { return }
             
                
        // ---------- create update doc ----------
        var updateDoc = [String:Any]()
                 
        if self.newName != self.name {
            //updateDoc[user.username] = usernameTextField.text
            
           let docRef = self.db.collection("models").document(modelUid)

           docRef.updateData([
            "name": self.newName
           ])
       }
        
        if self.newPrice != self.price {
            //updateDoc[user.username] = usernameTextField.text
            
           let docRef = self.db.collection("models").document(modelUid)

           docRef.updateData([
            "price": self.newPrice
           ])
       }
        
        if self.newDescription != self.descriptionText {
            //updateDoc[user.username] = usernameTextField.text
            
           let docRef = self.db.collection("models").document(modelUid)

           docRef.updateData([
            "description": self.newDescription
           ])
       }
                          
        ProgressHUD.dismiss()
        self.dismiss(animated: true)
    //    }
             
    }
    
    
    @objc func deleteContent(){
        let alertController = UIAlertController(title: "Delete Content?", message: "Are you sure you want to delete this content? It will be deleted from the Marketplace and your Profile and impossible to get back.", preferredStyle: .alert)
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            ProgressHUD.show("Loading")
            FirestoreManager.deleteModel(self.modelUid) { error in
                if error != nil {
                    ProgressHUD.showError("Unable to delete at this time")
                   print("Error - delete not working")
                  // completion(false)
                   return
                }
                let docRef2 = self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
                docRef2.updateData([
                    "uploadedContentCount": FieldValue.increment(Int64(-1))
                ])
                ProgressHUD.dismiss()
                let defaults = UserDefaults.standard
                
            //    defaults.set("\(self.modelUid ?? "")", forKey: "modelUid")
                defaults.set(true, forKey: "showContentDeleted")
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                return
                
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
           
        })
        alertController.addAction(delete)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && indexPath.section == 0 {
              guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentNameTableViewCell.identifier, for: indexPath) as? ContentNameTableViewCell else {
                  return UITableViewCell()
              }
              tableView.rowHeight = 96
            //  cell.nameTextField.text = self.name
                return cell
          }
//           if indexPath.row == 1 {
//               guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentPromptTableViewCell.identifier, for: indexPath) as? ContentPromptTableViewCell else {
//                   return UITableViewCell()
//               }
//               tableView.rowHeight = 96
//                 return cell
//           }
        if indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentDescriptionTableViewCell.identifier, for: indexPath) as? ContentDescriptionTableViewCell else {
                return UITableViewCell()
            }
            tableView.rowHeight = 126
         //   cell.descriptionTextView.text = self.description
              return cell
        }
        if indexPath.row == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentPublicTableViewCell.identifier, for: indexPath) as? ContentPublicTableViewCell else {
                return UITableViewCell()
            }
            tableView.rowHeight = 60
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.publicAlert))
            cell.infoImageView.addGestureRecognizer(tap)
            
            return cell
        }
        if indexPath.row == 3 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentPriceTableViewCell.identifier, for: indexPath) as? ContentPriceTableViewCell else {
                return UITableViewCell()
            }
            tableView.rowHeight = 60
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.priceAlert))
            cell.infoImageView.addGestureRecognizer(tap)
         //   cell.priceTextField.text = self.price
            let text = cell.priceTextField.text
          //  price = Int(text ?? "")!
            
            return cell
        }
        
        if indexPath.row == 4 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UploadContentTableViewCell.identifier, for: indexPath) as? UploadContentTableViewCell else {
                return UITableViewCell()
            }
          //  let cell = tableView.dequeueReusableCell(withIdentifier: "saveContentCell", for: indexPath)
            tableView.rowHeight = 70
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.saveContent))
            cell.uploadButton.addGestureRecognizer(tap)
            return cell
        }
        if indexPath.row == 0 && indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DeleteContentTableViewCell.identifier, for: indexPath) as? DeleteContentTableViewCell else {
                return UITableViewCell()
            }
            tableView.rowHeight = 70
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.deleteContent))
            cell.deleteButton.addGestureRecognizer(tap)
              return cell
          }
         return UITableViewCell()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
   
    
    @IBAction func deleteAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Content?", message: "Are you sure you want to delete this ____? It will be deleted from the Marketplace and your Profile and impossible to get back.", preferredStyle: .alert)
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            FirestoreManager.deleteModel(self.modelUid) { error in
                if error != nil {
                   print("Error - delete not working")
                  // completion(false)
                   return
               }
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
           
        })
        alertController.addAction(delete)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    

}
