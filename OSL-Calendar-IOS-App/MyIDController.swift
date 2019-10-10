//
//  MyIDController.swift
//  OSL-Calendar-IOS-App
//
//  Created by checkout on 9/11/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import Firebase

class MyIDController: UIViewController {
    var containerView = UIView()
    var scrollView = UIScrollView()
    
    // View will appear - set theme, check if in calendar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpScrollView()
        
    }
    
    func setUpScrollView() {
        let margins = self.view.safeAreaLayoutGuide
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: containerView.bounds.height)
        containerView.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        scrollView.addSubview(idImage)
        idImage.anchor(top: scrollView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 75, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width, enableInsets: false)
        idImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    }
    
    private let idImage : UIImageView = {
        let defaultImage = UIImage(named: "my_id")
        let imgView = UIImageView(image: defaultImage)
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        let currentAccount = Auth.auth().currentUser
        let userEmail = currentAccount?.email
        let userIndex = userEmail!.index(of: "@")!
        let user = String((userEmail?.prefix(upTo: userIndex))!)
        let data = user.data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return imgView }
        qrFilter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else { return imgView  }
        let transform = CGAffineTransform(scaleX: 50, y: 50)
        let scaledQrImage = qrImage.transformed(by: transform)
        imgView.image = UIImage(ciImage: scaledQrImage)
        
        return imgView
    }()
    
}
