//
//  User.swift
//  Accel
//
//  Created by Nijel Hunt on 6/21/19.
//  Copyright © 2019 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit

public class User {
    private(set) var uid          : String = ""
    private(set) var name         : String = ""
    private(set) var email        : String = ""
    private(set) var username     : String = ""
    private(set) var deviceToken     : String = ""
    private(set) var referralCode     : String = ""
    private(set) var currentConnectedNetworkID     : String = ""
    private(set) var numSessions     : Int = 0
    private(set) var uploadedContentCount     : Int = 0
    private(set) var collectedContentCount     : Int = 0
    private(set) var collectedContentIDs     = [String]()
    private(set) var createdContentIDs     = [String]()
    private(set) var points     : Int?
    private(set) var amountEarned     : Double?
    // Followers and Following
    private(set) var followers    = [String]()
    private(set) var following    = [String]()
    
    private(set) var latitude          : Double?// = ""
    private(set) var longitude          : Double?
    
    private(set) var historyNetworkIDs    = [String]()
    private(set) var createdNetworkIDs    = [String]()
    
    private(set) var likedAnchorIDs    = [String]()
    
    // Subscriptions
    private(set) var subscriptions  = [String]()
    private(set) var subscribers    = [String]()
    
    // Profile picture
    private(set) var profileImageUrl   : String?
    
    // Asset
    private(set) var assetUids    = [String]()
    private(set) var ownedAssets = [String]()
    
//    // groups
//    private(set) var groups       = [[String:Any]]()
    
    //MARK: --- Methods ---
    init(_ userFirDoc: [String:Any]) {
        
        // uid
        if let uid = userFirDoc["uid"] as? String {
            self.uid = uid
        }
        
        // name
        if let name = userFirDoc["name"] as? String {
            self.name = name
        }
        
        // emailStr
        if let email = userFirDoc["email"] as? String {
            self.email = email
        }
        
        //usernameStr
        if let username = userFirDoc["username"] as? String {
            self.username = username
        }
        
        if let deviceToken = userFirDoc["deviceToken"] as? String {
            self.deviceToken = deviceToken
        }
        
        if let referralCode = userFirDoc["referralCode"] as? String {
            self.referralCode = referralCode
        }
        
        if let points = userFirDoc["points"] as? Int {
            self.points = points
        }
        
        if let amountEarned = userFirDoc["amountEarned"] as? Double {
            self.amountEarned = amountEarned
        }
        
        if let numSessions = userFirDoc["numSessions"] as? Int {
            self.numSessions = numSessions
        }
        
        if let uploadedContentCount = userFirDoc["uploadedContentCount"] as? Int {
            self.uploadedContentCount = uploadedContentCount
        }
        
        if let collectedContentCount = userFirDoc["collectedContentCount"] as? Int {
            self.collectedContentCount = collectedContentCount
        }
        
        if let collectedContentIDs = userFirDoc["collectedContentIDs"] as? [String] {
            self.collectedContentIDs = collectedContentIDs
        }
        
        if let createdContentIDs = userFirDoc["createdContentIDs"] as? [String] {
            self.createdContentIDs = createdContentIDs
        }
        
        if let latitude = userFirDoc["latitude"] as? Double {
            self.latitude = latitude
        }
        
        if let longitude = userFirDoc["longitude"] as? Double {
            self.longitude = longitude
        }

//        // bioStr
//        if let bioStr = userFirDoc["bio"] as? String {
//            self.bioStr = bioStr
//        }
//
//        // locationStr
//        if let locationStr = userFirDoc["location"] as? String {
//            self.locationStr = locationStr
//        }
        
//        // urlStr
//        if let urlStr = userFirDoc["urlStr"] as? String {
//            self.urlStr = urlStr
//        }
        
        // --------------------------------------------------------
    
        // followers
        if let followers = userFirDoc["followers"] as? [String] {
            self.followers = followers
        }
        
        // following
        if let following = userFirDoc["following"] as? [String] {
            self.following = following
        }
        
        if let likedAnchorIDs = userFirDoc["likedAnchorIDs"] as? [String] {
            self.likedAnchorIDs = likedAnchorIDs
        }
        
        if let historyNetworkIDs = userFirDoc["historyNetworkIDs"] as? [String] {
            self.historyNetworkIDs = historyNetworkIDs
        }
        
        if let currentConnectedNetworkID = userFirDoc["currentConnectedNetworkID"] as? String {
            self.currentConnectedNetworkID = currentConnectedNetworkID
        }
        
        // following
        if let createdNetworkIDs = userFirDoc["createdNetworkIDs"] as? [String] {
            self.createdNetworkIDs = createdNetworkIDs
        }
        
        // ---------------------------------------------------------
 
        self.profileImageUrl = userFirDoc["profileImageUrl"] as? String
        
        // ---------------------------------------------------------
        
        // Assets
        if let assetUids = userFirDoc["assetUids"] as? [String] {
            self.assetUids = assetUids
        }
        
        if let ownedAssets = userFirDoc["ownedAssets"] as? [String] {
            self.ownedAssets = ownedAssets
        }
        
        
        // subscriptions
        if let subscriptions = userFirDoc["subscriptions"] as? [String] {
            self.subscriptions = subscriptions
        }
        
        if let subscribers = userFirDoc["subscribers"] as? [String] {
            self.subscribers = subscribers
        }
        
    }
    
//    static func transformUser(dict: [String: Any]) -> User? {
//        guard let email = dict["email"] as? String,
//            let username = dict["username"] as? String,
//            let bio = dict["bio"] as? String,
//            let name = dict["name"] as? String,
//            // let location = dict["location"] as? String,
//            //  let needs = dict["needs"] as? String,
//            //            let companySummary = dict["companySummary"] as? String,
//            //            let numberOfEmployees = dict["numberOfEmployees"] as? Double,
//            let uid = dict["uid"] as? String else {
//                return nil
//        }
//        let user = User(uid: uid, email: email, name: name, username: username, bio: bio)
//
//        if let locationImageUrl = dict["locationImageUrl"] as? String{
//            user.locationImageUrl = locationImageUrl
//        }
//
//        if let website = dict["website"] as? String{
//            user.website = website
//        }
//
//        if let revenueSplit = dict["revenue_Split"] as? Double{
//            user.revenueSplit = revenueSplit
//        }
//
//        if let companyType = dict["companyType"] as? String{
//            user.companyType = companyType
//        }
//
//        if let inviteCode = dict["inviteCode"] as? String{
//            user.inviteCode = inviteCode
//        }
//
////        if let address = dict["address"] as? String{
////            user.address = address
////        }
//        if let profileImageUrl = dict["profileImageUrl"] as? String{
//            user.profileImageUrl = profileImageUrl
//        }
//
//        if let isLoggedIn = dict["isLoggedIn"] as? Bool {
//            user.isLoggedIn = dict["isLoggedIn"] as? Bool
//        }
//        if let isAHost = dict["isAHost"] as? Bool {
//            user.isAHost = dict["isAHost"] as? Bool
//        }
//        if let hasViewedHostWalkthrough = dict["hasViewedHostWalkthrough"] as? Bool {
//            user.hasViewedHostWalkthrough = dict["hasViewedHostWalkthrough"] as? Bool
//        }
//        if let hasConfirmedDetails = dict["hasConfirmedDetails"] as? Bool {
//            user.hasConfirmedDetails = dict["hasConfirmedDetails"] as? Bool
//        }
//        if let isAnAdvertiser = dict["isAnAdvertiser"] as? Bool {
//            user.isAnAdvertiser = dict["isAnAdvertiser"] as? Bool
//        }
//        if let hasFinishedShippingProcess = dict["hasFinishedShippingProcess"] as? Bool {
//            user.hasFinishedShippingProcess = dict["hasFinishedShippingProcess"] as? Bool
//        }
//
////        if let phoneNumber = dict["phoneNumber"] as? String{
////            user.phoneNumber = phoneNumber
////        }
//
//        if let latitude = dict["current_latitude"] as? String {
//            user.latitude = latitude
//        }
//        if let longitude = dict["current_longitude"] as? String {
//            user.longitude = longitude
//        }
//        return user
//    }
    
    func toString() -> String {
        var ret: String = ""
        
        ret = ret + "uid: " + uid
        ret = ret + "\nemailStr: " + email
        ret = ret + "\nusernameStr: " + username
//        ret = ret + "\nbioStr: " + bio
//        ret = ret + "\nlocationStr: " + location
      //  ret = ret + "\nurlStr: " + urlStr
        
        ret = ret + "\nfollowers: " + following.debugDescription
        ret = ret + "\nfollowing: " + following.debugDescription
        ret = ret + "\nproPicRef: " + profileImageUrl.debugDescription
        
        ret = ret + "\nsubscriptions: " + subscriptions.debugDescription
        ret = ret + "\nsubscribers: " + subscribers.debugDescription
        
        // assets
        ret = ret + "\nassetUids: " + assetUids.joined(separator: ",")
        ret = ret + "\nownedAssets: " + ownedAssets.joined(separator: ",")
        
        return ret
    }
}
