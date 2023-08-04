//
//  FirestoreManager.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 1/10/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
//import GeoFire
import FirebaseStorage

public class FirestoreManager {
    
    private static let db = Firestore.firestore()
    static private let auth = Auth.auth()
    
    var model: Model!
    
    //MARK: ------------------------ USER ------------------------
    
    // Create a cache for the users
    private static var userCache = NSCache<NSString, User>()

    public static func getUser(_ userUid: String, completion: @escaping (User?) -> Void ) {
        userCache.countLimit = 50
        userCache.evictsObjectsWithDiscardedContent = true
        
        // Check if the user is in the cache
        if let cachedUser = userCache.object(forKey: userUid as NSString) {
            // Return the cached user
            return completion(cachedUser)
        }

        // User is not in cache, fetch it from the database
        let docRef = db.collection("users").document(userUid)
        docRef.getDocument { docSnapshot, err in
            if let err = err {
                print("ERROR - getUser: \(err)")
            }

            guard let docSnapshot = docSnapshot, let userFirDoc = docSnapshot.data() else {
                print("ERROR - getUser: Could not get user \(userUid)")
                return completion(nil)
            }

            // Create a new user object from the retrieved data
            let user = User(userFirDoc)

            // Add the user to the cache
            userCache.setObject(user, forKey: userUid as NSString)

            completion(user)
        }
    }
    
    private static var modelCache = NSCache<NSString, Model>()
    
    public static func getModel(_ id: String, completion: @escaping (Model?) -> Void ) {
        modelCache.countLimit = 35
        modelCache.evictsObjectsWithDiscardedContent = true
        
        // Check if the model is in the cache
            if let cachedModel = modelCache.object(forKey: id as NSString) {
                // Return the cached model
                return completion(cachedModel)
            }

            let docRef = db.collection("models").document(id)

            docRef.getDocument { docSnapshot, err in
                if let err = err {
                    print("ERROR - getModel: \(err)")
                }

                guard let docSnapshot = docSnapshot, let userFirDoc = docSnapshot.data() else {
                    print("ERROR - getModel: Could not get model \(id)")
                    return completion(nil)
                }

                let model = Model(userFirDoc)
                // Add the model to the cache
                modelCache.setObject(model, forKey: id as NSString)
                completion(model)
            }
    }
    
    /// Async returns an array of `User`s objects from "users" collection
    public static func getUsers(_ userUids: [String], completion: @escaping ([User]) -> Void ) {
        
        var counter = 0
        var users = [User]()
        
        for userUid in userUids {
            getUser(userUid) { (user) in
                counter += 1
                
                if let user = user {
                    users.append(user)
                } else {
                    print("ERROR - getUsers: Could not get user \(userUid)")
                }
                
                if counter == userUids.count {
                    completion(users)
                }
            }
        }
    }
    
    /// Async returns an array of `User`s of the entire "users" collection
    public static func getAllUsers(completion: @escaping([User]) -> Void) {
        
        var ret = [User]()
        db.collection("users").getDocuments() { querySnapshot, err in
            guard let querySnapshot = querySnapshot, err == nil else {
                print("ERROR - getAllUsers: \(err!.localizedDescription)")
                return completion(ret)
            }
            
            for docSnapshot in querySnapshot.documents {
                ret.append(User(docSnapshot.data()))
            }
            
            completion(ret)
        }
    }
    
    /// Async returns an array of `Model`s of the entire "users" collection
    public static func getAllModels(completion: @escaping([Model]) -> Void) {
        
        var ret = [Model]()
        db.collection("models").getDocuments() { querySnapshot, err in
            guard let querySnapshot = querySnapshot, err == nil else {
                print("ERROR - getAllModels: \(err!.localizedDescription)")
                return completion(ret)
            }
            
            for docSnapshot in querySnapshot.documents {
               // ret.append(Model(docSnapshot.data()))
            }
            
            completion(ret)
        }
    }
    
    //CACHE TO IMPROVE
 
    //  static var collectedModelscache = [String: [Model]]()
    
    static func getCollectedModels(_ userUid: String, completion: @escaping ([Model]) -> Void) {
        var ret = [Model]()
        
        db.collection("users").document(userUid).getDocument { (document, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            if let doc = document {
                var items = doc.get("collectedContentIDs") as! [String]
                            // remove any item with a value of ""
                items = items.filter { $0 != "" }
                let group = DispatchGroup()
                for item in items {
                    // Enter the dispatch group before starting async work
                    group.enter()
                    // Get the model document for each model ID
                    db.collection("models").document(item).getDocument { (modelDocument, error) in
                        if let err = error {
                            print(err.localizedDescription)
                            return
                        }
                        
                        if let modelDoc = modelDocument {
                            // Create a Model object from the model document data
                            if let model = try? Model(modelDoc.data()!) {
                                ret.append(model)
                            } else {
                                print("ERROR - getCollectedModels: malformed event \(modelDocument?.documentID)")
                            }
                        }
                        // Leave the dispatch group after finishing async work
                        group.leave()
                    }
                
            }
                // Wait for all async work to finish and call the completion closure
                group.notify(queue: .main) {
                    return completion(ret)
                }
            }
        }
    }
    
    //CACHE TO IMPROVE
    
    static func getCreatedModels(_ userUid: String, completion: @escaping ([Model]) -> Void) {
        
        var ret = [Model]()
            
        db.collection("models").whereField(Model.CREATOR, isEqualTo: userUid).getDocuments() { querySnapshot, err in
                    
            if let err = err {
                print("ERROR - getCreatedModels: \(err.localizedDescription)")
                return completion(ret)
            }

            guard let querySnapshot = querySnapshot else {
                print ("ERROR - getCreatedModels: querySnapshot is nil")
                return completion(ret)
            }
                
            for docSnapshot in querySnapshot.documents {
                
                if let model = try? Model(docSnapshot.data()) {
                    ret.append(model)
                } else {
                    print("ERROR - getCreatedModels: malformed event \(docSnapshot.documentID)")
                }
            }
                
            return completion(ret)
        }
    }
    
    static func getProfileCreatedModels(_ userUid: String, completion: @escaping ([Model]) -> Void) {
            
            let currentUserUid = FirestoreManager.getCurrentUserUid2()
                
            guard currentUserUid != userUid else {
                return getCreatedModels(userUid) { events in
                    return completion(events)
                }
            }
            
                    
            self.getCreatedModels(userUid) { createdModels in
                
                var filtered = [Model]()
                for model in createdModels {
                        filtered.append(model)
                        
                }
                
                completion(filtered)
            }
        }
          
    static func getProfileCollectedModels(_ userUid: String, completion: @escaping ([Model]) -> Void) {
            
            let currentUserUid = FirestoreManager.getCurrentUserUid2()
                
            guard currentUserUid != userUid else {
                return getCollectedModels(userUid) { models in
                    return completion(models)
                }
            }
            
        
                    self.getCollectedModels(userUid) { collectedModels in
                        
                        var filtered = [Model]()
                        for model in collectedModels {
                            
                                filtered.append(model)
                        }
                        
                        completion(filtered)
                    }
                }
    
    static func getProfileLibrary(_ userUid: String, completion: @escaping ([Model]) -> Void) {
        var allModels = [Model]()

        getCollectedModels(userUid) { collectedModels in
            getCreatedModels(userUid) { createdModels in
                allModels = collectedModels + createdModels
                return completion(allModels)
            }
        }
    }
    
   // var network: Network!
    
//    static func getNetworksInRange(centerCoord: CLLocationCoordinate2D, withRadius radiusInM: Double, completion: @escaping ([Network]) -> Void) {
//
//
//        // ----------------------- location filter ---------------------
//
//        let queryBounds = GFUtils.queryBounds(forLocation: centerCoord,
//                                              withRadius: radiusInM)
//
//        let queries = queryBounds.map { bound -> Query in
//            return self.db.collection("networks")
//                .order(by: Network.GEOHASH)
//                .start(at: [bound.startValue])
//                .end(at: [bound.endValue])
//        }
//
//        // --------------------------------------------
//
//
//        var ret = [Network]()
//        var count = 0
//
//        for query in queries {
//
//            // ----------------------- execute ----------------------
//            query.getDocuments { querySnapshot, err in
//                count += 1
//
//                if let documents = querySnapshot?.documents {
//
//                    for document in documents {
//
//                        if let network = try? Network(document.data()) {
//
//                            let center = CLLocation(latitude: centerCoord.latitude, longitude: centerCoord.longitude)
//                            let location = CLLocation(latitude: network.latitude ?? 0, longitude: network.longitude ?? 0)
//
//                            if GFUtils.distance(from: center, to: location) <= radiusInM {
//                                ret.append(network)
//                            }
//
//                        }
//                    }
//
//                    if (count == queries.count) {
//                        return completion(ret)
//                    }
//
//                } else {
//                    print("ERROR - getNetworksInRange \(String(describing: err))")
//                }
//            }
//        }
//    }
    
    /// Async returns if the "users" colleciton contains a document with "usernameStr": -username
    public static func usernameUnique(_ username: String, completion: @escaping (Bool) -> Void) {
        
        return completion(true)
        
        db.collection("users").getDocuments() { querySnapshot, err in
            guard let querySnapshot = querySnapshot, err == nil else {
                print("ERROR - uernameUnique: \(err!.localizedDescription)")
                return completion(false)
            }
            
            for docSnapshot in querySnapshot.documents {
                if let docUsername = docSnapshot.get("usernameStr") as? String {
                    if username == docUsername {
                        return completion(false)
                    }
                }
            }
            
            completion(true)
        }
    }
    
    //ADD PAGINATION AND CACHE
    
//    static func searchModels(queryStr: String, lastDocument: DocumentSnapshot?, completion: @escaping ([Model], DocumentSnapshot?) -> Void) {
//        var ret = [Model]()
//
//        var query = db.collection("models")
//            .whereField("name", isGreaterThanOrEqualTo: queryStr)
//            .whereField("name", isLessThanOrEqualTo: queryStr + "\u{f8ff}")
//
//        if let lastDocument = lastDocument {
//            query = query.start(afterDocument: lastDocument)
//        }
//
//        query.getDocuments { querySnapshot, err in
//            guard let querySnapshot = querySnapshot, err == nil else {
//                print("ERROR - searchModels (NAME): \(err!.localizedDescription)")
//                return completion(ret, lastDocument)
//            }
//            
//            for docSnapshot in querySnapshot.documents {
//                if let model = try? Model(docSnapshot.data()) {
//                    ret.append(model)
//                } else {
//                    print("ERROR - searchModels (NAME) \(docSnapshot.documentID): malformed")
//                }
//            }
//            
//            var query = db.collection("models")
//                .whereField("modelName", isGreaterThanOrEqualTo: queryStr)
//                .whereField("modelName", isLessThanOrEqualTo: queryStr + "\u{f8ff}")
//            
//            if let lastDocument = lastDocument {
//                query = query.start(afterDocument: lastDocument)
//            }
//            
//            query.getDocuments { querySnapshot, err in
//                guard let querySnapshot = querySnapshot, err == nil else {
//                    print("ERROR - searchModels (MODELNAME): \(err!.localizedDescription)")
//                    return completion(ret, lastDocument)
//                }
//                
//                for docSnapshot in querySnapshot.documents {
//                    if !ret.contains(where: { $0.id == docSnapshot.documentID}) {
//                        if let model = try? Model(docSnapshot.data()) {
//                            ret.append(model)
//                        }
//                    }
//                }
//                
//                return completion(ret)
//            }}
    
    static func searchProfileLibrary(allModels: [Model], queryStr: String, completion: @escaping ([Model]) -> Void) {
        let filteredModels = allModels.filter { model -> Bool in
            model.name.contains(queryStr) || model.modelName.contains(queryStr)
        }
        return completion(filteredModels)
    }
    
    static func searchModels(queryStr: String, completion: @escaping ([Model]) -> Void) {
        
        var ret = [Model]()
        
        //Using Index
        db.collection("models")
                .whereField("name", isGreaterThanOrEqualTo: queryStr)
                .whereField("name", isLessThanOrEqualTo: queryStr + "\u{f8ff}").getDocuments { querySnapshot, err in
                
                guard let querySnapshot = querySnapshot, err == nil else {
                    print("ERROR - searchUsers: \(err!.localizedDescription)")
                    return completion(ret)
                }
                
                
                for docSnapshot in querySnapshot.documents {
                    if let model = try? Model(docSnapshot.data()) {
                        ret.append(model)
                    } else {
                        print("ERROR - searchUsers \(docSnapshot.documentID): malformed")
                    }
                }
                    //Using Index
                db.collection("models").whereField("modelName", isGreaterThanOrEqualTo: queryStr).whereField("modelName", isLessThanOrEqualTo: queryStr + "\u{f8ff}").getDocuments { querySnapshot, err in
                                        
                        guard let querySnapshot = querySnapshot, err == nil else {
                            print("ERROR - searchUsers: \(err!.localizedDescription)")
                            return completion(ret)
                        }
                        
                        // add if not already added
                        for docSnapshot in querySnapshot.documents {
                            
                            if !ret.contains(where: { $0.id == docSnapshot.documentID}) {
                                if let model = try? Model(docSnapshot.data()) {
                                    ret.append(model)
                                }
                            }
                        }
                        
                        return completion(ret.filter({ $0.id != "s8i5XBgPuUgGPOX1NY48tAWOfsl1"}))
                    }
            }
    }
    
    static func getBrowseModels(models: [Model], completion: @escaping ([Model]) -> Void) {
                
        var ret = [Model]()
        
        let query = db.collection("models")
            .limit(to: 4)
            .order(by: Model.DATE, descending: true)
        
        // first query
        if models.count == 0 {
            
            query.getDocuments() { querySnapshot, err in
                            
                guard let querySnapshot = querySnapshot, err == nil else {
                    print("ERROR - getDiscoverUsers: \(err!.localizedDescription)")
                    return completion(ret)
                }
                
                for docSnapshot in querySnapshot.documents {
                    
                    if let model = try? Model(docSnapshot.data()){
                        
                        if (model.id != "s8i5XBgPuUgGPOX1NY48tAWOfsl1") {
                            ret.append(model)
                        }
                        
                    } else {
                        print("ERROR - getDiscoverUsers \(docSnapshot.documentID): malformed user")
                    }
                }
                
                completion(ret)
            }
            
        // get more users
        } else {
            
            let lastModel = models.last!
            db.document("models/\(lastModel.id)").getDocument() { docSnapshot, err in
                
                if let err = err {
                    print("ERROR - getDiscoverUsers: \(err)")
                }
                
                guard let docSnapshot = docSnapshot else {
                    print("ERROR - getDiscoverUsers: Could not get user \(lastModel.id)")
                    return completion(ret)
                }
                
                query.start(afterDocument: docSnapshot)
                    .getDocuments() { querySnapshot, err in
                                
                    guard let querySnapshot = querySnapshot, err == nil else {
                        print("ERROR - getDiscoverUsers: \(err!.localizedDescription)")
                        return completion(ret)
                    }
                    
                    for docSnapshot in querySnapshot.documents {
                        if let model = try? Model(docSnapshot.data()) {
                            ret.append(model)
                        } else {
                            print("ERROR - getDiscoverUsers \(docSnapshot.documentID): malformed user")
                        }
                    }
                    
                    completion(ret)
                }
            }
        }
        
    }
    
    public static func saveUser(withID uid: String, withData data: [String:Any], completion: @escaping (String?) -> Void ) {

        db.collection("users").document(uid).setData(data) { err in
            if err != nil {
                return completion(err!.localizedDescription)
            }
            completion(nil)
        }
    }
    
    static func getCurrentUserUid() -> String? {
        return auth.currentUser?.uid
    }
    
    static func getCurrentUserUid2() -> String {
        
        if let uid = auth.currentUser?.uid {
            return uid
        } else {
            //fatalError("Could not get uid of current User")
            print("not a user")
            return ""
        }
    }
    
    public static func loginUser(email: String?, password: String?, completion: @escaping (Error?) -> Void ) {
            guard let email = email, !email.isEmpty, let password = password, !password.isEmpty else {
                completion(NSError(domain: "Auth Error", code: 400, userInfo: [NSLocalizedDescriptionKey: "Fields cannot be empty"]))
                return
            }
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let error = error {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }

    
//    public static func loginUser(email: String?, password: String?, completion: @escaping (String?) -> Void ) {
//
//        // Validate email / pwd
//        guard let email = email, let password = password else {
//            return completion("Fields cannot be empty")
//        }
//
//        // sign in user via firebase auth
//        auth.signIn(withEmail: email, password: password) { (authResult, err) in
//
//            guard let authResult = authResult, err == nil else {
//                return completion(err!.localizedDescription)
//            }
//
////            let mainTabBarController = TabBarViewController2()
////            mainTabBarController.modalPresentationStyle = .fullScreen
////            self.present(mainTabBarController, animated: false, completion: nil)
//            completion(nil)
//        }
//    }
    
    public static func updateUser(_ updateDoc: [String:Any], completion: @escaping (Bool) -> Void ) {
        
        let currentUserUid = FirestoreManager.getCurrentUserUid2()
        
        db.document("users/\(currentUserUid)").updateData(updateDoc) { err in
            
            if let err = err {
                print("ERROR - updateUser: \(err.localizedDescription)")
                return completion(false)
            }
            
            return completion(true)
            
        }
    }
    
    public static func updateNetwork(_ updateDoc: [String:Any], completion: @escaping (Bool) -> Void ) {
        
        let currentUserUid = FirestoreManager.getCurrentUserUid2()
        
        db.document("networks/\(currentUserUid)").updateData(updateDoc) { err in
            
            if let err = err {
                print("ERROR - updateUser: \(err.localizedDescription)")
                return completion(false)
            }
            
            return completion(true)
            
        }
    }
//
//    public static func updateUser(withFirDoc firDoc: [String:Any], completion: @escaping (Bool) -> Void ) {
//        guard let currentUserUid = AuthManager.getCurrentUserUid() else { completion(false); return }
//        let currentUserDoc = db.collection("users").document(currentUserUid)
//
//        if let name = firDoc["name"] {
//            currentUserDoc.updateData(["name": name]) { err in
//                if let err = err {
//                    print ("ERROR - udpateUser: \(err.localizedDescription)")
//                    completion(false)
//                }
//            }
//        }
//
//        if let username = firDoc["username"] {
//            currentUserDoc.updateData(["username": username]) { err in
//                if let err = err {
//                    print ("ERROR - udpateUser: \(err.localizedDescription)")
//                    completion(false)
//                }
//            }
//        }
////        if let bioStr = firDoc["bioStr"] {
////            currentUserDoc.updateData(["bioStr": bioStr]) { err in
////                if let err = err {
////                    print ("ERROR - udpateUser: \(err.localizedDescription)")
////                    completion(false)
////                }
////            }
////        }
////        if let locationStr = firDoc["locationStr"] {
////            currentUserDoc.updateData(["locationStr": locationStr]) { err in
////                if let err = err {
////                    print ("ERROR - udpateUser: \(err.localizedDescription)")
////                    completion(false)
////                }
////            }
////        }
////        if let urlStr = firDoc["urlStr"] {
////            currentUserDoc.updateData(["urlStr": urlStr]) { err in
////                if let err = err {
////                    print("ERROR - udpateUser: \(err.localizedDescription)")
////                    completion(false)
////                }
////            }
////        }
//
//        if let imageData = firDoc["imageData"] as? Data {
//            StorageManager.updateProfilePicture(withData: imageData) { (refUid) in
//                if let refUid = refUid {
//                    currentUserDoc.updateData(["proPicRef": refUid])
//                    return completion(true)
//                }
//                return completion(false)
//            }
//        } else {
//            completion(true)
//        }
//    }
//
    public static func updateFCMToken(userUid: String, fcmToken: String, completion: @escaping (Bool) -> Void) {
        let userDoc = db.collection("users").document(userUid)
        userDoc.updateData(["fcmToken" : fcmToken]) { err in
            if err != nil {
                print("ERROR - updateFCMToken: \(err!.localizedDescription)")
                return completion(false)
            }
            completion(true)
        }
    }
//
    public static func updateProPic(withProPicRef proPicRef: String, completion: @escaping (Bool) -> Void ) {
        guard let currentUserUid = FirebaseAuthHelper.getCurrentUserUid() else {
            return completion(false)
        }
        let currentUserDoc = db.collection("users").document(currentUserUid)

        currentUserDoc.updateData(["proPicRef": proPicRef]) { err in
            if let err = err {
                print("Error - updateProPic", err.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }

        }
    }
//
//    public static func followUser(_ userUid: String, completion: @escaping (Bool) -> Void ) {
//        guard let currentUserUid = AuthManager.getCurrentUserUid() else { return }
//
//        // Add userUid to currentUserUid "following" array
//        let currentUserDoc = db.collection("users").document(currentUserUid)
//
//        currentUserDoc.updateData(["following": FieldValue.arrayUnion([userUid])]) { error in
//            if error != nil {
//                print("Error - add follower")
//                completion(false)
//                return
//            }
//        }
//
//        // Add currentUserUid to userUid "followers" array
//        let userDoc = db.collection("users").document(userUid)
//        userDoc.updateData(["followers": FieldValue.arrayUnion([currentUserUid])]) { error in
//            if error != nil {
//                print("Error - add follower")
//                completion(false)
//                return
//            }
//            completion(true)
//        }
//    }
//
//    public static func unfollowUser(_ userUid: String, completion: @escaping (Bool) -> Void ) {
//        guard let currentUserUid = AuthManager.getCurrentUserUid() else { return }
//
//        // remove user from self."following"
//        let currentUserDoc = db.collection("users").document(currentUserUid)
//        currentUserDoc.updateData(["following": FieldValue.arrayRemove([userUid])]) { err in
//            if let err = err {
//                print("ERROR - unfollowUser: \(err)")
//                return completion(false)
//            }
//        }
//
//        // remove self from user."followers" array
//        removeSelfFrom_UserFollowers(userUid) { success in
//            if (!success) { print("ERROR - unfollowUser") }
//            return completion(success)
//        }
//    }
//
//    public static func createGroup(group: Group, completion: @escaping (Bool) -> Void ) {
//        guard let currentUserUid = AuthManager.getCurrentUserUid() else { return }
//
//        // add imageRef to storage
//        StorageManager.updateGroupImage(group: group) { (success) in
//            if !success {
//                print("Error: createGroup")
//                completion(false)
//            } else {
//                // add group to userDoc
//                let userDoc = self.db.collection("users").document(currentUserUid)
//                userDoc.updateData(["groups": FieldValue.arrayUnion([group.toDict()])]) { err in
//                    if err != nil { print("Error: createGroup"); completion(false); return }
//                    completion(true)
//                }
//            }
//        }
//    }
//
    public static func deleteAccount(completion: @escaping (Bool) -> Void) {
        
        let currentUserUid = FirebaseAuthHelper.getCurrentUserUid2()
                        
        db.collection("users").document(Auth.auth().currentUser!.uid).delete { err in
                        
            if let err = err {
                print("ERROR - deleteAccount \(currentUserUid): \(err.localizedDescription)")
                return completion(false)
            }
                    
            
            // ------------------
            FirebaseAuthHelper.deleteUser { success in
                return completion(success)
            }
        }
    }
//
//    //MARK: ------------------------ EVENT ------------------------
//
//    public static func createEvent(_ event: Event, completion: @escaping (Bool) -> Void ) {
//
//        // Take different actinos based on privacy level of created event
//        var collection = "events"
//        if (event.privacy == .Public) {
//            collection = "public_events"
//        }
//
//        /// create eventDoc
//        db.document("\(collection)/\(event.uid)").setData(event.toFirDoc()) { err in
//
//            if err != nil {
//                print("ERROR - createEvent: \(err!.localizedDescription)")
//                return completion(false)
//            }
//
//            /// hostUserDoc.eventUids
//            self.db.document("users/\(event.hostUid)").updateData(["eventUids": FieldValue.arrayUnion([event.uid])]) { err in
//
//                if let err = err {
//                    print("ERROR - createEvent: \(err.localizedDescription)")
//                    return completion(false)
//                }
//
//                self.add_eventUidToJoinedEvents(eventUid: event.uid, userUids: event.addedUsers) { success in
//                    return completion(success)
//                }
//
//            }
//        }
//    }
//
//    public static func updateEvent(event: Event, editEventData: EditEventData, completion: @escaping (Bool) -> Void) {
//
//        changeEventCollection(event: event, editEventData: editEventData) {
//
//            getEventRef(uid: event.uid) { docRef in
//                guard let docRef = docRef else {
//                    return completion(false)
//                }
//
//                // update eventdoc
//                docRef.updateData(editEventData.toFirDoc()) { err in
//
//                    if let err = err {
//                        print("ERROR - udpateEvent: \(err)")
//                        return completion(false)
//                    }
//
//                    // add eventUid to userdocs.joinedEvents
//                    self.add_remove_eventUid_JoinedEvents(event: event, _editEventData: editEventData) { success in
//                        print("Updated event \(event.uid):\n\t\(editEventData.toFirDoc())")
//                        return completion(success)
//                    }
//                }
//            }
//        }
//    }
//
    
    static let fs = Storage.storage()
    
//    public static func deleteModel(_ modelUid: String, completion: @escaping (Bool) -> Void ) {
//        // Create a batch write to delete the model document and update all the user documents that reference the model
//        let batch = db.batch()
//
//        // Delete the model document from Firestore
//        let modelRef = db.collection("models").document(modelUid)
//        batch.deleteDocument(modelRef)
//
//        // Get the thumbnail name for the model
//        getModel(modelUid) { (model) in
//            let thumbnailName = model?.thumbnail
//
//            // Delete the model thumbnail from Firebase Storage
//            let ref = fs.reference(forURL: "gs://blueprint-8c1ca.appspot.com").child("thumbnails").child(thumbnailName)
//            ref.delete { error in
//                if let error = error {
//                    return completion(error)
//                }
//
//                // Delete the reference to the model from the "collectedContentIDs" field of all users
//                let query = db.collection("users").order(by: "collectedContentIDs").start(at: [modelUid]).end(at: [modelUid])
//                query.getDocuments { snapshot, error in
//                    if let error = error {
//                        return completion(error)
//                    }
//
//                    snapshot?.forEach { document in
//                        var collectedContentIDs = document.get("collectedContentIDs") as? [String] ?? []
//                        collectedContentIDs.removeAll { $0 == modelUid }
//                        batch.updateData(["collectedContentIDs": collectedContentIDs], forDocument: document.reference)
//                    }
//                }
//            }
//        }
//
//        // Commit the batch write and execute all the delete and update operations together
//        batch.commit { error in
//            if let error = error {
//                return completion(error)
//            }
//            return completion(nil)
//        }
//    }

    
    public static func deleteModel(_ modelUid: String, completion: @escaping (Error?) -> Void ) {
            // Create a batch write to delete the model document and update all the user documents that reference the model
            let batch = db.batch()
            
//            // Delete the model document from Firestore
//            let modelRef = db.collection("models").document(modelUid)
//            batch.deleteDocument(modelRef)
            
            // Get the thumbnail name for the model
            getModel(modelUid) { model in
                let thumbnailName = model?.thumbnail
                
                // Delete the model thumbnail from Firebase Storage
                let ref = fs.reference(forURL: "gs://blueprint-8c1ca.appspot.com").child("thumbnails").child(thumbnailName ?? "")
                ref.delete { error in
                    if let error = error {
                        return completion(error)
                    }
                    
                    // Delete the reference to the model from the "collectedContentIDs" field of all users
                    let query = db.collection("users").whereField("collectedContentIDs", arrayContains: modelUid)
                    query.getDocuments { snapshot, error in
                        if let error = error {
                            return completion(error)
                        }
                        
                        // Create an array of update operations for each user document
                        if let snapshot = snapshot {
                            snapshot.documents.forEach { document in
                                batch.updateData(["collectedContentIDs": FieldValue.arrayRemove([modelUid])], forDocument: document.reference)
                            }
                        }
                        
                        // Delete the model document from Firestore
                        let modelRef = db.collection("models").document(modelUid)
                        batch.deleteDocument(modelRef)
                        
                        // Commit the batch write and execute all the delete and update operations together
                        batch.commit { error in
                            if let error = error {
                                return completion(error)
                            }
                            return completion(nil)
                        }
                    }
                }
                
            }
//
//            // Delete the model document from Firestore
//            let modelRef = db.collection("models").document(modelUid)
//            batch.deleteDocument(modelRef)
//
//            // Commit the batch write and execute all the delete and update operations together
//            batch.commit { error in
//                if let error = error {
//                    return completion(error)
//                }
//                return completion(nil)
//            }
        }



                    
                   


    
//    public static func deleteModel(_ model: Model, completion: @escaping (Bool) -> Void ) {
//
//        // Delete the model document from Firestore
//            db.collection("models").document(model.id).delete { error in
//                if let error = error {
//                    return completion(error)
//                }
//
//                let thumbnailname = model.thumbnail
//                let ref = fs.reference(forURL: "gs://blueprint-8c1ca.appspot.com").child("thumbnails").child(thumbnailName)
//
//                // Delete the model thumbnail from Firebase Storage
//                ref.delete { error in
//                    if let error = error {
//                        return completion(error)
//                    }
//                    return completion(nil)
//                }
//            }
//
//    }

  }
//
