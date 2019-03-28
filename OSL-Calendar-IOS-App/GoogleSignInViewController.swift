//
//  GoogleSignIn.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/27/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import Toast_Swift
import SpriteKit

class GoogleSignInViewController: UIViewController, GIDSignInUIDelegate {
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 32/255, green: 85/255, blue: 138/255, alpha: 1)
        GIDSignIn.sharedInstance().uiDelegate = self
        addGoogleBtn()
    }
    
    // Construct and add the Google sign in button to the view
    func addGoogleBtn() {
        let googleButton = GIDSignInButton()
        view.addSubview(googleButton)
        googleButton.translatesAutoresizingMaskIntoConstraints=false
        googleButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        googleButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        googleButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        googleButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        googleButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    // Handles the action for the loginBtn, shows activity spinner
    @objc func loginAction() {
//        ToastManager.shared.style.activityBackgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
//        ToastManager.shared.style.activityIndicatorColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        self.view.makeToastActivity(.center)
        self.view.isUserInteractionEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
