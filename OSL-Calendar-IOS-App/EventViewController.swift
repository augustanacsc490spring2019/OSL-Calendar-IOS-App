//
//  EventViewController.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/27/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//
//  https://stackoverflow.com/questions/28379603/how-to-add-an-event-in-the-device-calendar-using-swift
//  https://stackoverflow.com/questions/39132741/how-can-i-check-if-event-exist-on-calendar

import Foundation
import UIKit
import EventKit

var group = DispatchGroup()

protocol Return {
    func returnFromEventView()
}

class EventViewController: UIViewController, DisplayEvent {
    
    var event : Event? {
        didSet {
            eventImage.image = event?.image
            eventNameLabel.text = event?.name
            var description = ""
            if let location = event?.getLocation() {
                description = "\(description)Location: \(location)"
            }
            if let date = event?.getDate() {
                description = "\(description)\nDate: \(date)"
            }
            if let time = event?.getTimes() {
                description = "\(description)\nTime: \(time)"
            }
            if let organization = event?.getOrganization() {
                description = "\(description)\nOrganization: \(organization)"
            }
            eventDescriptionLabel.text = description
        }
    }
    
    let eventNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.boldSystemFont(ofSize: 32)
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    
    let eventDescriptionLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let eventImage : UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "augieIcon"))
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private let calendarButton : UIButton = {
        let btn = UIButton()
        btn.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        btn.setTitle("Add to Calendar", for: .normal)
        btn.backgroundColor = Theme.sharedInstance.buttonColor
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    var delegate: Return?
    var scrollView = UIScrollView()
    var containerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        generateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTheme()
        checkEventInCalendar()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.delegate?.returnFromEventView()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpScrollView() {
        let margins = self.view.safeAreaLayoutGuide
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 3000)
        containerView.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    }
    
    func generateLayout() {
        scrollView.addSubview(eventImage)
        scrollView.addSubview(eventNameLabel)
        scrollView.addSubview(eventDescriptionLabel)
        scrollView.addSubview(calendarButton)
        
        eventNameLabel.anchor(top: scrollView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        eventNameLabel.center.x = scrollView.center.x
        
        eventImage.anchor(top: eventNameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 3*UIScreen.main.bounds.width/4, height: 3*UIScreen.main.bounds.width/4, enableInsets: false)
        eventImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        eventDescriptionLabel.anchor(top: eventImage.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        eventDescriptionLabel.center.x = scrollView.center.x
        
        calendarButton.anchor(top: eventDescriptionLabel.bottomAnchor, left: containerView.leftAnchor, bottom: scrollView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 45, enableInsets: false)
        calendarButton.center.x = scrollView.center.x
        calendarButton.addTarget(self, action: #selector(calendarAction), for: .touchUpInside)
    }
    
    func checkEventInCalendar() {
        let eventStore = EKEventStore()
        var isExistingEvent = false
        var isError = false
        group.enter()
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = self.event!.getName()
                event.startDate = self.event!.getStartDate()
                event.endDate = self.event!.getEndDate()
                event.notes = self.event!.getDescription()
                event.calendar = eventStore.defaultCalendarForNewEvents
                let predicate = eventStore.predicateForEvents(withStart: self.event!.getStartDate(), end: self.event!.getEndDate(), calendars: nil)
                let existingEvents = eventStore.events(matching: predicate)
                for singleEvent in existingEvents {
                    if singleEvent.title == self.event!.getName() && singleEvent.startDate == self.event!.getStartDate() && singleEvent.endDate == self.event!.getEndDate() {
                        isExistingEvent = true
                    }
                }
            } else {
                isError = true
                //completion?(false, error as NSError?)
            }
            group.leave()
        })
        group.notify(queue: .main) {
            if (isExistingEvent) {
                self.calendarButton.isEnabled = false
                self.calendarButton.setTitle("Already in Calendar", for: .normal)
            } else if (isError) {
                self.view.makeToast("Unable to access calendar, make sure permissions are allowed in Settings")
                self.calendarButton.isEnabled = false
                self.calendarButton.setTitle("No Access to Calendar", for: .normal)
            } else {
                self.calendarButton.isEnabled = true
                self.calendarButton.setTitle("Add to Calendar", for: .normal)
            }
        }
    }
    
    @objc func calendarAction() {
        let eventStore = EKEventStore()
        var isExistingEvent = false
        group.enter()
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = self.event!.getName()
                event.startDate = self.event!.getStartDate()
                event.endDate = self.event!.getEndDate()
                event.notes = self.event!.getDescription()
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    //completion?(false, e)
                    return
                }
                //completion?(true, nil)
                
            } else {
                //completion?(false, error as NSError?)
            }
            group.leave()
        })
        group.notify(queue: .main) {
            self.view.makeToast("Added event to calendar")
            self.calendarButton.isEnabled = false
            self.calendarButton.setTitle("Added", for: .normal)
        }
    }
    
    func getEvent(event: Event) {
        self.event = event
    }
    
    func setTheme() {
        self.view.backgroundColor = Theme.sharedInstance.backgroundColor
        eventNameLabel.textColor = Theme.sharedInstance.textColor
        eventDescriptionLabel.textColor = Theme.sharedInstance.textColor
        calendarButton.backgroundColor = Theme.sharedInstance.buttonColor
    }
    
}
