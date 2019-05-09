//
//  EventCell.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 4/4/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//
//  Custom table cell for displaying the events in the search view controller
//
//  Custom Cells: https://medium.com/@kemalekren/swift-create-custom-tableview-cell-with-programmatically-in-ios-835d3880513d

import Foundation
import UIKit

class EventCell : UITableViewCell {
    
    // Set the different attributes of the cell based on the event object
    var event : Event? {
        didSet {
            eventImage.image = event?.image
            eventNameLabel.text = event?.name
            var description = ""
            if let location = event?.getLocation() {
                description = "\(description)\(location)"
            }
            if let date = event?.getDate() {
                description = "\(description)\n\(date)"
            }
            if let time = event?.getTimes() {
                description = "\(description)\n\(time)"
            }
            if let organization = event?.getOrganization() {
                description = "\(description)\n\(organization)"
            }
            eventDescriptionLabel.text = description
        }
    }
    
    // Label for the name of the event
    let eventNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()
    
    // Description label for the location, date, time, and organization of the event
    let eventDescriptionLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    // Image view for the event image
    private let eventImage : UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "augieIcon"))
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    // Constructor - add and anchor the different views
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(eventImage)
        addSubview(eventNameLabel)
        addSubview(eventDescriptionLabel)
        
        eventNameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        
        eventImage.anchor(top: eventNameLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 90, height: 90, enableInsets: false)
        
        eventDescriptionLabel.anchor(top: eventNameLabel.bottomAnchor, left: eventImage.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
