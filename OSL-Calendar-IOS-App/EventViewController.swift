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
    
    var event: Event = Event(name: "", location: "", startDate: "", duration: 0, organization: "", tags: "", imgid: "", description: "")
    var delegate: Return?
    var labels: [UILabel] = []
    var index: CGFloat = 15
    var image = UIImageView()
    var calendarButton = UIButton()
    var scrollView = UIScrollView()
    var containerView = UIView()
    var fixedHeightOfLabel: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        generateLayout()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: index*fixedHeightOfLabel)
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
        let imageView = UIImageView(image: UIImage(named: "augieIcon"))
        scrollView.addSubview(imageView)
        let bounds = UIScreen.main.bounds
        imageView.frame = CGRect(x: bounds.width/4, y: bounds.height/20, width: bounds.width/2, height: bounds.width/2)
        makeLabel(text: "Name: \(event.getName())", size: 20)
        makeLabel(text: "Location: \(event.getLocation())", size: 20)
        makeLabel(text: "Date: \(event.getDate())", size: 20)
        makeLabel(text: "Time: \(event.getTimes())", size: 20)
        makeLabel(text: "Organization: \(event.getOrganization())", size: 20)
        makeLabel(text: "Description: \(event.getDescription())", size: 20)
        addCalendarButton()
    }
    
    func addCalendarButton() {
        calendarButton.setTitle("Add to Calendar", for: .normal)
        calendarButton.setTitleColor(.black, for: .normal)
        calendarButton.backgroundColor = UIColor.init(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        calendarButton.translatesAutoresizingMaskIntoConstraints=false
        scrollView.addSubview(calendarButton)
        index = index + 2
        calendarButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: index * fixedHeightOfLabel).isActive = true
        calendarButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        calendarButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        calendarButton.heightAnchor.constraint(equalToConstant: CGFloat(45)).isActive = true
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
                event.title = self.event.getName()
                event.startDate = self.event.getStartDate()
                event.endDate = self.event.getEndDate()
                event.notes = self.event.getDescription()
                event.calendar = eventStore.defaultCalendarForNewEvents
                let predicate = eventStore.predicateForEvents(withStart: self.event.getStartDate(), end: self.event.getEndDate(), calendars: nil)
                let existingEvents = eventStore.events(matching: predicate)
                for singleEvent in existingEvents {
                    if singleEvent.title == self.event.getName() && singleEvent.startDate == self.event.getStartDate() && singleEvent.endDate == self.event.getEndDate() {
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
                event.title = self.event.getName()
                event.startDate = self.event.getStartDate()
                event.endDate = self.event.getEndDate()
                event.notes = self.event.getDescription()
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
    
    func makeLabel(text: String, size: CGFloat) {
        let label = UILabel()
        label.text = text
        label.textColor = Theme.sharedInstance.textColor
        label.translatesAutoresizingMaskIntoConstraints=false
        scrollView.addSubview(label)
        label.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: index*fixedHeightOfLabel).isActive = true
        label.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        label.textAlignment = .center
        label.font = UIFont(name: "San Fransisco", size: size)
        label.sizeToFit()
        label.lineBreakMode = NSLineBreakMode.byCharWrapping
        label.numberOfLines = 0
        index = index + 1
        labels.append(label)
    }
    
    func getEvent(event: Event) {
        self.event = event
    }
    
    func setTheme() {
        self.view.backgroundColor = Theme.sharedInstance.backgroundColor
        for label in labels {
            label.textColor = Theme.sharedInstance.textColor
        }
    }
    
}
