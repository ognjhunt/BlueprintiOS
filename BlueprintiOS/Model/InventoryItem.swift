//
//  InventoryItem.swift
//  XCAInventoryTracker
//
//  Created by Alfian Losari on 30/07/23.
//

import FirebaseFirestoreSwift
import Foundation

struct InventoryItem: Identifiable, Codable, Equatable {
    
    var id = UUID().uuidString
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
    
    var name: String
    var creatorId: String // = ""
    var description: String
    var price: Double
    var category: String
    var privacy: String
    var tags: String// = ""
    var scale: Double// = 1
    var size: Double // = 10
    var date = Date()
    
    
   // var modelName       : String
    var usdzLink: String?
    var usdzURL: URL? {
        guard let usdzLink else { return nil }
        return URL(string: usdzLink)
    }
    
    
   // var thumbnail: String?
    var thumbnailLink: String?
    var thumbnailURL: URL? {
        guard let thumbnailLink else { return nil }
        return URL(string: thumbnailLink)
    }
    
}
