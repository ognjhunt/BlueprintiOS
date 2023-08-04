//
//  UserProfileViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 1/24/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
import FirebaseFirestore
//import SCLAlertView
import FirebaseAuth
import FirebaseStorage
//import SDWebImage
import ProgressHUD

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {


    @IBOutlet weak var backBarButton: UIBarButtonItem!
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var pointsButton: UIBarButtonItem!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var collectedButton: UIButton!
    @IBOutlet weak var createdButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var subscribeBtn: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profPicImageView: UIImageView!
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmenetedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var subscribed = false
    var getCreated = true
    
    var user: User!
    var userUid     : String!
    let db = Firestore.firestore()
    
    var numCollected = -1
    var numCreated = -1
    
    private var searchedModels  = [Model]()
    private var models        = [Model]()
    private var visibleModels = [Model]()
    private var modelImages = [String: UIImage?]()
    private var fetchingImages = false

    var collectionView              : UICollectionView!
    private let activityIndicator   = UIActivityIndicatorView()
    

        internal static func instantiate(with userId: String) -> UserProfileViewController {

            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileViewController
            vc.userUid = userId
            return vc
        }
    
    var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // let _  = self.view
        setupView()
      loadData()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        searchTextField.tag = 0
        
        print("\(String(describing: Auth.auth().currentUser?.uid)) is auth current user")
        
        profPicImageView.isUserInteractionEnabled = true
        
        
       // searchBar.delegate = self
        
        if UITraitCollection.current.userInterfaceStyle == .light {
            tableView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
            searchView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
         //   topView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.90)
        } else {
            tableView.backgroundColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
            searchView.backgroundColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
            searchTextField.overrideUserInterfaceStyle = .light
          //  searchField.alpha = 1.0
        }
        
        if Auth.auth().currentUser?.uid == userUid {
            FirestoreManager.getUser(Auth.auth().currentUser!.uid) { user in
               // let randUsername = self.randomString(length: 12)
                let uid = Auth.auth().currentUser!.uid
                self.subscribeBtn.setTitle("Edit profile", for: .normal)
                self.subscribeBtn.backgroundColor = .systemGray6
                self.subscribeBtn.tintColor = .darkGray
                let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.settings))
                self.subscribeBtn.addGestureRecognizer(tap1)
            }} else {
                if Auth.auth().currentUser != nil {
                    FirestoreManager.getUser(Auth.auth().currentUser?.uid ?? "") { user in
                        if user?.following.contains(self.userUid) == true {
                            self.subscribeBtn.backgroundColor = .white
                            self.subscribeBtn.setTitle("Following", for: .normal) //= "Subscribed"
                            self.subscribeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                            self.subscribeBtn.setTitleColor(.darkGray, for: .normal)
                            self.subscribeBtn.layer.borderColor = UIColor.darkGray.cgColor
                            self.subscribeBtn.layer.borderWidth = 0.5
                            self.subscribed = true
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.subscribe(_:)))
                            self.subscribeBtn.addGestureRecognizer(tap)
                            //      self.settingsBarButton.tintColor = .clear//. isHidden = true
                            //      self.settingsBarButton.customView?.isUserInteractionEnabled = false
                        } else {
                            self.subscribeBtn.setTitle("Follow", for: .normal)
                            self.subscribeBtn.backgroundColor = .systemBlue
                            self.subscribeBtn.setTitleColor(.white, for: .normal)
                            self.subscribeBtn.tintColor = .white
                            self.subscribeBtn.layer.borderWidth = 0
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.subscribe(_:)))
                            self.subscribeBtn.addGestureRecognizer(tap)
                            //   self.settingsBarButton.tintColor = .clear//. isHidden = true
                            //   self.settingsBarButton.customView?.isUserInteractionEnabled = false
                        }}} else {
                        self.subscribeBtn.setTitle("Follow", for: .normal)
                        self.subscribeBtn.backgroundColor = .systemBlue
                        self.subscribeBtn.setTitleColor(.white, for: .normal)
                        self.subscribeBtn.tintColor = .white
                        self.subscribeBtn.layer.borderWidth = 0
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.subscribe(_:)))
                        self.subscribeBtn.addGestureRecognizer(tap)
                    }
                FirestoreManager.getUser(userUid) { user in
                   
                    self.name = user?.name ?? ""
                    
                }
         
        }
        backButton.layer.cornerRadius = 25
        backButton.layer.shadowRadius = 3
        backButton.layer.shadowOpacity = 0.95
        backButton.layer.shadowColor = UIColor.black.cgColor
        //note.view?.layer.cornerRadius = 5
        backButton.layer.masksToBounds = false
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        
        createdButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        collectedButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        
        searchStackUnderView.backgroundColor = .link
        searchStackUnderView.frame.origin.x = 0
        createdButton.addSubview(searchStackUnderView)
        
        searchTextField.setLeftView(image: UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))!)
        searchTextField.tintColor = .lightGray
     //   imageView.image?.symbolConfiguration = .
        
        subscribeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15 , weight: .semibold)
        
        backImg.layer.cornerRadius = 22.5
      //  backImg.layer.borderWidth = 1
       // backImg.layer.borderColor = UIColor.lightGray.cgColor
        backImg.layer.shadowRadius = 4
        backImg.layer.shadowOpacity = 0.95
        backImg.layer.shadowColor = UIColor.black.cgColor
        //note.view?.layer.cornerRadius = 5
        backImg.layer.masksToBounds = false
        backImg.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        let backTap = UITapGestureRecognizer(target: self, action: #selector(back(_:)))
        backImg.addGestureRecognizer(backTap)
        
        let db = Firestore.firestore()
        let docRef = db.collection("models").document("8EaV7rkVJCjn7iyzWUkR")
        

//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let documentThumbnail = document.get("thumbnail")
//                profPicImageView.image = documentThumbnail
//    }
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadData()
    }
    
    private func setupView() {
        // ------------------- collection views --------------------
        let eventLayout = UICollectionViewFlowLayout()
        let spacing = CGFloat(10)
        let size = (UIScreen.main.bounds.width / 2) - 12
        eventLayout.scrollDirection = .vertical
        eventLayout.minimumLineSpacing = 19
        eventLayout.minimumInteritemSpacing = 0
        eventLayout.sectionInset = UIEdgeInsets(top: 5, left: 8, bottom: 0, right: 8)
        eventLayout.itemSize = CGSize(width: size, height: size + 70)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: searchView.frame.maxY, width: view.frame.width, height: view.frame.height - searchView.frame.maxY), collectionViewLayout: eventLayout)
        collectionView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView.refreshControl?.beginRefreshing()
        
        collectionView.register(ModelCollectionViewCell.self, forCellWithReuseIdentifier: ModelCollectionViewCell.reuseID)
//        collectionView.register(ProfileHeaderSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderSupplementaryView.reuseID)
        
        view.addSubview(collectionView)
        [   collectionView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ].forEach{ $0.isActive = true }
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityIndicator)
        [   activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -20),
            activityIndicator.heightAnchor.constraint(equalToConstant: 20),
            activityIndicator.widthAnchor.constraint(equalToConstant: 20),
        ].forEach{ $0.isActive = true }
    }
    
    @IBAction func backAction1(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private var leftBarButton: UIBarButtonItem!
    
    @objc func loadData() {
        // Use a serial queue to avoid race conditions
        let dataQueue = DispatchQueue(label: "dataQueue", qos: .userInitiated)
        // Keep track of any errors that occur
        var loadError: Error? = nil
        // Use a dispatch group to wait for all async tasks to finish
        let group = DispatchGroup()
        
        dataQueue.async {
            self.modelImages = [:]

            if (self.getCreated) {
                group.enter()
                FirestoreManager.getProfileCreatedModels(self.userUid) { created in
                    self.models = created.sorted(by: { $0.date > $1.date })
                    self.numCreated = created.count
                    self.numCollected = -1
                    group.leave()
                }
            } else {
                group.enter()
                FirestoreManager.getProfileCollectedModels(self.userUid) { collected in
                    self.models = collected.sorted(by: { $0.date > $1.date })
                    self.numCollected = collected.count
                    self.numCreated = -1
                    group.leave()
                }
            }
            // Wait for the group to finish and check for errors
            group.wait()
            
            if let error = loadError {
                // Handle error
                return
            }
            DispatchQueue.main.async {
                self.visibleModels = Array(self.models.prefix(6))
                self.updateUI()
            }
        }
        // Set a timeout for the dispatch group
        let result = group.wait(timeout: .now() + 8)
        switch result {
        case .timedOut:
            // Handle timeout
            break
        default:
            break
        }
    }

    
//    @objc func loadData() {
//
//        modelImages = [:]
//
//        let group = DispatchGroup()
//
//        if (getCreated) { //on created side of toggle
//
//            // ---------------------- joined ----------------------
//            group.enter()
//            FirestoreManager.getProfileCreatedModels(userUid) { created in
//                self.models = created.sorted(by: { $0.date > $1.date })
//                self.numCreated = created.count
//                self.numCollected = -1
//                group.leave()
//            }
//
//        } else {
//
//            // ---------------------- created ----------------------
//            group.enter()
//            FirestoreManager.getProfileCollectedModels(userUid) { collected in
//                self.models = collected.sorted(by: { $0.date > $1.date })
//                self.numCollected = collected.count
//                self.numCreated = -1
//                group.leave()
//            }
//        }
//
//
//        group.notify(queue: DispatchQueue.main) {
//
//            self.visibleModels = Array(self.models.prefix(6))
//            self.updateUI()
//        }
//    }
    
    var noCollectionView = UIView()
    
    var noContentView = UIView()
    
    private func getModelThumbnail(_ modelUid: String) {
        FirestoreManager.getModel(modelUid) { model in
            let thumbnailName = model?.thumbnail
            StorageManager.getModelThumbnail(thumbnailName ?? "") { image in
                self.modelImages[modelUid] = image
                self.collectionView.reloadData()
                //return
            }
        }
    }
        
    private func updateUI() {
        
        activityIndicator.stopAnimating()
        self.collectionView.refreshControl?.endRefreshing()
        
       // headerHasContent = false
        self.collectionView.reloadData()
        fetchingImages = false
        
       // navigationItem.title = username
    }
    
    func checkUserContent(){
        if Auth.auth().currentUser?.uid == userUid {
            FirestoreManager.getUser(Auth.auth().currentUser!.uid) { user in
                if (self.getCreated) {
                    self.noCollectionView.removeFromSuperview()
                    if user?.uploadedContentCount == 0 {
                        self.tableView.isHidden = true
                        self.noContentView = UIView(frame: CGRect(x: 0, y: self.searchView.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.searchView.frame.maxY))
                        
                        let noContentTitle = UILabel(frame: CGRect(x: 70.67, y: 69, width: 249, height: 53))
                        noContentTitle.text = "No Creations :("
                        noContentTitle.textAlignment = .center
                        noContentTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
                        let noContentSubtitle = UILabel(frame: CGRect(x: 25, y: 127, width: 340, height: 56))
                        noContentSubtitle.text = "Once you create content, it will appear here on your profile" //"Content you upload on Blueprint's website will appear here on your profile
                        noContentSubtitle.font = UIFont.systemFont(ofSize: 21.5, weight: .medium)
                        noContentSubtitle.textAlignment = .center
                        noContentSubtitle.textColor = .darkGray
                        noContentSubtitle.numberOfLines = 3
                        let createLabel = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 100, y: noContentSubtitle.frame.maxY + 13, width: 200, height: 23))
                        createLabel.text = "Create content now"
                        createLabel.textColor = .systemBlue
                        createLabel.textAlignment = .center
                        createLabel.isUserInteractionEnabled = true
                        createLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
                        let tapG = UITapGestureRecognizer(target: self, action: #selector(self.goToCompose))
                        createLabel.addGestureRecognizer(tapG)
                        if UITraitCollection.current.userInterfaceStyle == .light {
                            self.noContentView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
                        } else {
                            self.noContentView.backgroundColor =  UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
                            noContentSubtitle.textColor = .lightGray
                            self.subscribeBtn.backgroundColor = .white
                            self.subscribeBtn.setTitleColor(.darkGray, for: .normal)
                        }
                        self.noContentView.addSubview(noContentTitle)
                        self.noContentView.addSubview(noContentSubtitle)
                        self.noContentView.addSubview(createLabel)
                        self.view.addSubview(self.noContentView)
                    } else {
                        self.noContentView.removeFromSuperview()
                        self.noCollectionView.removeFromSuperview()
                        self.tableView.isHidden = true
                    }
                } else {
                    if user?.collectedContentCount == 0 {
                        self.noContentView.removeFromSuperview()
                        self.tableView.isHidden = true
                        self.noCollectionView = UIView(frame: CGRect(x: 0, y: self.searchView.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.searchView.frame.maxY))
                        
                        let noContentTitle = UILabel(frame: CGRect(x: 45.67, y: 69, width: 299, height: 53))
                        noContentTitle.text = "No Collections :("
                        noContentTitle.textAlignment = .center
                        noContentTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
                        let noContentSubtitle = UILabel(frame: CGRect(x: 25, y: 127, width: 340, height: 56))
                        noContentSubtitle.text = "Once you collect content, it will appear here on your profile" //"Content you upload on Blueprint's website will appear here on your profile
                        noContentSubtitle.font = UIFont.systemFont(ofSize: 21.5, weight: .medium)
                        noContentSubtitle.textAlignment = .center
                        noContentSubtitle.textColor = .darkGray
                        noContentSubtitle.numberOfLines = 3
                        let createLabel = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 100, y: noContentSubtitle.frame.maxY + 13, width: 200, height: 23))
                        createLabel.text = "Create content now"
                        createLabel.textColor = .systemBlue
                        createLabel.textAlignment = .center
                        createLabel.isUserInteractionEnabled = true
                        createLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
                        let tapG = UITapGestureRecognizer(target: self, action: #selector(self.goToCompose))
                        createLabel.addGestureRecognizer(tapG)
                        if UITraitCollection.current.userInterfaceStyle == .light {
                            self.noCollectionView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
                        } else {
                            self.noCollectionView.backgroundColor =  UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
                            noContentSubtitle.textColor = .lightGray
                            self.subscribeBtn.backgroundColor = .white
                            self.subscribeBtn.setTitleColor(.darkGray, for: .normal)
                        }
                        self.noCollectionView.addSubview(noContentTitle)
                        self.noCollectionView.addSubview(noContentSubtitle)
                        //   noContentView.addSubview(createLabel)
                        self.view.addSubview(self.noCollectionView)
                    } else {
                        self.noContentView.removeFromSuperview()
                        self.noCollectionView.removeFromSuperview()
                        self.tableView.isHidden = true
                    }
                }
            }
        } else {
            FirestoreManager.getUser(userUid) { user in
                if (self.getCreated) {
                    if user?.uploadedContentCount == 0 {
                        self.noCollectionView.removeFromSuperview()
                        self.tableView.isHidden = true
                        self.noContentView = UIView(frame: CGRect(x: 0, y: self.searchView.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.searchView.frame.maxY))
                        
                        let noContentTitle = UILabel(frame: CGRect(x: 70.67, y: 69, width: 249, height: 53))
                        noContentTitle.text = "No Creations :("
                        noContentTitle.textAlignment = .center
                        noContentTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
                        let noContentSubtitle = UILabel(frame: CGRect(x: 25, y: 127, width: 340, height: 56))
                        noContentSubtitle.text = "Once they create content, it will appear here on their profile" //"Content you upload on Blueprint's website will appear here on your profile
                        noContentSubtitle.font = UIFont.systemFont(ofSize: 21.5, weight: .medium)
                        noContentSubtitle.textAlignment = .center
                        noContentSubtitle.textColor = .darkGray
                        noContentSubtitle.numberOfLines = 3
                        if UITraitCollection.current.userInterfaceStyle == .light {
                            self.noContentView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
                        } else {
                            self.noContentView.backgroundColor =  UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
                            noContentSubtitle.textColor = .lightGray
                            self.subscribeBtn.backgroundColor = .white
                            self.subscribeBtn.setTitleColor(.darkGray, for: .normal)
                        }
                        self.noContentView.addSubview(noContentTitle)
                        self.noContentView.addSubview(noContentSubtitle)
                        
                        self.view.addSubview(self.noContentView)
                    } else {
                        self.tableView.isHidden = true
                        self.noContentView.removeFromSuperview()
                        self.noCollectionView.removeFromSuperview()
                    }
                } else {
                    if user?.collectedContentCount == 0 {
                        self.noContentView.removeFromSuperview()
                        self.tableView.isHidden = true
                        self.noCollectionView = UIView(frame: CGRect(x: 0, y: self.searchView.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.searchView.frame.maxY))
                        
                        let noContentTitle = UILabel(frame: CGRect(x: 45.67, y: 69, width: 299, height: 53))
                        noContentTitle.text = "No Collections :("
                        noContentTitle.textAlignment = .center
                        noContentTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
                        let noContentSubtitle = UILabel(frame: CGRect(x: 25, y: 127, width: 340, height: 56))
                        noContentSubtitle.text = "Once they collect content, it will appear here on their profile" //"Content you upload on Blueprint's website will appear here on your profile
                        noContentSubtitle.font = UIFont.systemFont(ofSize: 21.5, weight: .medium)
                        noContentSubtitle.textAlignment = .center
                        noContentSubtitle.textColor = .darkGray
                        noContentSubtitle.numberOfLines = 3
                        if UITraitCollection.current.userInterfaceStyle == .light {
                            self.noCollectionView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
                        } else {
                            self.noCollectionView.backgroundColor =  UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
                            noContentSubtitle.textColor = .lightGray
                            self.subscribeBtn.backgroundColor = .white
                            self.subscribeBtn.setTitleColor(.darkGray, for: .normal)
                        }
                        self.noCollectionView.addSubview(noContentTitle)
                        self.noCollectionView.addSubview(noContentSubtitle)
                        
                        self.view.addSubview(self.noCollectionView)
                    } else {
                        self.noContentView.removeFromSuperview()
                        self.noCollectionView.removeFromSuperview()
                        self.tableView.isHidden = true
                    }
                }
            }
        }}
    
    func reloadData() {
//        if Auth.auth().currentUser != nil {
//            var customerId = Auth.auth().currentUser?.uid
//            if customerId?.count == 28 {
                if Auth.auth().currentUser?.uid == userUid {
                    FirestoreManager.getUser(Auth.auth().currentUser!.uid) { user in
                        
                        //   FirestoreManager.getUser(Auth.auth().currentUser!.uid) { user in
                        // let randUsername = self.randomString(length: 12)
                        
                        let uid = Auth.auth().currentUser!.uid
                        self.subscribeBtn.setTitle("Edit profile", for: .normal)
                        self.subscribeBtn.backgroundColor = .systemGray6
                        self.subscribeBtn.tintColor = .darkGray
                        //                        self.pointsButton.title = "\(user?.points ?? 0)"
                        let myButton = UIButton(type: .system)
                        myButton.setImage(UIImage(systemName: "diamond.fill"), for: .normal) //(UIImage(systemName: "bitcoinsign.circle.fill"), for: .normal)
                        myButton.setTitle(" \(user?.points ?? 0)", for: .normal)
                        myButton.setTitleColor(.label, for: .normal)
                        myButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.5, weight: .semibold)
                        myButton.imageView?.contentMode = .scaleAspectFit
                        myButton.tintColor = .systemYellow
                        myButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                        //  myButton.titleLabel?.textColor = .black
                        myButton.sizeToFit()
                        //                        myButton.layer.borderWidth = 0.7
                        //                        myButton.frame.size.height = myButton.frame.size.height + 15
                        //
                        //                        myButton.layer.cornerRadius = (myButton.frame.size.height / 2)
                        //                        myButton.frame.size.width = myButton.frame.size.width + 20
                        //                        myButton.layer.borderColor = UIColor.label.cgColor
                        myButton.addTarget(self, action: #selector(self.goToPoints), for: .touchUpInside)
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: myButton)
                        
                        
                        if user?.points ?? 0 < 500 {
                            //                            self.profPicImageView.layer.borderWidth = 4
                            //                            self.profPicImageView.layer.borderColor = UIColor.white.cgColor
                        } else if user?.points ?? 0 > 500 && user?.points ?? 0 < 1500 {
                            self.profPicImageView.layer.borderWidth = 3
                            self.profPicImageView.layer.borderColor = UIColor.systemBlue.cgColor
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tierInfoAlert))
                            self.profPicImageView.addGestureRecognizer(tap)
                        } else if user?.points ?? 0 > 1500 && user?.points ?? 0 < 5000 {
                            self.profPicImageView.layer.borderWidth = 3
                            self.profPicImageView.layer.borderColor = UIColor.green.cgColor
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tierInfoAlert))
                            self.profPicImageView.addGestureRecognizer(tap)
                        } else if user?.points ?? 0 > 5000 && user?.points ?? 0 < 10000 {
                            self.profPicImageView.layer.borderWidth = 3
                            self.profPicImageView.layer.borderColor = UIColor.red.cgColor
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tierInfoAlert))
                            self.profPicImageView.addGestureRecognizer(tap)
                        } else if user?.points ?? 0 > 10000 && user?.points ?? 0 < 25000 {
                            self.profPicImageView.layer.borderWidth = 3
                            self.profPicImageView.layer.borderColor = UIColor.systemYellow.cgColor
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tierInfoAlert))
                            self.profPicImageView.addGestureRecognizer(tap)
                        } else if user?.points ?? 0 > 25000 && user?.points ?? 0 < 50000 {
                            self.profPicImageView.layer.borderWidth = 3
                            self.profPicImageView.layer.borderColor = UIColor.systemOrange.cgColor
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tierInfoAlert))
                            self.profPicImageView.addGestureRecognizer(tap)
                        } else  if user?.points ?? 0 > 50000 {
                            self.profPicImageView.layer.borderWidth = 3
                            self.profPicImageView.layer.borderColor = UIColor.label.cgColor
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tierInfoAlert))
                            self.profPicImageView.addGestureRecognizer(tap)
                            
                        }
                        
                        
                        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.goToEditProfile(_:)))
                        if (self.getCreated) {
                        if user?.uploadedContentCount == 0 {
                            self.tableView.isHidden = true
                            self.noContentView = UIView(frame: CGRect(x: 0, y: self.searchView.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.searchView.frame.maxY))
                            
                            let noContentTitle = UILabel(frame: CGRect(x: 70.67, y: 69, width: 249, height: 53))
                            noContentTitle.text = "No Creations :("
                            noContentTitle.textAlignment = .center
                            noContentTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
                            let noContentSubtitle = UILabel(frame: CGRect(x: 25, y: 127, width: 340, height: 56))
                            noContentSubtitle.text = "Once you create content, it will appear here on your profile" //"Content you upload on Blueprint's website will appear here on your profile
                            noContentSubtitle.font = UIFont.systemFont(ofSize: 21.5, weight: .medium)
                            noContentSubtitle.textAlignment = .center
                            noContentSubtitle.textColor = .darkGray
                            noContentSubtitle.numberOfLines = 3
                            let createLabel = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 100, y: noContentSubtitle.frame.maxY + 13, width: 200, height: 23))
                            createLabel.text = "Create content now"
                            createLabel.textColor = .systemBlue
                            createLabel.textAlignment = .center
                            createLabel.isUserInteractionEnabled = true
                            createLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
                            let tapG = UITapGestureRecognizer(target: self, action: #selector(self.goToCompose))
                            createLabel.addGestureRecognizer(tapG)
                            if UITraitCollection.current.userInterfaceStyle == .light {
                                self.noContentView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
                            } else {
                                self.noContentView.backgroundColor =  UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
                                noContentSubtitle.textColor = .lightGray
                                self.subscribeBtn.backgroundColor = .white
                                self.subscribeBtn.setTitleColor(.darkGray, for: .normal)
                            }
                            self.noContentView.addSubview(noContentTitle)
                            self.noContentView.addSubview(noContentSubtitle)
                            self.noContentView.addSubview(createLabel)
                            self.view.addSubview(self.noContentView)
                        } else {
                            self.tableView.isHidden = true
                        }
                        } else {
                            if user?.collectedContentCount == 0 {
                                self.tableView.isHidden = true
                                self.noCollectionView = UIView(frame: CGRect(x: 0, y: self.searchView.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.searchView.frame.maxY))
                                
                                let noContentTitle = UILabel(frame: CGRect(x: 70.67, y: 69, width: 249, height: 53))
                                noContentTitle.text = "No Collections :("
                                noContentTitle.textAlignment = .center
                                noContentTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
                                let noContentSubtitle = UILabel(frame: CGRect(x: 25, y: 127, width: 340, height: 56))
                                noContentSubtitle.text = "Once you collect content, it will appear here on your profile" //"Content you upload on Blueprint's website will appear here on your profile
                                noContentSubtitle.font = UIFont.systemFont(ofSize: 21.5, weight: .medium)
                                noContentSubtitle.textAlignment = .center
                                noContentSubtitle.textColor = .darkGray
                                noContentSubtitle.numberOfLines = 3
                                let createLabel = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 100, y: noContentSubtitle.frame.maxY + 13, width: 200, height: 23))
                                createLabel.text = "Create content now"
                                createLabel.textColor = .systemBlue
                                createLabel.textAlignment = .center
                                createLabel.isUserInteractionEnabled = true
                                createLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
                                let tapG = UITapGestureRecognizer(target: self, action: #selector(self.goToCompose))
                                createLabel.addGestureRecognizer(tapG)
                                if UITraitCollection.current.userInterfaceStyle == .light {
                                    self.noCollectionView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
                                } else {
                                    self.noCollectionView.backgroundColor =  UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
                                    noContentSubtitle.textColor = .lightGray
                                    self.subscribeBtn.backgroundColor = .white
                                    self.subscribeBtn.setTitleColor(.darkGray, for: .normal)
                                }
                                self.noCollectionView.addSubview(noContentTitle)
                                self.noCollectionView.addSubview(noContentSubtitle)
                             //   noContentView.addSubview(createLabel)
                                self.view.addSubview(self.noCollectionView)
                            } else {
                                self.tableView.isHidden = true
                            }
                        }
                    self.createdButton.setTitle("  Created \(user?.uploadedContentCount ?? 0)", for: .normal)
                    self.collectedButton.setTitle("  Collected \(user?.collectedContentCount ?? 0)", for: .normal)
                        self.title = user?.username
                    //    self.navigationItem.titleView?.tintColor = .black
                    StorageManager.getProPic(Auth.auth().currentUser!.uid) { image in
                        self.profPicImageView.image = image
                    }
//                    if let photoUrlString = user?.profileImageUrl {
//                        let photoUrl = URL(string: photoUrlString)
//                        self.profPicImageView.sd_setImage(with: photoUrl)
//                    }
                    self.nameLabel.text = user?.name
                }
                } else {
                    if Auth.auth().currentUser != nil {
                        FirestoreManager.getUser(Auth.auth().currentUser?.uid ?? "") { user in
                            if user?.following.contains(self.userUid) == true {
                                self.subscribeBtn.backgroundColor = .white
                                self.subscribeBtn.setTitle("Following", for: .normal) //= "Subscribed"
                                self.subscribeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                                self.subscribeBtn.setTitleColor(.darkGray, for: .normal)
                                self.subscribeBtn.layer.borderColor = UIColor.darkGray.cgColor
                                self.subscribeBtn.layer.borderWidth = 0.5
                                self.subscribed = true
                                let tap = UITapGestureRecognizer(target: self, action: #selector(self.subscribe(_:)))
                                self.subscribeBtn.addGestureRecognizer(tap)
                            } else {
                                self.subscribeBtn.setTitle("Follow", for: .normal)
                                self.subscribeBtn.backgroundColor = .systemBlue
                                self.subscribeBtn.setTitleColor(.white, for: .normal)
                                self.subscribeBtn.tintColor = .white
                                self.subscribeBtn.layer.borderWidth = 0
                                let tap = UITapGestureRecognizer(target: self, action: #selector(self.subscribe(_:)))
                                self.subscribeBtn.addGestureRecognizer(tap)
                            }}
                    } else {
                        self.subscribeBtn.setTitle("Follow", for: .normal)
                        self.subscribeBtn.backgroundColor = .systemBlue
                        self.subscribeBtn.setTitleColor(.white, for: .normal)
                        self.subscribeBtn.tintColor = .white
                        self.subscribeBtn.layer.borderWidth = 0
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.subscribe(_:)))
                        self.subscribeBtn.addGestureRecognizer(tap)
                    }
                    FirestoreManager.getUser(userUid) { user in
                        if (self.getCreated) {
                            if user?.uploadedContentCount == 0 {
                                self.tableView.isHidden = true
                                self.noContentView = UIView(frame: CGRect(x: 0, y: self.searchView.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.searchView.frame.maxY))
                                
                                let noContentTitle = UILabel(frame: CGRect(x: 70.67, y: 69, width: 249, height: 53))
                                noContentTitle.text = "No Creations :("
                                noContentTitle.textAlignment = .center
                                noContentTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
                                let noContentSubtitle = UILabel(frame: CGRect(x: 25, y: 127, width: 340, height: 56))
                                noContentSubtitle.text = "Once they create content, it will appear here on their profile" //"Content you upload on Blueprint's website will appear here on your profile
                                noContentSubtitle.font = UIFont.systemFont(ofSize: 21.5, weight: .medium)
                                noContentSubtitle.textAlignment = .center
                                noContentSubtitle.textColor = .darkGray
                                noContentSubtitle.numberOfLines = 3
                                if UITraitCollection.current.userInterfaceStyle == .light {
                                    self.noContentView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
                                } else {
                                    self.noContentView.backgroundColor =  UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
                                    noContentSubtitle.textColor = .lightGray
                                    self.subscribeBtn.backgroundColor = .white
                                    self.subscribeBtn.setTitleColor(.darkGray, for: .normal)
                                }
                                self.noContentView.addSubview(noContentTitle)
                                self.noContentView.addSubview(noContentSubtitle)
                                
                                self.view.addSubview(self.noContentView)
                            } else {
                                self.tableView.isHidden = true
                            }
                        } else {
                            if user?.collectedContentCount == 0 {
                                self.tableView.isHidden = true
                                self.noCollectionView = UIView(frame: CGRect(x: 0, y: self.searchView.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.searchView.frame.maxY))
                                
                                let noContentTitle = UILabel(frame: CGRect(x: 70.67, y: 69, width: 249, height: 53))
                                noContentTitle.text = "No Collections :("
                                noContentTitle.textAlignment = .center
                                noContentTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
                                let noContentSubtitle = UILabel(frame: CGRect(x: 25, y: 127, width: 340, height: 56))
                                noContentSubtitle.text = "Once they collect content, it will appear here on their profile" //"Content you upload on Blueprint's website will appear here on your profile
                                noContentSubtitle.font = UIFont.systemFont(ofSize: 21.5, weight: .medium)
                                noContentSubtitle.textAlignment = .center
                                noContentSubtitle.textColor = .darkGray
                                noContentSubtitle.numberOfLines = 3
                                if UITraitCollection.current.userInterfaceStyle == .light {
                                    self.noCollectionView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
                                } else {
                                    self.noCollectionView.backgroundColor =  UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
                                    noContentSubtitle.textColor = .lightGray
                                    self.subscribeBtn.backgroundColor = .white
                                    self.subscribeBtn.setTitleColor(.darkGray, for: .normal)
                                }
                                self.noCollectionView.addSubview(noContentTitle)
                                self.noCollectionView.addSubview(noContentSubtitle)
                                
                                self.view.addSubview(self.noCollectionView)
                            } else {
                                self.tableView.isHidden = true
                            }
                        }
                        self.createdButton.setTitle("  Created \(user?.uploadedContentCount ?? 0)", for: .normal)
                        self.collectedButton.setTitle("  Collected \(user?.collectedContentCount ?? 0)", for: .normal)
                        self.numCreated = user?.uploadedContentCount ?? 0
                        self.numCollected = user?.collectedContentCount ?? 0
                        self.navigationItem.title = user?.username
                      //  self.navigationItem.titleView?.tintColor = .black
                        StorageManager.getProPic(self.userUid) { image in
                            self.profPicImageView.image = image
                        }
                        self.nameLabel.text = user?.name
                    }
                    }
        
   }
    //scanning UI
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "SettingsAndPrivacyTableVC") as! SettingsAndPrivacyTableViewController
        let navVC = UINavigationController(rootViewController: next)
       // var next = UserProfileViewController.instantiate(with: user)
      //  navVC.modalPresentationStyle = .fullScreen
     //   next.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func settings(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "SettingsAndPrivacyTableVC") as! SettingsAndPrivacyTableViewController
        let navVC = UINavigationController(rootViewController: next)
       // var next = UserProfileViewController.instantiate(with: user)
      //  navVC.modalPresentationStyle = .fullScreen
     //   next.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func goToCompose(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        var next = storyboard.instantiateViewController(withIdentifier: "ComposeArtworkVC") as! ComposeArtworkViewController
//         next.modalPresentationStyle = .fullScreen
//        self.present(next, animated: true, completion: nil)
    }
    
    @objc func goToSignUp(){
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        var next = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpViewController
         next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func tierInfoAlert(_ sender: UITapGestureRecognizer){
        let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.black]
          let titleString = NSAttributedString(string: "Blueprint Tier", attributes: titleAttributes)
        let actionSheet = UIAlertController(title: "", message: "This Blueprint user is a Gold Tier creator. Meaning they have created more than 25 pieces of content.", preferredStyle: .actionSheet)

        actionSheet.setValue(titleString, forKey: "attributedTitle")
       
               let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                   print("didPress cancel")
               }

               // Add the actions to your actionSheet
               actionSheet.addAction(cancelAction)
               // Present the controller
               self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func goToPoints(_ sender: UITapGestureRecognizer){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        var next = storyboard.instantiateViewController(withIdentifier: "PurchasePointsVC") as! PurchasePointsViewController
//        next.modalPresentationStyle = .fullScreen
//        self.present(next, animated: true, completion: nil)
    }
    
    @objc func goToEditProfile(_ sender: UITapGestureRecognizer){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        var next = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileViewController
//       // next.modalPresentationStyle = .fullScreen
//        self.present(next, animated: true, completion: nil)
      
    }
            
    
    @objc func subscribe(_ sender: UITapGestureRecognizer){
        if subscribed {
            let alert = UIAlertController(title: "Unfollow \(self.name ?? "")?", message: "You'll lose access to \(self.name ?? "")'s creations when you unfollow.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Unfollow", style: .default) { action in
                ProgressHUD.show("Unfollowed")
                //SCLAlertView().showTitle("Unfollowed", subTitle: "", style: .info)// .showSuccess("Unsubscribed", subTitle: "Users can now connect to your Blueprint Network")
                let docRef = self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
                   docRef.updateData([
                    "following": FieldValue.arrayRemove(["\(self.userUid ?? "")"])
                   ])
                let docRef1 = self.db.collection("users").document(self.userUid ?? "")
                   docRef1.updateData([
                    "followers": FieldValue.arrayRemove(["\(Auth.auth().currentUser?.uid ?? "")"])
                   ])
                self.subscribeBtn.backgroundColor = .systemBlue
                self.subscribeBtn.tintColor = .white
                self.subscribeBtn.setTitle("Follow", for: .normal) //= "Subscribed"
                self.subscribeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                self.subscribeBtn.setTitleColor(.white, for: .normal)
                self.subscribeBtn.layer.borderWidth = 0
                self.subscribed = false
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                //completionHandler(false)
                return
            })
            present(alert, animated: true)
        } else if Auth.auth().currentUser != nil {
            let alert = UIAlertController(title: "Follow \(self.name)?", message: "When following an account, you get alerts whenever the user creates or collects new content.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Follow", style: .default) { action in
              //  SCLAlertView().showSuccess("Following", subTitle: "Users can now connect to your Blueprint Network")
                let docRef = self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
                   docRef.updateData([
                    "following": FieldValue.arrayUnion(["\(self.userUid ?? "")"])
                   ])
                let docRef1 = self.db.collection("users").document(self.userUid ?? "")
                   docRef1.updateData([
                    "followers": FieldValue.arrayUnion(["\(Auth.auth().currentUser?.uid ?? "")"])
                   ])
                self.subscribeBtn.backgroundColor = .white
                self.subscribeBtn.setTitle("Following", for: .normal) //= "Subscribed"
                self.subscribeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                self.subscribeBtn.setTitleColor(.darkGray, for: .normal)
                self.subscribeBtn.layer.borderColor = UIColor.darkGray.cgColor
                self.subscribeBtn.layer.borderWidth = 0.5
                self.subscribed = true
                
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                //completionHandler(false)
                return
            })
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Create Account", message: "In order to start following your favorite creators, you must first create an account on Blueprint.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sign Up", style: .default) { action in
                
                self.goToSignUp()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                //completionHandler(false)
                return
            })
            present(alert, animated: true)
        }}
    
    
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//            let currentText = textField.text ?? ""
//            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
//
//            if updatedText.isEmpty {
//                // If the text field is empty, show the full list of models
//               // browseTableView.isHidden = false
//                //collectionView.isHidden = true
//                loadData()
//                return true
//            }
//
//        FirestoreManager.searchProfileLibrary(allModels: self.models, queryStr: updatedText) { searchedModels in
//                self.searchedModels = searchedModels
//                print("\(searchedModels) is searchedModels")
//                self.visibleModels = Array(self.searchedModels.prefix(6))
//                print("\(self.visibleModels) is visibleModels")
//                self.updateUI()
//            }
//            return true
//        }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Use a serial queue to avoid race conditions
        let dataQueue = DispatchQueue(label: "dataQueue", qos: .userInitiated)
        // Keep track of any errors that occur
        var loadError: Error? = nil
        // Use a dispatch group to wait for all async tasks to finish
        let group = DispatchGroup()
        
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

        dataQueue.async {
            if updatedText.isEmpty {
                // If the text field is empty, show the full list of models
                self.loadData()
            } else {
                // Update the search results
                group.enter()
                FirestoreManager.searchProfileLibrary(allModels: self.models, queryStr: updatedText) { searchedModels in
                    self.searchedModels = searchedModels
                    self.visibleModels = Array(self.searchedModels.prefix(6))
                    group.leave()
                }
                // Wait for the group to finish and check for errors
                group.wait()
            }
        }
        // Set a timeout for the dispatch group
        let result = group.wait(timeout: .now() + 8)
        switch result {
        case .timedOut:
            // Handle timeout
            break
        default:
            break
        }
        DispatchQueue.main.async {
            self.updateUI()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if searchTextField.text == "" || searchTextField.text == " " {
           // browseTableView.isHidden = false
         //   collectionView.isHidden = true
            searchTextField.layer.borderWidth = 0
              searchTextField.tintColor = .lightGray
//            loadData()
        } else {
            guard let searchText = searchTextField.text else {
                return false
            }
          searchTextField.layer.borderWidth = 0
            searchTextField.tintColor = .lightGray
            
            FirestoreManager.searchProfileLibrary(allModels: self.models, queryStr: searchText) { searchedModels in
                    self.searchedModels = searchedModels
                    print("\(searchedModels) is searchedModels")
                    self.visibleModels = Array(self.searchedModels.prefix(6))
                    print("\(self.visibleModels) is visibleModels")
                    self.updateUI()
                }
        }
        return false
    }
    

    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTextField.layer.borderColor = UIColor.systemBlue.cgColor
        searchTextField.layer.borderWidth = 2
        searchTextField.tintColor = .systemBlue
        searchTextField.layer.cornerRadius = 10
    }
    
    
    let searchStackUnderView = UIView(frame: CGRect(x: 0, y: 55, width: UIScreen.main.bounds.width / 2, height: 3))
    
    @IBAction func createdAction(_ sender: Any) {
        
        activityIndicator.startAnimating()

        visibleModels = []
        collectionView.reloadData()

        self.getCreated = true
        
        loadData()
        checkUserContent()
        collectedButton.setTitleColor(.darkGray, for: .normal)
        collectedButton.tintColor = .darkGray
        searchStackUnderView.removeFromSuperview()
        if #available(iOS 15.0, *) {
            createdButton.setTitleColor(.label, for: .normal)
            createdButton.tintColor = .label
            searchStackUnderView.backgroundColor = .link // setTitleColor(.tintColor, for: .normal)
        } else {
            createdButton.setTitleColor(.label, for: .normal)
            createdButton.tintColor = .label
            searchStackUnderView.backgroundColor = .link
        }
        searchStackUnderView.bottomAnchor.constraint(equalTo: searchView.topAnchor)
        searchStackUnderView.frame.origin.x = 0
        print("\( searchStackUnderView.frame.origin.x) is searchStackUnderView x")
        createdButton.addSubview(searchStackUnderView)
       // browseTableView.isScrollEnabled = true
        //nftView.removeFromSuperview()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func back(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    
    @IBAction func collectedAction(_ sender: Any) {
        activityIndicator.startAnimating()

        visibleModels = []
        collectionView.reloadData()

        self.getCreated = false
        
        loadData()
        self.checkUserContent()
        createdButton.setTitleColor(.darkGray, for: .normal)
        createdButton.tintColor = .darkGray
        searchStackUnderView.removeFromSuperview()
        if #available(iOS 15.0, *) {
            collectedButton.setTitleColor(.label, for: .normal)
            collectedButton.tintColor = .label
            searchStackUnderView.backgroundColor = .link // setTitleColor(.tintColor, for: .normal)
        } else {
            collectedButton.setTitleColor(.label, for: .normal)
            collectedButton.tintColor = .label
            searchStackUnderView.backgroundColor = .link
        }
        
        searchStackUnderView.bottomAnchor.constraint(equalTo: searchView.topAnchor)
        searchStackUnderView.frame.origin.x = 0
        print("\( searchStackUnderView.frame.origin.x) is searchStackUnderView x")
        collectedButton.addSubview(searchStackUnderView)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.dismissKeyboard()
        }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
       // browseTableView.isHidden = false
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "new", for: indexPath)

            tableView.rowHeight = 275
              return cell
          }
          if indexPath.row == 1 {
              let cell = tableView.dequeueReusableCell(withIdentifier: "new1", for: indexPath)
              tableView.rowHeight = 275
            //  print("most popular cell returned")
              return cell
          }
                   if indexPath.row == 2 {
                       let cell = tableView.dequeueReusableCell(withIdentifier: "new", for: indexPath)
                       tableView.rowHeight = 275
                       return cell
                   }
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "new1", for: indexPath)
            tableView.rowHeight = 275
            return cell
        }
        if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "new", for: indexPath)
            tableView.rowHeight = 275
            return cell
        }

         return UITableViewCell()
    }
   

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
   
}

extension UITextField {
  func setLeftView(image: UIImage) {
      let iconView = UIImageView(frame: CGRect(x: 12, y: 6, width: 20, height: 20)) // set your Own size
    iconView.image = image
      iconView.contentMode = .scaleAspectFill
      
    let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
    iconContainerView.addSubview(iconView)
    leftView = iconContainerView
    leftViewMode = .always
    self.tintColor = .lightGray
  }
}

extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
        return visibleModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ModelCollectionViewCell.reuseID, for: indexPath) as! ModelCollectionViewCell
        
        let model = visibleModels[indexPath.row]
        
        if !modelImages.keys.contains(model.id) {
            modelImages[model.id] = nil as UIImage?
            getModelThumbnail(model.id)
        }
        
        let image = modelImages[model.id] ?? nil
        
        cell.setContent(model, image: image)

        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: visibleModels[indexPath.row].id)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
            
        if position > (scrollView.contentSize.height - scrollView.frame.maxY) {
            
            if !fetchingImages {
                
                fetchingImages = true
                
                guard visibleModels.count != searchedModels.count else {
                    return
                }
                
                activityIndicator.startAnimating()
                visibleModels = Array(models.prefix(visibleModels.count + 4))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                    self.updateUI()
                }
            }
        }
    }
    
}
