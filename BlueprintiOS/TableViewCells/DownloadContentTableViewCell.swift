//
//  DownloadContentTableViewCell.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 11/25/22.
//

import UIKit
import FirebaseAuth

class DownloadContentTableViewCell: UITableViewCell {
    
    var user: User!
    var model: Model!
    
    static let identifier = "DownloadContentTableViewCell"
 
    
    let downloadButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 20, y: 10, width: UIScreen.main.bounds.width - 40, height: 50))
        button.setTitle("Add to Library", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .tintColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 8
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: ((UIScreen.main.bounds.width - 40) / 2) - 10, y: 15, width: 20, height: 20))
        view.tintColor = .lightGray
        view.hidesWhenStopped = true
        view.isHidden = true
        return view
    }()

    var userPoints = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if Auth.auth().currentUser != nil {
            FirestoreManager.getUser(Auth.auth().currentUser?.uid ?? "") { user in
                self.userPoints = user?.points ?? 0
                // if user?.collectedContentIDs.contains(<#T##other: Collection##Collection#>)
            }
        }
       // downloadButton.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        if UITraitCollection.current.userInterfaceStyle == .light {
//            backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
//            contentView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
        } else {
            backgroundColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
            contentView.backgroundColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
        }
        downloadButton.addSubview(activityIndicator)
        contentView.addSubview(downloadButton)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
   // var price = 0

    public func configure(with modelId: String) {
        FirestoreManager.getModel(modelId) { model in
            //let id = model?.id
            if Auth.auth().currentUser != nil {
                FirestoreManager.getUser(Auth.auth().currentUser?.uid ?? "") { user in
                    if user?.collectedContentIDs.contains(modelId) == true || model?.creatorId == Auth.auth().currentUser?.uid ?? "" { // 
                        //                    self.downloadButton.setTitle("Collected", for: .normal)
                        self.downloadButton.setTitle("Add to Library", for: .normal)
                        self.downloadButton.setTitleColor(UIColor.white, for: .normal)
                        self.downloadButton.backgroundColor = .tintColor
                    } else {
                        let price = model?.price ?? 0
                        if price == 0 {
                            self.downloadButton.setTitle("Add to Library", for: .normal) //.text = "FREE"
                        } else {
                            let imageView = UIImageView()
                        let image = UIImage(systemName: "diamond.fill")
                            imageView.tintColor = .systemYellow
                            imageView.image = image
                           // self.downloadButton.tintColor = .systemYellow
                            self.downloadButton.setImage(imageView.image, for: .normal)
                            self.downloadButton.imageView?.contentMode = .scaleAspectFit
                            self.downloadButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 130, bottom: 15, right: 100) //adjust these to have fit right

                      //      button.titleEdgeInsets = UIEdgeInsets(top:0, left:10, bottom:0, right:0) //adjust insets to have fit how you want
                            self.downloadButton.setTitle("Purchase (\(price) credits)", for: .normal)
                        }
                    }
                }
            } else {
                let price = model?.price ?? 0
                if price == 0 {
                    self.downloadButton.setTitle("Download", for: .normal) //.text = "FREE"
                } else {
                    self.downloadButton.setTitle("Purchase (\(price) credits)", for: .normal)
                }
            }
        }
    }
    
   
    
}
