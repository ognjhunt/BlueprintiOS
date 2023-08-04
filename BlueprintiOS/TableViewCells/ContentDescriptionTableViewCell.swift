//
//  ContentDescriptionTableViewCell.swift
//  Indoor Blueprint
//
//  Created by Nijel Hunt on 1/5/23.
//

import UIKit

class ContentDescriptionTableViewCell: UITableViewCell {
    
    // Declare the model property
    var model: Model!
    
    // Declare a static constant for the identifier
    static let identifier = "contentDescriptionCell"
 
    // Declare a private descriptionLabel property
    private let descriptionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 11, width: 95, height: 20))
        // Set the number of lines to 1
        label.numberOfLines = 1
        // Set the label text
        label.text = "Description"
        // Set the font and weight
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        // Set the text color
        label.textColor = .black
        return label
    }()
    
    // Declare a descriptionTextView property
    let descriptionTextView: UITextView = {
        let textView = UITextView(frame: CGRect(x: 20, y: 41, width: UIScreen.main.bounds.width - 40, height: 70))
        // Set the font
        textView.font = UIFont.systemFont(ofSize: 15)
        // Enable clipsToBounds
        textView.clipsToBounds = true
        // Set the autocapitalization type
        textView.autocapitalizationType = .sentences
        // Enable user interaction
        textView.isUserInteractionEnabled = true
        // Set the corner radius and border properties
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        // Add insets to the text view
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        return textView
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
        // Add the descriptionLabel and descriptionTextView as subviews
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

