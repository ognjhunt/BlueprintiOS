//
//  ModelCollectionViewCell.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 1/4/23.
//

import Foundation
import UIKit

class ModelCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "ModelCollectionCell"
    var modelUid: String = ""
    var isAdded: Bool = false
    
    var price = -1
    
    //get 3 random models from database, get their thumbnails and display/arrange them in stackview side by side, when clicking on thumbnail of model, it will download to scene

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImageView.image = nil
        nameLabel.text = nil
        creatorLabel.text = nil
        priceLabel.text = nil
        infoImageView.image = nil
        creditsImageView.image = nil
        
        activityIndicator.startAnimating()
    }

    //MARK: --- Main Functions ---
    func setContent(_ model: Model, image: UIImage?) {
        
        // --------------- cover image ---------------
        if let image = image {
            activityIndicator.stopAnimating()
            thumbnailImageView.image = image
            
        }
        creditsImageView.image = UIImage(systemName: "diamond.fill")
        creditsImageView.clipsToBounds = true
        creditsImageView.tintColor = .systemYellow
        creditsImageView.contentMode = .scaleAspectFit
        creditsImageView.isHidden = true
        
        infoImageView.clipsToBounds = true
        infoImageView.tintColor = .darkGray
        infoImageView.image = UIImage(systemName: "ellipsis")
        infoImageView.contentMode = .scaleAspectFit
        
        price = model.price ?? 0
        priceLabel.text = "\(model.price ?? 0)"
        creatorLabel.text = model.creatorId
        nameLabel.text = model.name
        
//        let userUid = model.creatorId
//
//        FirestoreManager.getUser(userUid) { user in
//
//            self.creatorLabel.text = user?.name
//
//        }

        if price == 0 {
            self.priceLabel.text = "FREE"
            self.priceLabel.frame = CGRect(x: 3, y: thumbnailImageView.frame.maxY + 8.5, width: 52, height: 17)
        } else {
           // self.creditsImage.image = UIImage(systemName: "diamond.fill")
            self.creditsImageView.frame = CGRect(x: 3, y: thumbnailImageView.frame.maxY + 9, width: 16, height: 16)
            self.creditsImageView.isHidden = false
            self.priceLabel.frame =  CGRect(x: 23, y: thumbnailImageView.frame.maxY + 8.5, width: 250, height: 17)
          //  self.priceLabel.text = "\(model?.price ?? 0)"
        }
//        StorageManager.getThumbnail(model.thumbnail) { (image) in
//            self.thumbnailImageView.image = image
//        }
    }

    //MARK: --- SetupView ---
    let thumbnailImageView = UIImageView()
    let nameLabel    = UILabel()
    let priceLabel    = UILabel()
    let creatorLabel    = UILabel()
    let creditsImageView = UIImageView()
    let infoImageView = UIImageView()
    let activityIndicator = UIActivityIndicatorView()
    
    func setupView() {
    //    selectionStyle = .none
        
        backgroundColor = .clear
        
        // imageView
        let imageHeight = (contentView.frame.width)
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.layer.cornerRadius = imageHeight/12.2
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.frame = CGRect(x: 0, y: 0, width: (contentView.frame.width), height: (contentView.frame.width))

        // nameLabel
        nameLabel.frame = CGRect(x: 3, y: thumbnailImageView.frame.maxY + 29.5, width: (contentView.frame.width) - 20, height: 17.5)
        nameLabel.numberOfLines = 1
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = .label
        //(UIScreen.main.bounds.width / 2) - 12
       // nameLabel.sizeToFit()
        creatorLabel.frame = CGRect(x: 3, y: thumbnailImageView.frame.maxY + 53, width: (contentView.frame.width) - 20, height: 16)
        creatorLabel.numberOfLines = 1
        creatorLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        creatorLabel.textColor = UIColor(red: 73/255, green: 73/255, blue: 73/255, alpha: 1.0)
      //  creatorLabel.sizeToFit() //(UIScreen.main.bounds.width / 2) - 12

//        priceLabel.frame = CGRect(x: 3, y: 191.5, width: 52, height: 17)
        priceLabel.numberOfLines = 1
        priceLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        priceLabel.textColor = .label
        
       
        
        
        infoImageView.frame = CGRect(x: thumbnailImageView.frame.maxX - 25, y: thumbnailImageView.frame.maxY + 6, width: 22, height: 22)
        
        
        //--------------- activity indicator ---------------
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(activityIndicator)
        [   activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
            activityIndicator.heightAnchor.constraint(equalToConstant: 20),
            activityIndicator.widthAnchor.constraint(equalToConstant: 20),
        ].forEach { $0.isActive = true }
        
        // addSubviews
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(creditsImageView)
        contentView.addSubview(infoImageView)
        contentView.addSubview(creatorLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(activityIndicator)
    }
}
