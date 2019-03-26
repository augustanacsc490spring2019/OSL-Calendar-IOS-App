//
//  Event.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/26/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//

import Foundation

class Event {
    
    var name = ""
    var location = ""
    var date = ""
    var organization = ""
    var type = ""
    var tags: [String] = []
    var imgid = 0
    
    init(name: String, location: String, date: String, organization: String, type: String, tags: [String], imgid: Int) {
        self.name = name
        self.location = location
        self.date = date
        self.organization = organization
        self.type = type
        self.tags = tags
        self.imgid = imgid
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getLocation() -> String {
        return self.location
    }
    
    func getDate() -> String {
        return self.date
    }
    
    func getOrganization() -> String {
        return self.organization
    }
    
    func getType() -> String {
        return self.type
    }
    
    func getTags() -> [String] {
        return self.tags
    }
    
    func getImgid() -> Int {
        return self.imgid
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func setLocation(location: String) {
        self.location = location
    }
    
    func setDate(date: String) {
        self.date = date
    }
    
    func setOrganization(organization: String) {
        self.organization = organization
    }
    
    func setType(type: String) {
        self.type = type
    }
    
    func setTags(tags: [String]) {
        self.tags = tags
    }
    
    func setImgid(imgid: Int) {
        self.imgid = imgid
    }
    
}
