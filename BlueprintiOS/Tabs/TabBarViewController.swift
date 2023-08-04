//
//  TabBarViewController.swift
//  BlueprintiOS
//
//  Created by Nijel A. Hunt on 8/4/23.
//

import UIKit
import SwiftUI
import FirebaseAuth

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
            super.viewDidLoad()

            // Create instances of the view controllers you want to display
       //     let searchViewController = SearchViewController()// UINavigationController(rootViewController:  SearchViewController())
        
        let searchViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController

        
        // Wrap InventoryListView in a NavigationView
               let inventoryListView = InventoryListView()
                let uploadViewController = UINavigationController(rootViewController: UIHostingController(rootView: inventoryListView))
        
            let userProfileOrCreateAccountViewController: UIViewController
            
            // Check if the user is signed in
            if Auth.auth().currentUser != nil {
                // User is signed in, show UserProfileViewController
                let user = Auth.auth().currentUser?.uid ?? ""
                let userProfileViewController = UserProfileViewController.instantiate(with: user) //(user:user)
                userProfileOrCreateAccountViewController = UINavigationController(rootViewController: userProfileViewController)
                userProfileOrCreateAccountViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "person"), selectedImage: UIImage(named: "person.fill"))

            } else {
                // User is not signed in, show CreateAccountViewController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "CreateAccountVC") as! CreateAccountViewController
                userProfileOrCreateAccountViewController = UINavigationController(rootViewController: vc)

                // Set the tab name and icon for CreateAccountViewController
                userProfileOrCreateAccountViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "person"), selectedImage: UIImage(named: "person.fill"))
            }
        
        // Set the tab name and icon for SearchViewController
                searchViewController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "magnifyingglass"), selectedImage: nil)

                // Set the tab name and icon for UploadViewController
                uploadViewController.tabBarItem = UITabBarItem(title: "Upload", image: UIImage(named: "plus"), selectedImage: nil)
        
       
            
            // Set the view controllers for the tab bar
            viewControllers = [uploadViewController, searchViewController, userProfileOrCreateAccountViewController]
        }
    

}
