//
//  FirebaseStorageHelper.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 10/13/21.
//  Copyright © 2021 Placenote. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

class FirebaseStorageHelper {
    
    static private let cloudStorage = Storage.storage()
    
    private static let db = Firestore.firestore()
    
    class func asyncDownloadToFilesystem(relativePath: String, handler: @escaping (_ fileUrl: URL) -> Void) {
        //create local filesystem url
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = docsUrl.appendingPathComponent(relativePath)
        
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            handler(fileUrl)
            return
        }
        
        let storageRef = cloudStorage.reference(withPath: relativePath)
        print("\(storageRef) is storage ref")
        storageRef.write(toFile: fileUrl) { url, error in
            guard let localUrl = url else {
                print("Firebase storage: Error downloading file with relativePath: \(relativePath)")
                return
            }
            
            handler(localUrl)
            
        }.resume()
        
    }
    
//    public static func getAllModels(completion: @escaping([Model]) -> Void) {
//        
//        var ret = [Model]()
//        db.collection("models").getDocuments() { querySnapshot, err in
//            guard let querySnapshot = querySnapshot, err == nil else {
//                print("ERROR - getAllModels: \(err!.localizedDescription)")
//                return completion(ret)
//            }
//            
//            for docSnapshot in querySnapshot.documents {
//                ret.append(Model(docSnapshot.data()))
//            }
//            
//            completion(ret)
//        }
//    }
}
