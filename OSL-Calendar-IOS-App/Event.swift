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
    var startDate = ""
    var duration = 0
    var organization = ""
    var tags = ""
    var imgid = ""
    var description = ""
    
    init(name: String, location: String, startDate: String, duration: Int, organization: String, tags: String, imgid: String, description: String) {
        self.name = name
        self.location = location
        self.startDate = startDate
        self.duration = duration
        self.organization = organization
        self.tags = tags
        self.imgid = imgid
        self.description = description
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getLocation() -> String {
        return self.location
    }
    
    func getFullDate() -> String {
        return self.startDate
    }
    
    func getDate() -> String {
        let array = startDate.split(separator: " ")
        return "\(String(array[0]))"
    }
    
    func getTimes() -> String {
        let array = startDate.split(separator: " ")
        let dateAsString = array[1]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time24 = dateFormatter.date(from: String(dateAsString))
        dateFormatter.dateFormat = "h:mm a"
        let startTime = dateFormatter.string(from: time24!)
        var minutes = DateComponents.init()
        minutes.minute = getDuration()
        let addTime = Calendar.current.date(byAdding: minutes, to: time24!)
        return "\(startTime)-\(dateFormatter.string(from: addTime!))"
    }
    
    func getStartDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let date = dateFormatter.date(from:startDate)
        return date!
    }
    
    func getEndDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let date = dateFormatter.date(from:startDate)
        var minutes = DateComponents.init()
        minutes.minute = getDuration()
        let addTime = Calendar.current.date(byAdding: minutes, to: date!)
        return addTime!
    }
    
    func getDuration() -> Int {
        return self.duration
    }
    
    func getOrganization() -> String {
        return self.organization
    }
    
    func getTags() -> String {
        return self.tags
    }
    
    func getImgid() -> String {
        return self.imgid
    }
    
    func getDescription() -> String {
        return self.description
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func setLocation(location: String) {
        self.location = location
    }
    
    func setStartDate(startDate: String) {
        self.startDate = startDate
    }
    
    func setDuration(duration: Int) {
        self.duration = duration
    }
    
    func setOrganization(organization: String) {
        self.organization = organization
    }
    
    func setTags(tags: String) {
        self.tags = tags
    }
    
    func setImgid(imgid: String) {
        self.imgid = imgid
    }
    
    func setDescription(description: String) {
        self.description = description
    }
    
}
