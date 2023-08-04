//
//  ContentPublicTableViewCell.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 1/5/23.
//

import UIKit

class ContentPublicTableViewCell: UITableViewCell {
    
    // Declare the model property
    var model: Model!
    
    // Declare a static constant for the identifier
    static let identifier = "contentPublicCell"
 
    // UIImageView to show info icon
    let infoImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 74, y: 12.5, width: 35, height: 35))
        imageView.clipsToBounds = true
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "info.circle")
        return imageView
    }()

    // label to show "Public" text
    private let label: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 20.5, width: 95, height: 20))
        label.numberOfLines = 1
        label.text = "Public"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()

    // switch to control public/private state
    let publicSwitch: UISwitch = {
        let connect = UISwitch(frame: CGRect(x: UIScreen.main.bounds.width - 69, y: 14.5, width: 51, height: 31))
        connect.isOn = true
        return connect
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
        contentView.addSubview(infoImageView)
        contentView.addSubview(label)
        contentView.addSubview(publicSwitch)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
