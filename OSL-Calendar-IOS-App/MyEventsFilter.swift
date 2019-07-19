//
//  MyEventsFilter.swift
//  OSL-Calendar-IOS-App
//
//  Created by checkout on 7/15/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//

import Foundation

class MyEventsFilter {
    
    var user : String
    var enabled : Bool
    
    init(user : String) {
        self.user = user
        enabled = false
    }
    
    func isEnabled() -> Bool {
        return enabled
    }
    
    func setEnabled(enabled : Bool) {
        self.enabled = enabled
    }
    
    func applyFilter(event: Event) -> Bool {
        if (!enabled) {
            return true
        }
        return event.getFavoritedBy().keys.contains(user)
    }
}
