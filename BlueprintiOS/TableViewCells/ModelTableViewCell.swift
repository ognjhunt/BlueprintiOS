//
//  ModelTableViewCell.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 1/16/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import Foundation
import UIKit

class ModelTableViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    
    static let reuseID = "ModelCollectionCell1"
    var modelUid: String = ""
    var isAdded: Bool = false
    
    //get 3 random models from database, get their thumbnails and display/arrange them in stackview side by side, when clicking on thumbnail of model, it will download to scene

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: --- Main Functions ---
    func setContent(_ model: Model) {
        self.modelUid = model.id
    
        nameLabel.text = model.name

        StorageManager.getThumbnail(model.thumbnail) { (image) in
            self.thumbnailImageView.image = image
        }
    }

    //MARK: --- SetupView ---
    let thumbnailImageView = UIImageView()
    let nameLabel    = UILabel()
    
    func setupView() {
        selectionStyle = .none
        
        backgroundColor = .clear
        
        // imageView
        let imageHeight = contentView.frame.height - 10
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.layer.cornerRadius = imageHeight/2
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.frame = CGRect(x: 20, y: 5, width: imageHeight, height: imageHeight)

        // nameLabel
        nameLabel.frame = CGRect(x: thumbnailImageView.frame.maxX + 10, y: 0, width: contentView.frame.width - (thumbnailImageView.frame.maxX + 10), height: thumbnailImageView.frame.height)
        nameLabel.center = CGPoint(x: nameLabel.frame.midX, y: thumbnailImageView.frame.midY)
        
        // addSubviews
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(nameLabel)
    }
}
