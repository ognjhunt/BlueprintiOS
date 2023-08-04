//
//  DeleteContentTableViewCell.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 1/5/23.
//

import UIKit

class DeleteContentTableViewCell: UITableViewCell {

    var model: Model!
    
    static let identifier = "deleteContentCell"
    
    let deleteButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
        button.backgroundColor = .clear
        button.tintColor = .clear
        button.isUserInteractionEnabled = true
        return button
    }()
 
    let xImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 20, y: 22, width: 22, height: 25.5))
        imageView.clipsToBounds = true
        imageView.tintColor = .black
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "x.circle")
        return imageView
    }()
    
    private let deleteLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 49, y: 26, width: 120, height: 18))
        label.numberOfLines = 1
        label.text = "Delete content"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .systemRed
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
        
        contentView.addSubview(deleteButton)
        contentView.addSubview(xImageView)
        contentView.addSubview(deleteLabel)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
