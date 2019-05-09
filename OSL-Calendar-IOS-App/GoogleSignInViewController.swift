//
//  GoogleSignIn.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/27/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//
//  The Google sign in page for the application

import Foundation
import UIKit
import GoogleSignIn
import Toast_Swift
import SpriteKit

class GoogleSignInViewController: UIViewController, GIDSignInUIDelegate {
    
    // Image view of sign in page
    private let icon : UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "augieIcon"))
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    // Title of sign in page
    let titleLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.boldSystemFont(ofSize: 48)
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        lbl.text = "Augie Events"
        return lbl
    }()
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 32/255, green: 85/255, blue: 138/255, alpha: 1)
        GIDSignIn.sharedInstance().uiDelegate = self
        addTitle()
        addIcon()
        addGoogleBtn()
    }
    
    // Anchor and add the title to the sign in page
    func addTitle() {
        self.view.addSubview(titleLabel)
        let margins = self.view.safeAreaLayoutGuide
        titleLabel.anchor(top: margins.topAnchor, left: margins.leftAnchor, bottom: nil, right: margins.rightAnchor, paddingTop: 20, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0, enableInsets: false)
        titleLabel.center.x = view.center.x
        guard let customFont = UIFont(name: "Animo-Light", size: 100) else {
            fatalError("Failed to load the custom font.")
        }
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = customFont
        titleLabel.textColor = UIColor.init(red: 255/255, green: 221/255, blue: 0/255, alpha: 1)
    }
    
    // Anchor and add the icon to the sign in page
    func addIcon() {
        self.view.addSubview(icon)
        if let cgImage = icon.image?.cgImage {
            let margins = self.view.safeAreaLayoutGuide
            let ratio = CGFloat(cgImage.width) / UIScreen.main.bounds.width
            icon.anchor(top: titleLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width - 50, height: CGFloat(cgImage.height) / ratio - 50, enableInsets: false)
            icon.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
            icon.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        }
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
        self.view.makeToastActivity(.center)
        self.view.isUserInteractionEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
