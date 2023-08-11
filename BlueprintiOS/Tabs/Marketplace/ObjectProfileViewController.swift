//
//  ObjectProfileViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 7/11/20.
//  Copyright © 2020 Placenote. All rights reserved.
//

import UIKit
import QuickLook
import ARKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import ProgressHUD


protocol ObjectProfileViewControllerDelegate: class {
    func downloadContentFromMarketplace()
}
class ObjectProfileViewController: UIViewController, QLPreviewControllerDataSource, UITableViewDelegate, UITableViewDataSource{


    @IBOutlet weak var previewImgTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsImg: UIImageView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var previewImg: UIImageView!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var objectNameLabel: UILabel!
    @IBOutlet weak var objectDescriptionLabel: UILabel!
    @IBOutlet weak var objectPriceLabel: UILabel!
    @IBOutlet weak var objectIDLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var modelUid  : String! //      : String
    var modelName = ""
    var model           : Model!
    var description1 = ""
    
    //MARK: --- Override ---
//    init(modelUid: String) {
//        self.modelUid = modelUid
//        super.init(nibName: nil, bundle: nil)
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    weak var delegation: ObjectProfileViewControllerDelegate?
    
    internal static func instantiate(with modelId: String) -> ObjectProfileViewController {

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ObjectProfileVC") as! ObjectProfileViewController
        vc.modelUid = modelId
        return vc
    }
    
    let db = Firestore.firestore()

    var userPoints = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    var isCollected = false
    
    var creatorUid = ""
    
    var isCreator = false
    
    var isImage = false
    
    func setupView(){
        tableView.delegate = self
        tableView.dataSource = self
        objectImageView.contentMode = .scaleAspectFill
        
        FirestoreManager.getModel(modelUid) { model in
            self.price = model?.price ?? 0
            self.name = model?.name ?? ""
            self.modelName = model?.modelName ?? ""
            if self.modelName == "" {
                self.isImage = true
            }
            self.creatorUid = model?.creatorId ?? ""
            if self.creatorUid == Auth.auth().currentUser?.uid ?? "" {
                self.isCreator = true
                self.previewImgTrailingConstraint.constant = -148
                self.settingsImg.isHidden = false
                self.settingsImg.isUserInteractionEnabled = true
            }
            self.description1 = model?.description ?? ""
           // self.productLink = model?.productLink ?? ""
//            if price != 0 {
//                self.downloadButton.setTitle("Purchase (\(price ?? 0) points)", for: .normal)
//            } else {
//                self.downloadButton.setTitle("Add to Library", for: .normal)
//            }
           
                let thumbnailName = model?.thumbnail
                StorageManager.getModelThumbnail(thumbnailName ?? "") { image in
                    self.objectImageView.image = image
                }
        }
        if Auth.auth().currentUser != nil {
            FirestoreManager.getUser(Auth.auth().currentUser?.uid ?? "") { user in
                self.userPoints = user?.points ?? 0
                if user?.collectedContentIDs.contains(self.modelUid) == true {
                    self.isCollected = true
                }
            }
        }
        
        
        let arButton = UIButton(frame: CGRect(x: 295, y: 645, width: 70, height: 70))
        backImg.layer.cornerRadius = 22.5
        backImg.layer.shadowRadius = 3
        backImg.layer.shadowOpacity = 0.95
        backImg.layer.shadowColor = UIColor.black.cgColor
        //note.view?.layer.cornerRadius = 5
        backImg.layer.masksToBounds = false
        backImg.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        
//        likeBtn.layer.cornerRadius = 20
//        likeBtn.layer.shadowRadius = 3
//        likeBtn.layer.shadowOpacity = 0.95
//        likeBtn.layer.shadowColor = UIColor.black.cgColor
//        //note.view?.layer.cornerRadius = 5
//        likeBtn.layer.masksToBounds = false
//        likeBtn.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        
        shareButton.layer.cornerRadius = 20
        shareButton.layer.shadowRadius = 3
        shareButton.layer.shadowOpacity = 0.95
        shareButton.layer.shadowColor = UIColor.black.cgColor
        //note.view?.layer.cornerRadius = 5
        shareButton.layer.masksToBounds = false
        shareButton.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        
        previewImg.layer.cornerRadius = 22.5
        previewImg.layer.shadowRadius = 3
        previewImg.layer.shadowOpacity = 0.95
        previewImg.layer.shadowColor = UIColor.black.cgColor
        //note.view?.layer.cornerRadius = 5
        previewImg.layer.masksToBounds = false
        previewImg.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        
        likeImg.layer.cornerRadius = 22.5
        likeImg.layer.shadowRadius = 3
        likeImg.layer.shadowOpacity = 0.95
        likeImg.layer.shadowColor = UIColor.black.cgColor
        //note.view?.layer.cornerRadius = 5
        likeImg.layer.masksToBounds = false
        likeImg.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        
  //      if self.isCreator == true {
    //        self.previewImgTrailingConstraint.constant = -148
    //        self.settingsImg.isHidden = false
    //        self.settingsImg.isUserInteractionEnabled = true
    //    }
        settingsImg.layer.cornerRadius = 22.5
        settingsImg.layer.shadowRadius = 3
        settingsImg.layer.shadowOpacity = 0.95
        settingsImg.layer.shadowColor = UIColor.black.cgColor
        //note.view?.layer.cornerRadius = 5
        settingsImg.layer.masksToBounds = false
        settingsImg.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToContentSettings))
        settingsImg.addGestureRecognizer(tap)
       // backBtn.backgroundColor = UIColor.systemBlue
       // arButton.backgroundColor = UIColor(red: 25, green: 79, blue: 222, alpha: 1)
       // arButton.clipsToBounds = true
       // arButton.layer.masksToBounds = false
     //   let preview = UITapGestureRecognizer(target: self, action: #selector(presentARQuickLook(_:)))
      //  arButton.addGestureRecognizer(preview)
      //  view.addSubview(arButton)
        // Do any additional setup after loading the view.
//        downloadButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        let backImgView = UIImageView(frame: CGRect(x: 25, y: 40, width: 40, height: 40))
        backImgView.image = UIImage(systemName: "chevron.left")
        backImgView.backgroundColor = .white
        backImgView.tintColor = .darkGray
        backImgView.layer.cornerRadius = 20
        backImgView.layer.borderWidth = 1
        backImgView.layer.borderColor = UIColor.lightGray.cgColor
        backImgView.layer.shadowRadius = 3
        backImgView.layer.shadowOpacity = 0.95
        backImgView.layer.shadowColor = UIColor.black.cgColor
        //note.view?.layer.cornerRadius = 5
        backImgView.layer.masksToBounds = false
        backImgView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        let back = UITapGestureRecognizer(target: self, action: #selector(backAction(_:)))
        backImg.addGestureRecognizer(back)
       // view.addSubview(backImgView)
        let preview = UITapGestureRecognizer(target: self, action: #selector(previewAction(_:)))
        previewImg.addGestureRecognizer(preview)
        
        self.tableView.register(ObjectInfoTableViewCell.self, forCellReuseIdentifier: "ObjectInfoTableViewCell")
        self.tableView.register(ObjectDescriptionTableViewCell.self, forCellReuseIdentifier: "ObjectDescriptionTableViewCell")
     //   self.tableView.register(ObjectProductLinkTableViewCell.self, forCellReuseIdentifier: "ObjectProductLinkTableViewCell")
        self.tableView.register(ObjectCreatorTableViewCell.self, forCellReuseIdentifier: "ObjectCreatorTableViewCell")
        self.tableView.register(DownloadContentTableViewCell.self, forCellReuseIdentifier: "DownloadContentTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
      //  modelName = LaunchViewController.selectedEntityID
        print("\(modelName) is model ID")
    }
    
    func updateUI(){
//        // profileImage
//        StorageManager.getThumnail(model.thumbnail) { (image) in
//            self.objectImageView.image = image
//        }
//
//        // text descriptors
//        objectNameLabel.text = model.name
//        objectDescriptionLabel.text = model.bioStr
//
//        // profileButton / settingsButton
//        let currentUserUid = FirebaseAuthHelper.getCurrentUserUid2()
    }
    
    @objc func goToContentSettings(){
      //  let modelUid = Auth.auth().currentUser?.uid ?? ""
        let vc = EditContentDetailsTableViewController.instantiate(with: modelUid) //(user:user)
        let navVC = UINavigationController(rootViewController: vc)
      //  navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    @IBAction func likeAction(_ sender: Any) {
    }
    
    @IBAction func previewAction(_ sender: Any) {
        presentARQuickLook()
    }
    
    @objc func presentARQuickLook(){
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true)
    }
    
    //will need an objc func that takes __ uid so clicking on label will go to that user's profile
    
    @IBAction func goToCreatorProfile(_ sender: Any) {
//        let user = self.creatorUid
//        var next = UserProfileViewController.instantiate(with: user)
//        //next.modalPresentationStyle = .fullScreen
//        self.present(next, animated: true, completion: nil)
    }
    
    @objc func profile() {
        let user = self.creatorUid
        
        let vc = UserProfileViewController.instantiate(with: user)
        
        // Create a custom close button
        let closeButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(closeButtonTapped))
        vc.navigationItem.leftBarButtonItem = closeButton
        
        let navVC = UINavigationController(rootViewController: vc)
     //   navVC.modalPresentationStyle = .fullScreen
        
        present(navVC, animated: true)
    }

    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func goToPurchasePoints(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        var next = storyboard.instantiateViewController(withIdentifier: "PurchasePointsVC") as! PurchasePointsViewController
//         next.modalPresentationStyle = .fullScreen
//        self.present(next, animated: true, completion: nil)
    }
    
    private let cloudStorage = Storage.storage()
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {

        let storageRef = URL(string: "\(self.cloudStorage.reference(withPath: self.modelName))")
        let previewItem = ARQuickLookPreviewItem(fileAt: storageRef!)
        previewItem.allowsContentScaling = true
        return previewItem

       // let relativePath =

    //    FirebaseStorageHelper.asyncDownloadToFilesystem(relativePath: "models/Chess.usdz") { localUrl in
//                guard let fileURL = localUrl else {
//                    fatalError("could not load file")
//                }
//                let previewItem = ARQuickLookPreviewItem(fileAt: localUrl)
//                previewItem.allowsContentScaling = true
//                return previewItem
//            }
    }
    
//    func previewController(_ controller: QLPreviewController, previewItemAt index: Int, completion: (QLPreviewItem?) -> Void) {
//            let storageRef = cloudStorage.reference(forURL: "gs://blueprint-8c1ca.appspot.com").child("models").child(self.modelName)
//            storageRef.downloadURL { (url, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                    completion(nil)
//                    return
//                }
//                guard let url = url else {
//                    completion(nil)
//                    return
//                }
//                let item = ARQuickLookPreviewItem(fileAt: url)
//                completion(item)
//            }
//        }


      
    
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        let message = "Check out this asset on Blueprint."
                //Set the link to share.
                if let link = NSURL(string: "https://testflight.apple.com/join/oABsuTVH")
                {
                    let objectsToShare = [message,link] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                    self.present(activityVC, animated: true, completion: nil)
                }
    }
    
    var price = 0
    
    var name = ""
    
    @IBAction func downloadAction(_ sender: Any) {
        FirestoreManager.getModel(modelUid) { model in
            self.price = model?.price ?? 0
            let modelName = model?.modelName
            
            if self.price > self.userPoints {
                let alertController = UIAlertController(title: "Not Enough Credits :/", message: "To purchase this content, it requires more credits that you currently have. You can add credits to your account now.", preferredStyle: .alert)
                let purchaseAction = UIAlertAction(title: "Purchase", style: .default, handler: { (_) in
                    // GO TO PURCHASE POINTS VC -- DO NOT LOSE GENERATED CONTENT
                    
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                    
                })
                
                alertController.addAction(purchaseAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // DELEgAte METHOD TO DOWNLOAD CORRECT MODEL -- POP TO ROOT VC -- HAVE CORRECT LAUNCHVC UI -- ADD MODEL TO FOCUS ENTITY
                
                // FUNC DOWNLOADCONTENTFROMMARKETPLACE
                ProgressHUD.show("Loading...")
                let defaults = UserDefaults.standard
                
                defaults.set("\(self.modelUid ?? "")", forKey: "modelUid")
                defaults.set(true, forKey: "downloadContent")
                
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
            
        }
      //  LaunchViewController().addItem()
    }
    
    @objc func goToWebsite(_ url: String){
        // go to website
        if let url = URL(string: "https://www.hackingwithswift.com") {
            UIApplication.shared.open(url)
        }
    }
    
    var activityIndicator: UIActivityIndicatorView!
    
    func showLoading() {
//        originalButtonText = self.titleLabel?.text
//        self.setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .lightGray
        return activityIndicator
    }

    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
       // self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }

    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
    //    self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
     //   self.addConstraint(yCenterConstraint)
    }
    
    @objc func downloadContentAction(){
        // Check if the user is logged in
        if Auth.auth().currentUser == nil {
            let alert = UIAlertController(title: "Create Account", message: "To add content to your library  you first need to create an account. When you create an account on Blueprint, you get $5.00 in credits!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sign Up", style: .default) { action in
                self.goToSignUp()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                return
            })
            present(alert, animated: true)
            return
        }
       
        if isCollected == true {
//            if isImage {
//                saveImageToUserDefaults()
//            } else {
//                saveModelToUserDefaults()
//            }
//            dismiss()
            ProgressHUD.showSuccess("Already in Library")
            return
        }
        if Auth.auth().currentUser?.uid ?? "" == creatorUid {
//            if isImage {
//                saveImageToUserDefaults()
//            } else {
//                saveModelToUserDefaults()
//            }
//            dismiss()
            ProgressHUD.showSuccess("Already in Library")
            return
        }
        if self.price != 0 && Auth.auth().currentUser?.uid ?? "" != self.creatorUid && self.price < userPoints{
            if isImage {
                self.purchaseImageAlert()
            } else {
                self.purchaseModelAlert()
            }
         //   dismiss()
            return
        }
        
        if self.price == 0 && Auth.auth().currentUser?.uid ?? "" != self.creatorUid {

//            self.downloadButton.setTitle("Added to Library", for: .normal)
//            self.downloadButton.setTitleColor(UIColor.black, for: .normal)
//            self.downloadButton.backgroundColor = .white//.tintColor
//            self.downloadButton.layer.borderColor = UIColor.black.cgColor
//            self.downloadButton.layer.borderWidth = 1
            ProgressHUD.showSuccess("Added to Library")
            return
        }
        if price > userPoints {
            let alertController = UIAlertController(title: "Not Enough Credits :/", message: "To purchase this content, it requires more credits that you currently have. You can add credits to your account now.", preferredStyle: .alert)
            let purchaseAction = UIAlertAction(title: "Buy Credits", style: .default, handler: { (_) in
                self.goToPurchasePoints()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in })
            alertController.addAction(purchaseAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getDeviceToken(for userId: String, completion: @escaping (String?) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.getDocument { (snapshot, error) in
            if let error = error {
                print("Error getting user document: (error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = snapshot?.data(), let deviceToken = data["deviceToken"] as? String else {
                print("User document does not contain deviceToken")
                completion(nil)
                return
            }
                completion(deviceToken)
        }
    }
    
    func sendPushNotification(to userId: String, title: String, body: String) {
        // Get the device token for the user
        getDeviceToken(for: userId) { (deviceToken) in
            guard let deviceToken = deviceToken else {
                print("Could not get device token for user with id: (userId)")
                return
            }
            // Prepare the push notification
            let notification = ["to": deviceToken, "notification": ["title": title, "body": body]]
            let jsonData = try? JSONSerialization.data(withJSONObject: notification)

            // Create a request to the Firebase Cloud Messaging server to send the push notification
            var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=AAAArV4iZag:APA91bHGzURyShrsLNu47s5m4F1D0oV72fQfKLGaBwoVuJzFVjvebyVw3Fpyz-AvtZnkKzi41nLyG3WNOWqxyXUZHWKw71rn-_s_8_CAoffB-lNQiUcbFPFwurFYNUKkEuhRMn1VWF76", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData

            // Send the request
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error sending push notification: \(error.localizedDescription)")
                    return
                }
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        print("FCM response: \(jsonResponse)")
                        // Check the status of the push notification
                        if let messageId = jsonResponse?["message_id"] as? String {
                            print("Push notification sent successfully. Message Id: (messageId)")
                        } else if let error = jsonResponse?["error"] as? [String: Any], let errorCode = error["code"] as? Int {
                            print("Error sending push notification. Error code: (errorCode)")
                        }
                    } catch {
                        print("Error parsing FCM response: (error.localizedDescription)")
                    }
                }
                }
                task.resume()
            }
        }


    // this function will be called after the purchase is complete.
    func sendNotification(to userId: String, title: String, body: String) {
        sendPushNotification(to: userId, title: title, body: body)
    }



    @objc func purchaseModelAlert() {
        let alertController = UIAlertController(title: "Buy \(self.name)?", message: "Are you sure you want to purchase \(self.name)?", preferredStyle: .alert)
        let purchaseAction = UIAlertAction(title: "Purchase", style: .default, handler: { (_) in
            // ADD ACTIVITY INDICATOR AS TITLE OF DOWNLOAD BUTTON -- REMOVE POINTS FROM CURRENT USER -- PAY CREATOR -- TAKE COMMISSION -- ADD CONTENT TO USER LIBRARY

            //    self.showLoading()
            let docRef = self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
            docRef.updateData([
                "points": FieldValue.increment(Int64(-self.price)),
                "collectedContentCount": FieldValue.increment(Int64(+1)),
                "collectedContentIDs": FieldValue.arrayUnion(["\(self.modelUid ?? "")"])
            ]) { error in
                if let error = error {
                    // Handle the error
                    return
                }
                // Update the visibleModels and the UI
                self.isCollected = true
                self.updateUI()
            }

            let docRef1 = self.db.collection("users").document(self.creatorUid)
            let earned = Double(self.price)// * 0.0090
            docRef1.updateData([
                "points": FieldValue.increment(earned)
               ])

            self.saveModelToUserDefaults()
            // HOW TO USE  this function in the purchase action handler
//            self.sendNotification(to: self.creatorUid, title: "Content Purchased", body: "Some of your content has been collected.")
            self.dismiss()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in

        })

        alertController.addAction(purchaseAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        return
    }
    
    @objc func purchaseImageAlert(){
        let alertController = UIAlertController(title: "Buy \(self.name)?", message: "Are you sure you want to purchase \(self.name)?", preferredStyle: .alert)
        let purchaseAction = UIAlertAction(title: "Purchase", style: .default, handler: { (_) in
            // ADD ACTIVITY INDICATOR AS TITLE OF DOWNLOAD BUTTON -- REMOVE POINTS FROM CURRENT USER -- PAY CREATOR -- TAKE COMMISSION -- ADD CONTENT TO USER LIBRARY

            //    self.showLoading()
            let docRef = self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
               docRef.updateData([
                    "points": FieldValue.increment(Int64(-self.price)),
                    "collectedContentCount": FieldValue.increment(Int64(+1)),
                    "collectedContentIDs": FieldValue.arrayUnion(["\(self.modelUid ?? "")"])
               ])

            let docRef1 = self.db.collection("users").document(self.creatorUid)
            let earned = Double(self.price)// * 0.0090
               docRef1.updateData([
                "points": FieldValue.increment(earned)
               ])

            self.saveImageToUserDefaults()
            self.dismiss()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in

        })

        alertController.addAction(purchaseAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        return
    }
    
    private func saveImageToUserDefaults() {
        guard let data = objectImageView.image?.jpegData(compressionQuality: 0.5) else { return }
        let encoded = try! PropertyListEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: "marketplaceImage")
        UserDefaults.standard.set("\(modelUid ?? "")", forKey: "modelUid")
        UserDefaults.standard.set(true, forKey: "downloadImage")
        if self.creatorUid != Auth.auth().currentUser?.uid ?? "" {
            self.sendNotification(to: self.creatorUid, title: "Content Collected", body: "Someone has collected some of your content on the Marketplace.")
        }
    }

    private func saveModelToUserDefaults() {
        UserDefaults.standard.set("\(modelUid ?? "")", forKey: "modelUid")
        UserDefaults.standard.set(true, forKey: "downloadContent")
        if self.creatorUid != Auth.auth().currentUser?.uid ?? "" {
            self.sendNotification(to: self.creatorUid, title: "Content Collected", body: "Someone has collected some of your content on the Marketplace.")
        }
    }

    private func dismiss() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    
    @objc func goToSignUp(){
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpViewController
         next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if self.isCollected == true && self.description1.isEmpty{
//            return 2 // no need to show 'Add to Library' button if its already in your library
//        } else
        if self.description1.isEmpty {
            return 3 // Since we're skipping row 1
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
        
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ObjectInfoTableViewCell.identifier, for: indexPath) as? ObjectInfoTableViewCell else {
                return UITableViewCell()
            }
                        // do second task if success
            let tap = UITapGestureRecognizer(target: self, action: #selector(profile))
            cell.hostLabel.addGestureRecognizer(tap)
            
            cell.configure(with: self.modelUid)
            tableView.rowHeight = 164
            return cell
            }
          
        
        else if indexPath.row == 1 {
            if self.description1.isEmpty {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ObjectCreatorTableViewCell.identifier, for: indexPath) as? ObjectCreatorTableViewCell else {
                    return UITableViewCell()
                }
                            // do second task if success
                let tap = UITapGestureRecognizer(target: self, action: #selector(profile))
                cell.creatorNameLabel.addGestureRecognizer(tap)
                
                let tap1 = UITapGestureRecognizer(target: self, action: #selector(profile))
                cell.creatorImageView.addGestureRecognizer(tap1)
                
                cell.configure(with: self.modelUid)
                tableView.rowHeight = 108
                return cell
                
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ObjectDescriptionTableViewCell.identifier, for: indexPath) as? ObjectDescriptionTableViewCell else {
                    return UITableViewCell()
                }
                // do second task if success
                
                cell.configure(with: self.modelUid)
                if self.description1 == "" {
                    tableView.rowHeight = 0
                } else {
                    tableView.rowHeight = 135
                }
                return cell
            }
        }
        else if indexPath.row == 2 {
            if self.description1.isEmpty {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DownloadContentTableViewCell.identifier, for: indexPath) as? DownloadContentTableViewCell else {
                    return UITableViewCell()
                }
                cell.configure(with: self.modelUid)
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.downloadContentAction))
                cell.downloadButton.addGestureRecognizer(tap)
                
    //            cell.downloadButton.setTitle("", for: .normal)
    //            cell.activityIndicator.isHidden = false
    //            cell.activityIndicator.startAnimating()
                tableView.rowHeight = 70
                return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ObjectCreatorTableViewCell.identifier, for: indexPath) as? ObjectCreatorTableViewCell else {
                    return UITableViewCell()
                }
                // do second task if success
                let tap = UITapGestureRecognizer(target: self, action: #selector(profile))
                cell.creatorNameLabel.addGestureRecognizer(tap)
                
                let tap1 = UITapGestureRecognizer(target: self, action: #selector(profile))
                cell.creatorImageView.addGestureRecognizer(tap1)
                
                cell.configure(with: self.modelUid)
                tableView.rowHeight = 108
                return cell
            }
        }
        if indexPath.row == 3 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DownloadContentTableViewCell.identifier, for: indexPath) as? DownloadContentTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: self.modelUid)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.downloadContentAction))
            cell.downloadButton.addGestureRecognizer(tap)
            
//            cell.downloadButton.setTitle("", for: .normal)
//            cell.activityIndicator.isHidden = false
//            cell.activityIndicator.startAnimating()
            tableView.rowHeight = 70
            return cell
        }
             return UITableViewCell()
    }
    
    var int_row = Int()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        int_row = indexPath.row
        self.tableView.reloadData()
    }
    
    var cellTaps1 = 0
    var cellTaps2 = 0
    var cellTaps3 = 0
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 164
        } else if indexPath.row == 1 {
            if self.description1.isEmpty {
                return 108 // Height of ObjectCreatorTableViewCell when description is empty
            } else {
                return 135 // Height of ObjectDescriptionTableViewCell when description is not empty
            }
        } else if indexPath.row == 2 {
            if self.description1.isEmpty {
                return 70 // Height of ObjectCreatorTableViewCell when description is empty
            } else {
                return 108 // Height of ObjectDescriptionTableViewCell when description is not empty
            }
        } else if indexPath.row == 3 {
            return 70
        }
        
        return 0 // Default case
    }

    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        if indexPath.row == 0 {
//            return 164
//        }
//        if int_row == indexPath.row && indexPath.row == 1 { // when you tap on cell then it will expend the cell
//            cellTaps1 += 1
//            cellTaps2 = 0
//            cellTaps3 = 0
//            if cellTaps1 % 2 == 0 {
//                return 0
//            } else {
//                return 140 //UITableView.automaticDimension
//            }}
//        else if int_row == indexPath.row && indexPath.row == 2 { // when you tap on cell then it will expend the cell
//            cellTaps2 += 1
//            cellTaps1 = 0
//            cellTaps3 = 0
//            if cellTaps2 % 2 == 0 {
//                return 0
//            } else {
//                return 93 //UITableView.automaticDimension
//            }}
//        else if int_row == indexPath.row && indexPath.row == 3 { // when you tap on cell then it will expend the cell
//            cellTaps3 += 1
//            cellTaps2 = 0
//            cellTaps1 = 0
//            if cellTaps3 % 2 == 0 {
//                return 58
//            } else {
//                return 118// UITableView.automaticDimension
//            }}
//        else if indexPath.row == 4 {
//            return 70
//        }
//            else {
//            return 58 // at this time only show your uppar labal only
//        }
//        }
    
}
