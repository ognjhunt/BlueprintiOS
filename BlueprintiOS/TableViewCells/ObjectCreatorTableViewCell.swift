//
//  ObjectCreatorTableViewCell.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 10/3/22.
//

import UIKit

class ObjectCreatorTableViewCell: UITableViewCell {

    var user: User!
    var model: Model!
    
    static let identifier = "ObjectCreatorTableViewCell"
 
    private let sectionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: 130, height: 25.5))
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        label.textColor = .label
        label.text = "Created by"
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
    
    let creatorNameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 68, y: 62, width: 250, height: 31))
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .link
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let creatorImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 20, y: 57.5, width: 40, height: 40))
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
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
        contentView.addSubview(creatorNameLabel)
        contentView.addSubview(creatorImageView)
        contentView.addSubview(sectionLabel)
        contentView.addSubview(expandImageView)
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
            
        //    if model?.creatorId != nil || model?.creatorId != ""{
                FirestoreManager.getUser(model?.creatorId ?? "1zMDe5Raoee3At3jjFdjVVRqbIt2") { user in
                    StorageManager.getProPic(model?.creatorId ?? "eUWpeKULDhN1gZEyaeKvzPNkMEk1") { image in
                        self.creatorImageView.image = image
                    }
                    let name = user?.name
                    let username = user?.username
                    if name != nil && name != "" && name != "Optional(\(""))" {
                        self.creatorNameLabel.text = "by \(name ?? "")"
                    } else {
                        self.creatorNameLabel.text = "by \(username ?? "")"
                    }
                }
            }
            if self.creatorNameLabel.text == "" {
                self.creatorNameLabel.text = "by Nijel Hunt"
       //     }
        }
    }

}
