//
//  TermsAndConditionsViewController.swift
//  DecorateYourRoom
//
//  Created by Nijel Hunt on 8/14/22.
//  Copyright © 2022 Placenote. All rights reserved.
//

import UIKit
import WebKit

class TermsAndConditionsViewController: UIViewController {

    @IBOutlet weak var termsWebView: WKWebView!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // let url = URL(string: "https://termsfeed.com/terms-conditions/faf23cd7494e7eccca3c27770ee492c3")
        //termsWebView.loadRequest(URLRequest(url:url!))
        //        let path = Bundle.main.path(forResource: "Knocknock Terms and Conditions", ofType: "pdf")
        //        let url = URL(fileURLWithPath: path!)
        //        let request = URLRequest(url: url)
        //        termsWebView.loadRequest(request)
        if let pdf = Bundle.main.url(forResource: "Knocknock Terms and Conditions New1", withExtension: "pdf", subdirectory: nil, localization: nil)  {
            print("hit terms")
            let req = NSURLRequest(url: pdf)
//            termsWebView.loadRequest(req as URLRequest)
            termsWebView.load(req as URLRequest)

            print("should show terms")
        } else{
            print("didnt get to terms")
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    
}
