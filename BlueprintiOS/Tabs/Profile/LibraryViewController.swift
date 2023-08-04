//
//  LibraryViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 12/1/21.
//  Copyright © 2021 Placenote. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate  {
  

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    var getCreated = true
    
    var user: User!
    var userUid     : String!
    let db = Firestore.firestore()
    
    var numLibrary = -1
    var numCreated = -1
    
    private var searchedModels  = [Model]()
    private var models        = [Model]()
    private var visibleModels = [Model]()
    private var modelImages = [String: UIImage?]()
    private var fetchingImages = false

    var collectionView              : UICollectionView!
    private let activityIndicator   = UIActivityIndicatorView()
    
    
    internal static func instantiate(with userId: String) -> LibraryViewController {

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LibraryVC") as! LibraryViewController
        vc.userUid = userId
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        resetData()
      loadData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ModelTableViewCell.self, forCellReuseIdentifier: ModelTableViewCell.reuseID)
        if UITraitCollection.current.userInterfaceStyle == .light {
            tableView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
    //        topView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.90)
        } else {
            tableView.backgroundColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
            //searchField.overrideUserInterfaceStyle = .light
        }
        tableView.register(BrowseTableViewCell.self, forCellReuseIdentifier: "BrowseTableViewCell")
        searchTextField.delegate = self
        searchTextField.tag = 0
        searchTextField.setLeftView(image: UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))!)
        searchTextField.tintColor = .lightGray
//        searchBar.delegate = self
//        searchBar.searchBarStyle = .minimal
//        searchBar.barTintColor = .white
//        searchBar.autocapitalizationType = .none
      //  searchBar.layer.borderWidth = 1
       // searchBar.layer.borderColor UIColor.darkGray.cgColor
        // Do any additional setup after loading the view.
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
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: tableView.frame.minY, width: view.frame.width, height: view.frame.height - tableView.frame.minY), collectionViewLayout: eventLayout)
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
        [   collectionView.topAnchor.constraint(equalTo: tableView.topAnchor),
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
    
    
    @objc public func resetData() {

        guard !fetchingImages else {
            return
        }

      //  discoverEvents = []
        modelImages = [:]

        searchedModels = []
       // userImages = [:]

       // headerView?.resetData()
     //   headerView?.reloadData()

        fetchingImages = true
        collectionView.refreshControl?.beginRefreshing()
        collectionView.reloadData()
        fetchingImages = false

        loadData()
    }
    
    private func updateUI() {
        
        collectionView.showsVerticalScrollIndicator = true
        
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
        activityIndicator.stopAnimating()
        
        fetchingImages = false
    }
    
    @objc func loadData() {
        // Use a serial queue to avoid race conditions
        let dataQueue = DispatchQueue(label: "dataQueue", qos: .userInitiated)
        // Keep track of any errors that occur
        var loadError: Error? = nil
        // Use a dispatch group to wait for all async tasks to finish
        let group = DispatchGroup()
        
        dataQueue.async {
            self.modelImages = [:]
            // Enter the group before starting the first async task
            group.enter()
            if (self.getCreated) {
                FirestoreManager.getProfileLibrary(self.userUid) { library in
                    self.models = library.sorted(by: { $0.date > $1.date })
                    self.numLibrary = library.count
                    // Leave the group after finishing the first async task
                    group.leave()
                }
            } else {
                // Leave the group after finishing the first async task
                group.leave()
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTextField.layer.borderColor = UIColor.systemBlue.cgColor
        searchTextField.layer.borderWidth = 2
        searchTextField.tintColor = .systemBlue
        searchTextField.layer.cornerRadius = 10
    }
    
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
//          //  collectionView.isHidden = false
//           // browseTableView.isHidden = true
//            // Update the search results
//        FirestoreManager.searchProfileLibrary(allModels: self.models, queryStr: updatedText) { searchedModels in
//                self.searchedModels = searchedModels
//                print("\(searchedModels) is searchedModels")
//                self.visibleModels = Array(self.searchedModels.prefix(6))
//                print("\(self.visibleModels) is visibleModels")
//                self.updateUI()
//            }
//            return true
//        }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        // Use a serial queue to avoid race conditions
//        let dataQueue = DispatchQueue(label: "dataQueue", qos: .userInitiated)
//        // Keep track of any errors that occur
//        var loadError: Error? = nil
//        // Use a dispatch group to wait for all async tasks to finish
//        let group = DispatchGroup()
//
//        let currentText = textField.text ?? ""
//        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
//
//        dataQueue.async {
//            if updatedText.isEmpty {
//                // If the text field is empty, show the full list of models
//                self.loadData()
//            } else {
//                // Update the search results
//                group.enter()
//                FirestoreManager.searchProfileLibrary(allModels: self.models, queryStr: updatedText) { searchedModels in
//                    self.searchedModels = searchedModels
//                    self.visibleModels = Array(self.searchedModels.prefix(6))
//                    group.leave()
//                }
//                // Wait for the group to finish and check for errors
//                group.wait()
//            }
//        }
//        // Set a timeout for the dispatch group
//        let result = group.wait(timeout: .now() + 8)
//        switch result {
//        case .timedOut:
//            // Handle timeout
//            break
//        default:
//            break
//        }
//        DispatchQueue.main.async {
//            self.updateUI()
//        }
//        return true
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

        if updatedText.isEmpty {
            // If the text field is empty, reload the original data and update the UI
            loadData()
            updateUI()
        } else {
            // Update the search results
            FirestoreManager.searchProfileLibrary(allModels: self.models, queryStr: updatedText) { searchedModels in
                self.searchedModels = searchedModels
                self.visibleModels = Array(self.searchedModels.prefix(6))
                self.updateUI()
            }
        }
        return true
    }


    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           view.endEditing(true)
           if searchTextField.text == "" {
               // Reset the models arrays to their original values
               visibleModels = Array(models.prefix(6))
               searchedModels = models
               searchTextField.layer.borderWidth = 0
                 searchTextField.tintColor = .lightGray
               self.updateUI()
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

    
    @IBAction func filterAction(_ sender: Any) {
        //filter between Created and Collected
    }
    
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
              //  }
           /*     guard let cell = tableView.dequeueReusableCell(withIdentifier: BrowseTableViewCell.identifier, for: indexPath) as? BrowseTableViewCell else {
                    return UITableViewCell()
                }
                if self.loadedTableView == false{
                    self.getRandomModelID { (success) -> Void in
                        if success {
                            // do second task if success
                            
                            cell.configure(with: self.modelId1)
                            cell.configure2(with: self.modelId2)
                            
                        }
                    }
                    let tap = UITapGestureRecognizer(target: self, action: #selector(addItem))
                    cell.itemView1.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(addItem2))
                    cell.itemView2.addGestureRecognizer(tap2)
                    tableView.rowHeight = 280
                    self.loadedTableView = true
                    return cell
                } else {
                    cell.configure(with: self.modelId1)
                    cell.configure2(with: self.modelId2)
                    return cell
                }*/
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    

}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
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
                if searchedModels.count == 0 {
                    guard visibleModels.count != models.count else {
                        return
                    }
                    visibleModels = Array(models.prefix(visibleModels.count + 4))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        self.updateUI()
                    }
                } else {
                    guard visibleModels.count != searchedModels.count else {
                        return
                    }
                    visibleModels = Array(searchedModels.prefix(visibleModels.count + 4))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        self.updateUI()
                    }
                }
            }
        }
    }

    
}
