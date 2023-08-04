//
//  ObjectProductLinkTableViewCell.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 10/3/22.
//

import UIKit

class ObjectProductLinkTableViewCell: UITableViewCell {

    var model: Model!
    
    static let identifier = "ObjectProductLinkTableViewCell"
 
    private let sectionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: 130, height: 25.5))
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        label.textColor = .label
        label.text = "Product Link"
        return label
    }()
    
    private let expandImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 340, y: 25, width: 22, height: 17))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        let smallConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .small)
        let smallBoldDoc = UIImage(systemName: "chevron.down", withConfiguration: smallConfig)
        imageView.image = smallBoldDoc
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    let objectProductLinkLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 54.5, width: 374, height: 22))
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .link
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        contentView.addSubview(objectProductLinkLabel)
        contentView.addSubview(expandImageView)
        contentView.addSubview(sectionLabel)
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
////        objectNameLabel.text = nil
////        priceLabel.text = nil
////        hostLabel.text = nil
////        objectIdentifierLabel.text = nil
////        objectTypeLabel.text = nil
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//      //  priceLabel.sizeToFit()
//     //   hostLabel.sizeToFit()
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with modelId: String) {
        FirestoreManager.getModel(modelId) { model in
            //let id = model?.id
            self.objectProductLinkLabel.text = model?.productLink // "www.google.com" // model?.productLink
        }
    }

}
