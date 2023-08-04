//
//  Model.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 10/13/21.
//  Copyright © 2021 Placenote. All rights reserved.
//
import Foundation
import UIKit

public class Model {
    
    var id             : String = ""
    var creatorId      : String = ""
    var name            : String = ""
    var description  : String = ""
    var category        : String = ""
    var scale           : Double = 1
    var size            : Double = 10
    var thumbnail       : String? = nil
    var modelName       : String = ""
     var isPublic        : Bool?
     var price          : Int?
    var productLink     : String = ""
    var prompt     : String = ""
    var date = Date()
    
    static let CREATOR         = "creatorId"
    static let DATE         = "date"
    static let NAME         = "name"
    static let MODELNAME         = "modelName"
    
    init(_ userFirDoc: [String:Any]) {
        
        // uid
        if let id = userFirDoc["id"] as? String {
            self.id = id
        }
        
        // name
        if let name = userFirDoc["name"] as? String {
            self.name = name
        }
        
        if let name = userFirDoc["prompt"] as? String {
            self.prompt = name
        }
        
        if let productLink = userFirDoc["productLink"] as? String {
            self.productLink = productLink
        }
        
        if let date = userFirDoc["date"] as? Date {
            self.date = date
        }
        
        // emailStr
        if let creatorId = userFirDoc["creatorId"] as? String {
            self.creatorId = creatorId
        }
        
        if let description = userFirDoc["description"] as? String {
            self.description = description
        }
        
        if let category = userFirDoc["category"] as? String {
            self.category = category
        }
        
        // name
        if let scale = userFirDoc["scale"] as? Double {
            self.scale = scale
        }
        
        //usernameStr
        if let size = userFirDoc["size"] as? Double {
            self.size = size
        }
        
        if let thumbnail = userFirDoc["thumbnail"] as? String {
            self.thumbnail = thumbnail
        }
        
        if let modelName = userFirDoc["modelName"] as? String {
            self.modelName = modelName
        }
        
        if let isPublic = userFirDoc["isPublic"] as? Bool {
            self.isPublic = isPublic
        }
        
        if let price = userFirDoc["price"] as? Int {
            self.price = price
        }
        
    }
    
//     init(id: String, creatorUid: String, name: String, modelName: String, descriptionStr: String, category: String, scale: Int, size: Int, thumbnail: String) {//}, companySummary: String, needs: String, numberOfEmployees: Double, location: String
//         self.id = id
//         self.creatorUid = creatorUid
//         self.name = name
//         self.modelName = modelName
//         self.descriptionStr = descriptionStr
//         self.category = category
//         self.scale = scale
//         self.size = size
//         self.thumbnail = thumbnail
//     }
//
//     static func transformModel(dict: [String: Any]) -> Model? {
//         guard let id = dict["id"] as? String,
//             let creatorUid = dict["creatorUid"] as? String,
//             let name = dict["name"] as? String,
//             let modelName = dict["modelName"] as? String,
//             let descriptionStr = dict["descriptionStr"] as? String,
//             let category = dict["category"] as? String,
//            let thumbnail = dict["thumbnail"] as? String,
//             let scale = dict["scale"] as? Int,
//             let size = dict["size"] as? Int else {
//                 return nil
//         }
//         let model = Model(id: id, creatorUid: creatorUid, name: name, modelName: modelName, descriptionStr: descriptionStr, category: category, scale: scale, size: size, thumbnail: thumbnail)
//
//
//         if let isPublic = dict["isPublic"] as? Bool{
//             model.isPublic = isPublic
//         }
//
//         if let price = dict["price"] as? String {
//             model.price = price
//         }
//
//         return model
//     }
//
//     func updateData(key: String, value: String) {
//         switch key {
//         case "id": self.id = value
//         case "creatorUid": self.creatorUid = value
//         case "name": self.name = value
//
//    //     case "screenCount": self.screenCount = value
//         case "category": self.category = value
//     //    case "popularityRating": self.popularityRating = value
//
//         case "thumbnail": self.thumbnail = value
//      //   case "rate": self.rate = value
//       //  case "estimatedImpressions": self.estimatedImpressions = value
//         // case "location": self.location = value
//         default: break
//         }
//     }
 }
