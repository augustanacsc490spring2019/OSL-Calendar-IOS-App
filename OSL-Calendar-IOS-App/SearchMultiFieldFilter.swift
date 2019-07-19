//
//  SearchMultiFieldFilter.swift
//  OSL-Calendar-IOS-App
//
//  Created by checkout on 7/16/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//

import Foundation

class SearchMultiFieldFilter {
    
    var query : String
    var enabled : Bool
    var activated: Bool
    
    init(query : String) {
        self.query = query
        enabled = false
        activated = false
    }
    
    func isEnabled() -> Bool {
        return enabled
    }
    
    func setEnabled(enabled: Bool) {
        self.enabled = enabled
    }
    
    func isActivated() -> Bool {
        return activated
    }
    
    func setActivated(activated : Bool) {
        self.activated = activated
    }
    
    func applyFilter(event: Event) -> Bool {
        if (!enabled) {
            return true
        }
        return event.name.lowercased().contains(query) || event.location.lowercased().contains(query) || event.organization.lowercased().contains(query) || event.tags.lowercased().contains(query)
    }
}
