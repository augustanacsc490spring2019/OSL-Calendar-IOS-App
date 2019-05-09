//
//  AppDelegate.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/26/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

var email: String = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var needUpdate: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let _ = RCValues.sharedInstance
        // Configure Firebase and Google Sign in
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        // If user is signed in, continue to the tab view
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                email = user.email!
                if (email.contains("@augustana.edu")) {
                    self.continueToTabView()
                } else {
                    self.signOut()
                }
            } else {
            }
        }
        return true
    }
    
    // Handle URL for Google sign in
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    // Handle Google/Firebase sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // Cancelled Google sign in
        if let err = error {
            print(err)
            self.window?.rootViewController?.view.hideToastActivity()
            self.window?.rootViewController?.view.isUserInteractionEnabled = true
            return
        }
        
        // Successful Google sign in
        guard let authentication = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        // Authenticate with Firebase
        Auth.auth().signInAndRetrieveData(with: credentials, completion: { (user, error) in
            
            // Error authenticating with Firebase
            if let err = error {
                print(err)
                return
            }
        })
    }
    
    // Initialize the tab view controller with the find events page showing
    func continueToTabView() {
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "tab") as UIViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewControlleripad
        self.window?.makeKeyAndVisible()
    }
    
    // Sign the user out of Google and Firebase
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.window?.rootViewController?.view.hideToastActivity()
        self.window?.rootViewController?.view.isUserInteractionEnabled = true
        self.window?.makeToast("Must login with Augustana email!", position: .center)
    }
    
    // Called once the remote config successfully loaded the RC values
    func triggerFetched() {
        let updateRequired = RemoteConfig.remoteConfig().configValue(forKey: "force_update_required").boolValue
        if (updateRequired) {
            let cloudVersion = RemoteConfig.remoteConfig()
                .configValue(forKey: "force_update_version_ios")
                .stringValue?
                .replacingOccurrences(of: ".", with: "")
            let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let cloudNum: Int = Int(cloudVersion!)! // firstText is UITextField
            let currentNum: Int = Int(currentVersion.replacingOccurrences(of: ".", with: ""))!
            if (currentNum < cloudNum) {
                self.window?.rootViewController?.view.isUserInteractionEnabled = false
                updateAlert()
                needUpdate = true
            }
        }
    }
    
    // Displays an update alert to the user
    func updateAlert() {
        let alert = UIAlertController(title: "New Version Available", message: "Please update the app to the newest version.", preferredStyle: UIAlertController.Style.alert)
        let update = UIAlertAction(title: "Update", style: UIAlertAction.Style.default, handler: { action in
            let link = "https://itunes.apple.com/us/app/aces-augustana-college/id1437441626?ls=1&mt=8"
            if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                    if success {
                        print("Launch successful")
                    }
                })
            }
        })
        alert.addAction(update)
        DispatchQueue.main.async(execute: {
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if (needUpdate) {
            self.window?.rootViewController?.view.isUserInteractionEnabled = false
            updateAlert()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

