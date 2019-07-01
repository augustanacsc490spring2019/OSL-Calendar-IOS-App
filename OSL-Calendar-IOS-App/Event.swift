//
//  Event.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/26/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//
//  The event object that stores all of the necessary information for a given event

import Foundation
import UIKit
import FirebaseStorage

class Event {
    
    var name = ""
    var location = ""
    var startDate = ""
    var duration = 0
    var organization = ""
    var tags = ""
    var imgid = ""
    var description = ""
    var image = UIImage()
    
    init(name: String, location: String, startDate: String, duration: Int, organization: String, tags: String, imgid: String, description: String) {
        self.name = name
        self.location = location
        self.startDate = startDate
        self.duration = duration
        self.organization = organization
        self.tags = tags
        self.imgid = imgid
        self.description = description
        group.enter()
        setImage(completion: { boolean in
            group.leave()
        })
    }
    
    // Uses the imgid to download the image from Firebase and set the image of the current event object
    func setImage(completion: @escaping (Bool)->() ) {
        if (self.imgid == "default") {
            self.image = UIImage(named: "default")!
            completion(true)
        } else {
            let storage = Storage.storage().reference()
            let picture = storage.child("Images").child("\(self.imgid).jpg")
            picture.getData(maxSize: Int64.max) { data, error in
                if let error = error {
                    print(error)
                    completion(false)
                } else {
                    if let image = UIImage(data: data!) {
                        self.image = image
                    }
                    completion(true)
                }
            }
        }
    }
    
    // Getters and setters
    func getName() -> String {
        return self.name
    }
    
    func getLocation() -> String {
        return self.location
    }
    
    func getFullDate() -> String {
        return self.startDate
    }
    
    // Returns the date only (for displaying to the user)
    func getDate() -> String {
        let date = startDate.split(separator: " ")
        let formattedDate = date[0].split(separator: "-")
        return "\(String(formattedDate[1] + "-" + formattedDate[2] + "-" + formattedDate[0]))"
    }
    
    // Returns a formatted start time to end time string (for displaying to the user)
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
    
    // Returns a date object of the start date of the event (for sorting)
    func getStartDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from:startDate)
        return date!
    }
    
    // Returns a date object of the end date of the event (for sorting)
    func getEndDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
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
