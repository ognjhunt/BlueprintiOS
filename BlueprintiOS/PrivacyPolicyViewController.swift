//
//  PrivacyPolicyViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 8/14/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var privacyWebView: WKWebView!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let url = URL(string: "https://privacypolicies.com/privacy/view/91355dcc8ea9a848914259215ca31aef")
        //privacyWebView.loadRequest(URLRequest(url:url!))
        //        let backItem = UIBarButtonItem()
        //        backItem.title = "Back"
        //        navigationItem.backBarButtonItem = backItem
        if let pdf = Bundle.main.url(forResource: "Knocknock Privacy Policy New1", withExtension: "pdf", subdirectory: nil, localization: nil)  {
            print("hit privacy")
            let req = NSURLRequest(url: pdf)
            //privacyWebView.loadRequest(req as URLRequest)
            privacyWebView.load(req as URLRequest)

            print("should show privacy")
        } else{
            print("didnt get to privacy")
        }
        
    }
    

    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    

}
