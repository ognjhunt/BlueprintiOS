//
//  SearchViewController.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 11/22/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import ProgressHUD

class SearchViewController: UIViewController, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var categoryStackView: UIStackView!
    @IBOutlet weak var browseTableView: UITableView!
    @IBOutlet weak var categoryScrollView: UIScrollView!
    @IBOutlet weak var searchView: UIView!
    
    let db = Firestore.firestore()
    
    private var searchedModels  = [Model]()
    private var visibleModels = [Model]()
    private var modelImages     = [String: UIImage]()
    
    private var collectionView          : UICollectionView!
    private let activityIndicator       = UIActivityIndicatorView()
    
   // private var discoverModels = [Model]()
  //  private var eventImages    = [String: UIImage?]()
    
  //  private var fetchingEvents = false
    private var fetchingModels  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
      //  addCreateEventButton()
        
        resetData()
        reloadData()
        
        browseTableView.delegate = self
        browseTableView.dataSource = self
        browseTableView.register(ModelTableViewCell.self, forCellReuseIdentifier: ModelTableViewCell.reuseID)
        if UITraitCollection.current.userInterfaceStyle == .light {
            browseTableView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
    //        topView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.90)
        } else {
            browseTableView.backgroundColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
            searchField.overrideUserInterfaceStyle = .light
        }
        browseTableView.register(BrowseTableViewCell.self, forCellReuseIdentifier: "BrowseTableViewCell")
        searchField.delegate = self
        searchField.layer.shadowRadius = 3
        searchField.layer.shadowOpacity = 0.95
       // thirdField.layer.cornerRadius = 32
        searchField.layer.shadowColor = UIColor.systemGray3.cgColor
          //note.view?.layer.cornerRadius = 5
        searchField.layer.masksToBounds = false
        searchField.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        searchField.setLeftView1(image: UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))!)
        searchField.tintColor = .darkGray
        
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityIndicator)
        [   activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            activityIndicator.widthAnchor.constraint(equalToConstant: 20),
            activityIndicator.heightAnchor.constraint(equalToConstant: 20)
        ].forEach{ $0.isActive = true}

        // ---------------------------- Collection View --------------------------
        let eventLayout = UICollectionViewFlowLayout()
        let spacing = CGFloat(10)
        let size = (UIScreen.main.bounds.width / 2) - 12
        eventLayout.scrollDirection = .vertical
        eventLayout.minimumLineSpacing = 19
        eventLayout.minimumInteritemSpacing = 0
        eventLayout.sectionInset = UIEdgeInsets(top: 12, left: 8, bottom: 0, right: 8)
        eventLayout.itemSize = CGSize(width: size, height: size + 70)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: browseTableView.frame.minY, width: view.frame.width, height: view.frame.height - browseTableView.frame.minY), collectionViewLayout: eventLayout)
        collectionView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.isHidden = true
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(resetData), for: .valueChanged)
        
        collectionView.register(ModelCollectionViewCell.self, forCellWithReuseIdentifier: ModelCollectionViewCell.reuseID)
        
        view.addSubview(collectionView)
        [   collectionView.topAnchor.constraint(equalTo: browseTableView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ].forEach{ $0.isActive = true}
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
  //  let vc = LaunchViewController()
    
    var modelId = ""
    
    
    @objc public func resetData() {
        
        guard !fetchingModels else {
            collectionView.refreshControl?.endRefreshing()
            activityIndicator.stopAnimating()
            return
        }
        
      //  discoverEvents = []
        modelImages = [:]
        
        searchedModels = []
       // userImages = [:]
        
       // headerView?.resetData()
     //   headerView?.reloadData()
        
        fetchingModels = true
        collectionView.refreshControl?.beginRefreshing()
        collectionView.reloadData()
        fetchingModels = false
        
        reloadData()
    }
    
    private func reloadData() {
        
        collectionView.showsVerticalScrollIndicator = false
        
        guard !fetchingModels else {
            return
        }

        fetchingModels = true
        
        let group = DispatchGroup()
//        // ------------------- Suggested events -------------------
//        FirestoreManager.getDiscoverEvents(lastEventUid: discoverEvents.last?.uid) { events in
//            self.discoverEvents.append(contentsOf: events)
//
//            //if !self.fetchingUsers {
        group.notify(queue: DispatchQueue.main) {
            
            self.visibleModels = Array(self.searchedModels.prefix(6))
            print("\(self.visibleModels) is visibleModels")
            self.updateUI()
        }
//           // }
//        }
    }
    
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
        
        collectionView.showsVerticalScrollIndicator = true
        
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
        activityIndicator.stopAnimating()
        
        fetchingModels = false
    }
    
    
    @IBAction func addChess(_ sender: Any) {
     //   vc.modelUid = "dFCqM6TklPuh0g3v1crC"
        modelId = "dFCqM6TklPuh0g3v1crC"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
     
    }
    
    @IBAction func addRedPainting(_ sender: Any) {
     //   vc.modelUid = "4rIGwSVijh77o4qj1uRt"
        modelId = "4rIGwSVijh77o4qj1uRt"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    @IBAction func addChairGubi(_ sender: Any) {
     //   vc.modelUid = "5LWeAjR4wERzIR6HCCqc"
        modelId = "5LWeAjR4wERzIR6HCCqc"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
 
    }
    @IBAction func addFlatscreen(_ sender: Any) {
     //   vc.modelUid = "MbfjeiKYGfOFTw74eb33"
        modelId = "MbfjeiKYGfOFTw74eb33"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
   
    }
    @IBAction func addLShapeCouch(_ sender: Any) {
     //   vc.modelUid = "CYizrDMSTDonvpxwCxIN"
        modelId = "CYizrDMSTDonvpxwCxIN"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @IBAction func addDanceFrames(_ sender: Any) {
     //   vc.modelUid = "HM7RhXgvplpG5S9gAZnn"
        modelId = "HM7RhXgvplpG5S9gAZnn"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
  //  var tvStand : ModelEntity?
    
    @IBAction func addTVStand(_ sender: Any) {
     //   vc.modelUid = "kUCg8YOdf4buiXMwmxm7"
        modelId = "kUCg8YOdf4buiXMwmxm7"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
      
    }
    
    @IBAction func addWoodenPiano(_ sender: Any) {
     //   vc.modelUid = "5YCiyJ4bMMThRkYG9sQn"
        modelId = "5YCiyJ4bMMThRkYG9sQn"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @IBAction func addSamsungTV(_ sender: Any) {
      //  vc.modelUid = "z44i1R3BuOw2iPi7dV79"
        modelId = "z44i1R3BuOw2iPi7dV79"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @IBAction func addPlant(_ sender: Any) {
      //  vc.modelUid = "7LQYGxvKqTiCvL13pHhl"
        modelId = "7LQYGxvKqTiCvL13pHhl"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @IBAction func add3Frames(_ sender: Any) {
       // vc.modelUid = "SqXjbhl1T0XbAeNw19en"
        modelId = "SqXjbhl1T0XbAeNw19en"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    
    @IBAction func addJordans(_ sender: Any) {
       // vc.modelUid = "T8fZY0CksR9nd9lO1m6e"
        modelId = "T8fZY0CksR9nd9lO1m6e"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
       
    }
    
    @IBAction func addCar(_ sender: Any) {
      //  vc.modelUid = "Kv1OErYZ5Jwl4RkBmTSn"
        modelId = "Kv1OErYZ5Jwl4RkBmTSn"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
        }//}
    
    @IBAction func addMonkeys(_ sender: Any) {
      //  vc.modelUid = "KiwSj0FAbpn5BVc0ulEd"
        modelId = "KiwSj0FAbpn5BVc0ulEd"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @IBAction func addFlowerBoy(_ sender: Any) {
        let defaults = UserDefaults.standard
        
    //    defaults.set("\(self.modelUid ?? "")", forKey: "modelUid")
        defaults.set(true, forKey: "flowerBoy")
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAsapPoster(_ sender: Any) {
      //  vc.modelUid = "mr1hRfNicRNMZTsgVFyv"
        modelId = "mr1hRfNicRNMZTsgVFyv"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    @IBAction func addChancePoster(_ sender: Any) {
       // vc.modelUid = "OrNk4qRPNgaTLtopRFt4"
        modelId = "OrNk4qRPNgaTLtopRFt4"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    @IBAction func addVintageDesk(_ sender: Any) {
      //  vc.modelUid = "mSUMmPdsge7udfbicP1u"
        modelId = "mSUMmPdsge7udfbicP1u"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @IBAction func addFlowerVase(_ sender: Any) {
       // vc.modelUid = "r9vrD5hp7KcgnoHRPlJl"
        modelId = "r9vrD5hp7KcgnoHRPlJl"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @IBAction func addWoodenTable(_ sender: Any) {
        //vc.modelUid = "njiOMAILqHwwP80mqlcK"
        modelId = "njiOMAILqHwwP80mqlcK"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @IBAction func addRusticChair(_ sender: Any) {
       // vc.modelUid = "uEyy2Hj1DviglmP2B2lR"
        modelId = "uEyy2Hj1DviglmP2B2lR"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    @IBAction func addJunji(_ sender: Any) {
      //  vc.modelUid = "bDohDSgk5IlFTkd5ODSx"
        modelId = "bDohDSgk5IlFTkd5ODSx"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @IBAction func addSailingShip(_ sender: Any) {
      //  vc.modelUid = "pAmBHFgojiOHjthpAEKY"
        modelId = "pAmBHFgojiOHjthpAEKY"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @IBAction func addAbstractPainting(_ sender: Any) { //(handler: @escaping (_ completed: Bool, _ error: Error?) -> Void)
       // vc.modelUid = "2mG9Q1zMR6Avye5JZHFX"
        modelId = "2mG9Q1zMR6Avye5JZHFX"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var next = ObjectProfileViewController.instantiate(with: modelId)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//            let currentText = textField.text ?? ""
//            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
//
//            if updatedText.isEmpty {
//                // If the text field is empty, show the full list of models
//                browseTableView.isHidden = false
//                collectionView.isHidden = true
//                return true
//            }
//
//            collectionView.isHidden = false
//            browseTableView.isHidden = true
//            // Update the search results
//            FirestoreManager.searchModels(queryStr: updatedText) { searchedModels in
//                self.searchedModels = searchedModels
//                print("\(searchedModels) is searchedModels")
//                self.visibleModels = Array(self.searchedModels.prefix(6))
//                print("\(self.visibleModels) is visibleModels")
//                self.updateUI()
//            }
//            return true
//        }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                let currentText = textField.text ?? ""
                let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
                // Use a serial queue to avoid race conditions
                let searchQueue = DispatchQueue(label: "searchQueue", qos: .userInitiated)
                // Use a dispatch group to wait for the search task to finish
                let group = DispatchGroup()

                if updatedText.isEmpty {
                    // If the text field is empty, show the full list of models
                    browseTableView.isHidden = false
                    collectionView.isHidden = true
                    return true
                }

                collectionView.isHidden = false
                browseTableView.isHidden = true

                searchQueue.async {
                    // Enter the dispatch group before starting the async task
                    group.enter()
                    // Update the search results
                    FirestoreManager.searchModels(queryStr: updatedText) { searchedModels in
                        self.searchedModels = searchedModels
                        self.visibleModels = Array(self.searchedModels.prefix(6))
                        self.updateUI()
                        // Leave the dispatch group after finishing the async task
                        group.leave()
                    }
                    // Wait for the group to finish and set a timeout
                    let result = group.wait(timeout: .now() + 8)
                    switch result {
                    case .timedOut:
                        // Handle timeout
                        break
                    default:
                        break
                    }
                }
                return true
            }

    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if searchField.text == "" || searchField.text == " " {
            browseTableView.isHidden = false
            collectionView.isHidden = true
        } else {
            guard let searchText = searchField.text else {
                return false
            }
            collectionView.isHidden = false
            browseTableView.isHidden = true
           // searchField.text = searchText.lowercased()

           // ProgressHUD.show()

            FirestoreManager.searchModels(queryStr: searchText) { searchedModels in
                self.searchedModels = searchedModels
                print("\(searchedModels) is searchedModels")
                self.visibleModels = Array(self.searchedModels.prefix(6))
                print("\(self.visibleModels) is visibleModels")
                self.updateUI()
            }
        }
        return false
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//            view.endEditing(true)
//            
//            let dataQueue = DispatchQueue(label: "dataQueue", qos: .userInitiated)
//            var loadError: Error? = nil
//            let group = DispatchGroup()
//            
//            dataQueue.async {
//                if self.searchField.text == "" || self.searchField.text == " " {
//                    self.browseTableView.isHidden = false
//                    self.collectionView.isHidden = true
//                } else {
//                    guard let searchText = self.searchField.text else {
//                        return
//                    }
//                    
//                    group.enter()
//                    FirestoreManager.searchModels(queryStr: searchText) { searchedModels in
//                        self.searchedModels = searchedModels
//                        self.visibleModels = Array(self.searchedModels.prefix(6))
//                        group.leave()
//                    }
//                    
//                    group.wait()
//                    
//                    if let error = loadError {
//                        // handle error
//                        return
//                    }
//                    DispatchQueue.main.async {
//                        self.collectionView.isHidden = false
//                        self.browseTableView.isHidden = true
//                        self.updateUI()
//                    }
//                }
//            }
//            
//            let result = group.wait(timeout: .now() + 8)
//            switch result {
//            case .timedOut:
//                // Handle timeout
//                break
//            default:
//                break
//            }
//            return false
//        }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 12
       // return searchedModels.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = ModelTableViewCell()
//        cell.setContent(searchedModels[indexPath.row])
//        return cell
        let defaults = UserDefaults.standard
            if indexPath.row == 0 {
           //     if defaults.bool(forKey: "finishedWalkthrough") == false {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "new", for: indexPath)
                    tableView.rowHeight = 280
                    if UITraitCollection.current.userInterfaceStyle == .light {
                        cell.textLabel?.textColor = UIColor.yellow
                    } else {
                        cell.textLabel?.textColor = UIColor.green
                    }
                    return cell
              }
              if indexPath.row == 1 {
                  let cell = tableView.dequeueReusableCell(withIdentifier: "newSecond", for: indexPath)
                  tableView.rowHeight = 270
                //  print("most popular cell returned")
                  return cell
              }
               if indexPath.row == 2 {
                   let cell = tableView.dequeueReusableCell(withIdentifier: "newThird", for: indexPath)
                   tableView.rowHeight = 270
                   return cell
               }
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "newFourth", for: indexPath)
                tableView.rowHeight = 270
                return cell
            }
            if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "newFifth", for: indexPath)
                tableView.rowHeight = 270
                return cell
            }
            if indexPath.row == 5 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "newSixth", for: indexPath)
                tableView.rowHeight = 270
                return cell
            }
            if indexPath.row == 6 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "newSeventh", for: indexPath)
                tableView.rowHeight = 270
                return cell
            }
            if indexPath.row == 7 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "newEighth", for: indexPath)
                tableView.rowHeight = 270
                return cell
            }
            if indexPath.row == 8 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "newNinth", for: indexPath)
                tableView.rowHeight = 270
                return cell
            }
        if indexPath.row == 9 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newTenth", for: indexPath)
            tableView.rowHeight = 270
            return cell
        }
        if indexPath.row == 10 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newEleventh", for: indexPath)
            tableView.rowHeight = 270
            return cell
        }
    if indexPath.row == 11 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newTwelfth", for: indexPath)
        tableView.rowHeight = 270
        return cell
    }

             return UITableViewCell()
    }
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return visibleModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ModelCollectionViewCell.reuseID, for: indexPath) as! ModelCollectionViewCell
        
        let model = visibleModels[indexPath.row]
        print("\(self.visibleModels) is visibleModels")
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
        var next = ObjectProfileViewController.instantiate(with: searchedModels[indexPath.row].id)
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
            
        if position > (scrollView.contentSize.height - scrollView.frame.maxY) {
            
            if !fetchingModels {
                
                fetchingModels = true
                
                guard visibleModels.count != searchedModels.count else {
                 //   fetchingModels = false
                    return
                }
                
                activityIndicator.startAnimating()
                visibleModels = Array(searchedModels.prefix(visibleModels.count + 4))
                print("\(self.visibleModels) is visibleModels")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                    self.updateUI()
                }
            }
        }
    }
}

extension UITextField {
  func setLeftView1(image: UIImage) {
      let iconView = UIImageView(frame: CGRect(x: 15, y: 6, width: 20, height: 20)) // set your Own size
    iconView.image = image
      iconView.contentMode = .scaleAspectFill
      
    let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
    iconContainerView.addSubview(iconView)
    leftView = iconContainerView
    leftViewMode = .always
    self.tintColor = .lightGray
  }
}
