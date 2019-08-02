//
//  SettingsViewController.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/26/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//
//  The view for the settings tab in the application

import Foundation
import UIKit
import SimpleCheckbox
import GoogleSignIn
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    let themeManager = ThemeManager()
    var scrollView: UIScrollView = UIScrollView()
    var containerView: UIView = UIView()
    var fixedHeightOfLabel: CGFloat = 45
    var index: Double = 0.3
    var labels: [UILabel] = []
    var options: [Checkbox] = []
    var signOutButton: UIButton = UIButton()
    var aboutButton : UIButton = UIButton()
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        //setUpThemeOptions()
        addAboutButton()
        addSignOutButton()
        //setTheme()
    }
    
    // View will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View Will Appear: Settings")
    }
    
    // Sets up the scroll view for the settings page
    func setUpScrollView() {
        let margins = self.view.safeAreaLayoutGuide
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1800)
        containerView.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }
    
    // Creates the radio buttons for the different theme options
    func setUpThemeOptions() {
        makeLabel(text: "Theme", left: 20)
        makeRadioOption(optionText: "Augie", left: 40)
        makeRadioOption(optionText: "White", left: 40)
        makeRadioOption(optionText: "Dark", left: 40)
        makeRadioOption(optionText: "Sea Blue", left: 40)
        makeRadioOption(optionText: "Twighlight Purple", left: 40)
    }
    
    // Creates the sign out button
    func addSignOutButton() {
        signOutButton = UIButton()
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(.black, for: .normal)
        signOutButton.backgroundColor = UIColor.init(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        signOutButton.translatesAutoresizingMaskIntoConstraints=false
        scrollView.addSubview(signOutButton)
        signOutButton.topAnchor.constraint(equalTo: aboutButton.bottomAnchor, constant: 10).isActive = true
        signOutButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        signOutButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        signOutButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10).isActive = true
        signOutButton.heightAnchor.constraint(equalToConstant: fixedHeightOfLabel).isActive = true
        signOutButton.addTarget(self, action: #selector(signOutAction(_:)), for: .touchUpInside)
    }
    
    func addAboutButton() {
        aboutButton = UIButton()
        aboutButton.setTitle("About", for: .normal)
        aboutButton.setTitleColor(.black, for: .normal)
        aboutButton.backgroundColor = UIColor.init(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(aboutButton)
        aboutButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: CGFloat(index) * fixedHeightOfLabel).isActive = true
        aboutButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        aboutButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        aboutButton.heightAnchor.constraint(equalToConstant: fixedHeightOfLabel).isActive = true
        aboutButton.addTarget(self, action: #selector(aboutAction(_:)), for: .touchUpInside)
    }
    
    // Action for the sign out button
    @objc func signOutAction(_ sender: UIButton) {
        impact.impactOccurred()
        displaySignOutPopup()
    }
    
    @objc func aboutAction(_ sender: UIButton) {
        let nextView: AboutView = AboutView()
        self.present(nextView, animated: true, completion: nil)
    }
    
    // Displays a pop up asking if the user would really like to sign out
    func displaySignOutPopup() {
        let alertController = UIAlertController(title: "Sign Out?", message: "Are you sure you want to sign out?", preferredStyle: UIAlertController.Style.alert)
        let addAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
            self.signOut()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (action: UIAlertAction!) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Signs the current user out of Google and Firebase
    func signOut() {
        GIDSignIn.sharedInstance()?.signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let googleSignIn = self.storyboard?.instantiateViewController(withIdentifier: "signIn") as? GoogleSignInViewController ?? GoogleSignInViewController()
        googleSignIn.definesPresentationContext = true
        googleSignIn.modalPresentationStyle = .fullScreen
        self.present(googleSignIn, animated: true, completion: nil)
    }
    
    // Creates a label with the given text and anchors it with the given left margin
    func makeLabel(text: String, left: CGFloat) -> UILabel {
        let label = CustomLabel()
        label.text = text
        label.textColor = Theme.sharedInstance.textColor
        label.translatesAutoresizingMaskIntoConstraints=false
        scrollView.addSubview(label)
        label.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: CGFloat(index) * fixedHeightOfLabel).isActive = true
        label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: left).isActive = true
        label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        index = index + 1
        labels.append(label)
        return label
    }
    
    // Creates a Checkbox option with the given text and achors it with the given left margin
    func makeOption(optionText: String, left: CGFloat) -> Checkbox {
        let option = Checkbox()
        option.translatesAutoresizingMaskIntoConstraints=false
        scrollView.addSubview(option)
        option.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: CGFloat(index) * fixedHeightOfLabel).isActive = true
        option.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: left).isActive = true
        option.heightAnchor.constraint(equalToConstant: 25).isActive = true
        option.widthAnchor.constraint(equalToConstant: 25).isActive = true
        option.increasedTouchRadius = 10
        let label = makeLabel(text: optionText, left: left+45)
        options.append(option)
        createGestures(label: label)
        return option
    }
    
    // Creates a radio option with the given text and anchors it with the given left margin
    func makeRadioOption(optionText: String, left: CGFloat) {
        let option = makeOption(optionText: optionText, left: left)
        option.borderStyle = .circle
        option.borderWidth = 3
        option.useHapticFeedback = false
        option.checkmarkStyle = .circle
        option.valueChanged = { (isChecked) in
            self.handleOptionClick(option: option)
        }
    }
    
    // Create gestures for the radio button labels so that they can be tapped as well
    func createGestures(label: UILabel) {
        if options.count == 1 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap1(sender:)))
            label.addGestureRecognizer(gestureRecognizer)
        } else if options.count == 2 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap2(sender:)))
            label.addGestureRecognizer(gestureRecognizer)
        } else if options.count == 3 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap3(sender:)))
            label.addGestureRecognizer(gestureRecognizer)
        } else if options.count == 4 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap4(sender:)))
            label.addGestureRecognizer(gestureRecognizer)
        } else if options.count == 5 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap5(sender:)))
            label.addGestureRecognizer(gestureRecognizer)
        }
        label.isUserInteractionEnabled = true
    }
    
    @objc func handleTap1(sender: UIGestureRecognizer) {
        handleOptionClick(option: options[0])
    }
    
    @objc func handleTap2(sender: UIGestureRecognizer) {
        handleOptionClick(option: options[1])
    }
    
    @objc func handleTap3(sender: UIGestureRecognizer) {
        handleOptionClick(option: options[2])
    }
    
    @objc func handleTap4(sender: UIGestureRecognizer) {
        handleOptionClick(option: options[3])
    }
    
    @objc func handleTap5(sender: UIGestureRecognizer) {
        handleOptionClick(option: options[4])
    }
    
    // Action for when a radio option is clicked
    @objc func handleOptionClick(option: Checkbox) {
        let index = self.options.firstIndex(of: option) ?? 0
        for option in options {
            option.isChecked = false
        }
        self.options[index].isChecked = true
        self.switchTheme()
        impact.impactOccurred()
    }
    
    // Switches the overall app theme when a different option is selected
    func switchTheme() {
        if (self.options[0].isChecked) {
            switchToAugieTheme()
        } else if (self.options[1].isChecked) {
            switchToWhiteTheme()
        } else if (self.options[2].isChecked) {
            switchToDarkTheme()
        } else if (self.options[3].isChecked) {
            switchToSeaBlueTheme()
        } else if (self.options[4].isChecked) {
            switchToTwilightPurpleTheme()
        }
    }
    
    // Switches the app to Augie theme
    func switchToAugieTheme() {
        themeManager.augieTheme()
        setTheme()
    }
    
    // Switches the app to the white theme
    func switchToWhiteTheme() {
        themeManager.whiteTheme()
        setTheme()
    }
    
    // Switches the app to the dark theme
    func switchToDarkTheme() {
        themeManager.darkTheme()
        setTheme()
    }
    
    // Switches the app to the sea blue theme
    func switchToSeaBlueTheme() {
        themeManager.seaBlueTheme()
        setTheme()
    }
    
    // Switches the app to the twilight purple theme
    func switchToTwilightPurpleTheme() {
        themeManager.twilightPurpleTheme()
        setTheme()
    }
    
    // Method for changing the preferred status bar style
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if (Theme.sharedInstance.isDark) {
            return .lightContent
        }
        return .default
    }
    
    // Sets the theme of the setting view and changes appropriate colors
    func setTheme() {
        let theme = Theme.sharedInstance.theme
        self.view.backgroundColor = Theme.sharedInstance.backgroundColor
        self.setNeedsStatusBarAppearanceUpdate()
        switch theme {
            case .augie: self.options[0].isChecked = true
            case .white: self.options[1].isChecked = true
            case .dark: self.options[2].isChecked = true
            case .seaBlue: self.options[3].isChecked = true
            case .twilightPurple: self.options[4].isChecked = true
        }
        signOutButton.backgroundColor = Theme.sharedInstance.buttonColor
        setTextColors()
        setOptionColors()
    }
    
    // Sets the text colors of the view controller
    func setTextColors() {
        for label in labels {
            label.textColor = Theme.sharedInstance.textColor
        }
    }
    
    // Sets the radio option colors
    func setOptionColors() {
        for option in options {
            option.checkboxBackgroundColor = Theme.sharedInstance.checkboxBackground
            option.checkedBorderColor = Theme.sharedInstance.checkboxColor
            option.uncheckedBorderColor = Theme.sharedInstance.checkboxColor
            option.checkmarkColor = Theme.sharedInstance.checkboxColor
            option.setNeedsDisplay()
        }
    }
    
}
