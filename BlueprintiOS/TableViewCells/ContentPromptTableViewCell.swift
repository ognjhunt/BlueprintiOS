//
//  ContentPromptTableViewCell.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 1/5/23.
//

import UIKit

class ContentPromptTableViewCell: UITableViewCell {
    
    // Declare the model property
    var model: Model!
    
    // Declare a static constant for the identifier
    static let identifier = "contentPromptCell"
    
    // Declare a private promptLabel property
    private let promptLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 11, width: 145, height: 20))
        // Set the number of lines to 1
        label.numberOfLines = 1
        // Set the label text
        label.text = "Prompt"
        // Set the font and weight
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        // Set the text color
        label.textColor = .black
        return label
    }()
    
    // Declare a promptTextField property
    let promptTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 20, y: 41, width: UIScreen.main.bounds.width - 40, height: 40))
        // Set the font
        textField.font = UIFont.systemFont(ofSize: 16)
        // Set the autocapitalization type
        textField.autocapitalizationType = .sentences
        // Disable user interaction
        textField.isUserInteractionEnabled = false
        // Set the border style
        textField.borderStyle = .roundedRect
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
        // Add the promptLabel and promptTextField as subviews
        contentView.addSubview(promptLabel)
        contentView.addSubview(promptTextField)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

