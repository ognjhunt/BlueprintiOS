//
//  ContentPriceTableViewCell.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 1/5/23.
//

import UIKit

class ContentPriceTableViewCell: UITableViewCell {

    // Declare the model property
    var model: Model!
    
    // Declare a static constant for the identifier
    static let identifier = "contentPriceCell"
    
    // Declare an infoImageView property
    let infoImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 114, y: 12.5, width: 35, height: 35))
        // Enable clipping and set the content mode
        imageView.clipsToBounds = true
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        // Enable user interaction
        imageView.isUserInteractionEnabled = true
        // Set the image
        imageView.image = UIImage(systemName: "info.circle")
        return imageView
    }()
    
    // Declare a private priceLabel property
    private let priceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 20.5, width: 85.5, height: 19))
        // Set the number of lines to 1
        label.numberOfLines = 1
        // Set the label text
        label.text = "Price/Cost"
        // Set the font and weight
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        // Set the text color
        label.textColor = .black
        return label
    }()
    
    // Declare a priceTextField property
    let priceTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: UIScreen.main.bounds.width - 116, y: 13, width: 96, height: 34))
        // Set the font
        textField.font = UIFont.systemFont(ofSize: 15)
        // Set the default text
        textField.text = "0"
        // Set the border style
        textField.borderStyle = .roundedRect
        // Set the text alignment and keyboard type
        textField.textAlignment = .right
        textField.keyboardType = .numberPad
        // Set the autocapitalization type
        textField.autocapitalizationType = .sentences
        // Enable user interaction
        textField.isUserInteractionEnabled = true
        // Add padding to the right of the text field
        let paddingView = UIView(frame: CGRectMake(textField.frame.width, 0, 4, textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always
        
        return textField
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
        contentView.addSubview(priceLabel)
        contentView.addSubview(infoImageView)
        contentView.addSubview(priceTextField)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
}
