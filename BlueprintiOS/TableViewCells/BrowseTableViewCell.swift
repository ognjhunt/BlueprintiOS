//
//  BrowseTableViewCell.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 9/14/22.
//

import UIKit

class BrowseTableViewCell: UITableViewCell {
    
    var user: User!
    var model: Model!
    
    static let identifier = "BrowseTableViewCell"
    
    
    let itemView1: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let itemView2: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let itemImageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let infoImageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.tintColor = .darkGray
        imageView.image = UIImage(systemName: "ellipsis")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let priceLabel1: UILabel = {
        let label = UILabel(frame: CGRect(x: 3, y: 191.5, width: 52, height: 17))
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let nameLabel1: UILabel = {
        let label = UILabel(frame: CGRect(x: 3, y: 212.5, width: 72, height: 17.5))
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let hostLabel1: UILabel = {
        let label = UILabel(frame: CGRect(x: 3, y: 236, width: 72, height: 16))
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .lightGray // UIColor(red: 73/255, green: 73/255, blue: 73/255, alpha: 1.0)
        return label
    }()
    
    private let itemImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let infoImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.tintColor = .darkGray
        imageView.image = UIImage(systemName: "ellipsis")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let priceLabel2: UILabel = {
        let label = UILabel(frame: CGRect(x: 3, y: 191.5, width: 52, height: 17))
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let nameLabel2: UILabel = {
        let label = UILabel(frame: CGRect(x: 3, y: 212.5, width: 72, height: 17.5))
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let hostLabel2: UILabel = {
        let label = UILabel(frame: CGRect(x: 3, y: 236, width: 72, height: 16))
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .lightGray // UIColor(red: 73/255, green: 73/255, blue: 73/255, alpha: 1.0)
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
            backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
            contentView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
        } else {
            backgroundColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
            contentView.backgroundColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
        }
        itemView1.addSubview(itemImageView1)
        itemView1.addSubview(priceLabel1)
        itemView1.addSubview(nameLabel1)
        itemView1.addSubview(hostLabel1)
        itemView1.addSubview(infoImageView1)
        
        itemView2.addSubview(itemImageView2)
        itemView2.addSubview(priceLabel2)
        itemView2.addSubview(nameLabel2)
        itemView2.addSubview(hostLabel2)
        itemView2.addSubview(infoImageView2)
        
        contentView.addSubview(itemView1)
        contentView.addSubview(itemView2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView1.image = nil
        infoImageView1.image = nil
        nameLabel1.text = nil
        priceLabel1.text = nil
        hostLabel1.text = nil
        
        itemImageView2.image = nil
        infoImageView2.image = nil
        nameLabel2.text = nil
        priceLabel2.text = nil
        hostLabel2.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        itemView1.frame = CGRect(x: 8, y: 12, width: (UIScreen.main.bounds.width / 2) - 12, height: 253)
        itemView2.frame = CGRect(x: (UIScreen.main.bounds.width / 2) + 4, y: 12, width: (UIScreen.main.bounds.width / 2) - 12, height: 253)
        priceLabel1.sizeToFit() //(UIScreen.main.bounds.width / 2) - 12
        nameLabel1.frame = CGRect(x: 3, y: 212.5, width: (UIScreen.main.bounds.width / 2) - 20, height: 17.5) //(UIScreen.main.bounds.width / 2) - 12
        hostLabel1.sizeToFit() //(UIScreen.main.bounds.width / 2) - 12
        itemImageView1.frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width / 2) - 12, height: (UIScreen.main.bounds.width / 2) - 12)
        infoImageView1.frame = CGRect(x: 158, y: 196.5, width: 22, height: 7)
        
        priceLabel2.sizeToFit() //(UIScreen.main.bounds.width / 2) - 12
        nameLabel2.frame = CGRect(x: 3, y: 212.5, width: (UIScreen.main.bounds.width / 2) - 20, height: 17.5)
        hostLabel2.sizeToFit() //(UIScreen.main.bounds.width / 2) - 12
        itemImageView2.frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width / 2) - 12, height: (UIScreen.main.bounds.width / 2) - 12)
        infoImageView2.frame = CGRect(x: 158, y: 196.5, width: 22, height: 7)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with modelId: String) {
        FirestoreManager.getModel(modelId) { model in
            //let id = model?.id
            if model?.price == 0 {
                self.priceLabel1.text = "FREE"
            } else {
                self.priceLabel1.text = "\(model?.price)" ?? "FREE 2121"
            }
            print(self.priceLabel1.text)
            self.nameLabel1.text = model?.name
            self.hostLabel1.text = model?.creatorId
            //let creator = model?.creatorId

//            if self.priceLabel1.text == "" || self.priceLabel1.text == "$" {
//                self.priceLabel1.text = "FREE"
//            }
            if model?.creatorId != nil || model?.creatorId != ""{
                FirestoreManager.getUser(model?.creatorId ?? "1zMDe5Raoee3At3jjFdjVVRqbIt2") { user in
                    let name = user?.name
                    let username = user?.username
                    if name != nil || name != "" {
                        self.hostLabel1.text = name
                    } else {
                        self.hostLabel1.text = username
                    }
                }
            }
            if self.hostLabel1.text == "" {
                self.hostLabel1.text = "Nijel Hunt"
            }
            let thumbnailName = model?.thumbnail
            StorageManager.getModelThumbnail(thumbnailName ?? "") { image in
                self.itemImageView1.image = image
            }
        }
    }
    
    public func configure2(with modelId: String) {
        FirestoreManager.getModel(modelId) { model in
            //let id = model?.id
            if model?.price == 0 {
                self.priceLabel2.text = "FREE"
            } else {
                self.priceLabel2.text = "\(model?.price)" ?? "FREE 2121"
            }
            print(self.priceLabel2.text)
            self.nameLabel2.text = model?.name
          //  self.hostLabel2.text = model?.creatorId
            //let creator = model?.creatorId

//            if self.priceLabel2.text == "" || self.priceLabel2.text == "$" {
//                self.priceLabel2.text = "FREE"
//            }
            if model?.creatorId != nil || model?.creatorId != ""{
                FirestoreManager.getUser(model?.creatorId ?? "1zMDe5Raoee3At3jjFdjVVRqbIt2") { user in
                    let name = user?.name
                    let username = user?.username
                    if name != nil || name != "" {
                        self.hostLabel2.text = name
                    } else {
                        self.hostLabel2.text = username
                    }
                }
            }
            if self.hostLabel2.text == "" {
                self.hostLabel2.text = "Nijel Hunt"
            }
            let thumbnailName2 = model?.thumbnail
            StorageManager.getModelThumbnail(thumbnailName2 ?? "") { image in
                self.itemImageView2.image = image
            }
        }
    }

}
