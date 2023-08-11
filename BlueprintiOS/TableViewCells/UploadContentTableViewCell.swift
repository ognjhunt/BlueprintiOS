//
//  UploadContentTableViewCell.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 12/16/22.
//

import UIKit

class UploadContentTableViewCell: UITableViewCell {
    
    var user: User!
    
    static let identifier = "saveContentCell"
    
    let uploadButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 20, y: 10, width: UIScreen.main.bounds.width - 40, height: 50))
        button.setTitle("Save", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .tintColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 8
        return button
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
//        if UITraitCollection.current.userInterfaceStyle == .light {
////            backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
////            contentView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 244/255, alpha: 1.0)
//        } else {
//            backgroundColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
//            contentView.backgroundColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
//        }
//        downloadButton.addSubview(activityIndicator)
        contentView.addSubview(uploadButton)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
