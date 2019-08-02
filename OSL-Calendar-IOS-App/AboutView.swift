//
//  AboutView.swift
//  OSL-Calendar-IOS-App
//
//  Created by checkout on 7/25/19.
//  Copyright © 2019 Michael Wardach. All rights reserved.
//

import Foundation
import UIKit

class AboutView: UIViewController, UITextViewDelegate {
    
    // Text View for displaying the About Page
    let textView: UITextView = {
        let view = UITextView()
        view.textColor = .black
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints=false
        return view
    }()
    
    // Button for returning to the Sign-in Page
    let backBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .gray
        btn.layer.borderColor = UIColor.darkGray.cgColor
        btn.setTitle("Return", for: UIControl.State.normal)
        btn.setTitleColor(.black, for: UIControl.State.normal)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 32/255, green: 85/255, blue: 138/255, alpha: 1)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        displayText()
        addSubviewAnchorTLRB(subView: textView, top: 10, left: 10, right: -10, btm: -50)
        addSubviewAnchorBLRH(subView: backBtn, btm: -10, left: 10, right: -10, height: 35)
    }
    
    // Construct the text for the About Page
    func displayText() {
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .link: NSURL(string: "mailto:\("osleventsapp@augustana.edu")")!,
            .foregroundColor: UIColor.blue
        ]
        let attributedString = NSMutableAttributedString(string: "OSL Events App\n\nPlease email any problems, bugs, or suggestions here! Thanks!\n\nPurpose:\nTo provide an easy way for students to view, track, and check into events they attend held by different student groups on campus.\n\nHours:\nAlways open\n\nPhone:\n309-794-2695\n\nDevs:\nKyle Workman, Jared Haeme, Brandon Thompson, Jack Cannell, Brent Pierce, Paige Oucheriah, Michael Wardach\n\n(Made by Augustana students for Augustana students!)\n\nAdvised by Dr. Stonedahl")
        attributedString.setAttributes(linkAttributes, range: NSMakeRange(64, 4))
        self.textView.delegate = self
        self.textView.attributedText = attributedString
        self.textView.isUserInteractionEnabled = true
        self.textView.isEditable = false
        self.textView.font = .systemFont(ofSize: 18)
    }
    
    // Add and anchor (to the top, left, right, bottom) a subview with the given constraints to the view
    func addSubviewAnchorTLRB(subView: UIView, top: CGFloat, left: CGFloat, right: CGFloat, btm: CGFloat) {
        view.addSubview(subView)
        subView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: top).isActive=true
        subView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive=true
        subView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive=true
        subView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: btm).isActive=true
    }
    
    // Add and anchor (to the bottom, left, right, height) a subview with the given constraints to the view
    func addSubviewAnchorBLRH(subView: UIView, btm: CGFloat, left: CGFloat, right: CGFloat, height: CGFloat) {
        view.addSubview(subView)
        subView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: btm).isActive=true
        subView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive=true
        subView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive=true
        subView.heightAnchor.constraint(equalToConstant: height).isActive=true
    }
    
    // Ensures the About Page starts at the top
    override func viewDidLayoutSubviews() {
        self.textView.setContentOffset(.zero, animated: false)
    }
    
    // Handles the action for the backBtn, returns to Login Page
    @objc func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
