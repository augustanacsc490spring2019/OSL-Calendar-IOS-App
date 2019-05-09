//
//  RCValues.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 4/11/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//
//  Manages the values for the remote config

import Firebase
import FirebaseRemoteConfig

class RCValues {
    
    static let sharedInstance = RCValues()
    
    private init() {
        loadDefaultValues()
        fetchCloudValues()
    }
    
    // Load the default values
    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            "force_update_required_ios" : false,
            "force_update_version_ios" : "1.0.0",
            "force_update_store_url_ios" : "" 
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }
    
    // Fetch the cloud remote config values
    func fetchCloudValues() {
        let fetchDuration: TimeInterval = 3600
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { status, error in
            
            if let error = error {
                print("Error fetching remote config: \(error)")
                return
            }
            
            RemoteConfig.remoteConfig().activateFetched()
            print("Fetched remote config.")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.triggerFetched()
        }
    }
}
