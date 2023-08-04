//
//  FirebaseAuthHelper.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 1/10/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import Foundation
import Firebase

public class FirebaseAuthHelper {
    
    static private let auth = Auth.auth()
    
    //MARK: --- Get current auth user ---
    public static func getCurrentUserUid() -> String? {
        return auth.currentUser?.uid
    }
    public static func getCurrentUserUid2() -> String {
        
        if let uid = auth.currentUser?.uid {
            return uid
        } else {
//            fatalError("Could not get uid of current User")
            print("Could not get uid of current User - FATAL ERROR")
            return ""
           // return
        }
    }
    
    public static func getCurrentUser(completion: @escaping (User) -> Void) {
        
        let currentUser = getCurrentUserUid2()
        FirestoreManager.getUser(currentUser) { (user) in
            guard let user = user else {
                fatalError("Could not get current user")
            }
            completion(user)
        }
    }
    
    //MARK: --- Signup / Login ---
    public static func loginUser(email: String?, password: String?, completion: @escaping (String?) -> Void ) {
        
        // Validate email / pwd
        guard let email = email, let password = password else {
            return completion("Fields cannot be empty")
        }
        
        // sign in user via firebase auth
        auth.signIn(withEmail: email, password: password) { (authResult, err) in
            guard let authResult = authResult, err == nil else {
                return completion(err!.localizedDescription)
            }
            
            // upload fcm token
            let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
            FirestoreManager.updateFCMToken(userUid: authResult.user.uid, fcmToken: fcmToken) { success in
                if !success {
                    print("Could not update FCMToken")
                    completion("Please try again")
                } else {
                    completion(nil)
                }
            }
        }
    }
    public static func signOut(completion: @escaping () -> Void) {
//        FirestoreManager.updateFCMToken(userUid: getCurrentUserUid2(), fcmToken: "") { success in
//            if !success {
//                fatalError("Could not remove users FCM token")
//            }
            do {
                try auth.signOut()
                completion()
            } catch let signOutError {
                fatalError("Error signing out: \(signOutError.localizedDescription)")
            }
            
        //}
    }
    
    public static func sendPasswordReset(email: String, completion: @escaping (String?) -> Void ) {
        auth.sendPasswordReset(withEmail: email) { err in
            if let err = err {
                print("ERROR - resetPassword: \(err.localizedDescription)")
                return completion(err.localizedDescription)
            }
            
            return completion(nil)
        }
    }
    
    static func deleteUser(completion: @escaping (Bool) -> Void) {
        
        guard let firUser = auth.currentUser else {
            print("ERROR - deleteUser: No current user to delete")
            return completion(false)
        }
        
        firUser.delete() { err in
            
            if let err = err {
                print("ERROR - deleteUser: \(err.localizedDescription)")
                return completion(false)
            }
            
            completion(true)
        }
    }
    
    public static func registerAuthUser(email: String, password: String, completion: @escaping (String?) -> Void) { //
                
        auth.createUser(withEmail: email, password: password) { (authResult, err) in
            
            if err != nil {
                print("ERROR - registerAuthUser: \(err!.localizedDescription)")
                return completion(err!.localizedDescription)
            }
            
            completion(nil)
        }
    }
}
