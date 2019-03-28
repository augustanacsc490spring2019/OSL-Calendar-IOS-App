//
//  EventViewController.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/27/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//

import Foundation
import UIKit

protocol Return {
    func returnFromEventView()
}

class EventViewController: UIViewController, DisplayEvent, UIScrollViewDelegate {
    
    var event: Event = Event(name: "", location: "", date: "", organization: "", type: "", tags: "", imgid: "", description: "")
    var delegate: Return?
    var labels: [UILabel] = []
    var index = 10
    var image = UIImageView()
    var calendarButton = UIButton()
    var scrollView = UIScrollView()
    var containerView = UIView()
    var fixedHeightOfLabel = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        generateLayout()
        setTheme()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 3000)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTheme()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.delegate?.returnFromEventView()
        self.dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    func setUpScrollView() {
        let margins = self.view.safeAreaLayoutGuide
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 3000)
        containerView.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }
    
    func generateLayout() {
        let imageView = UIImageView(image: UIImage(named: "augieIcon"))
        self.view.addSubview(imageView)
        let bounds = UIScreen.main.bounds
        imageView.frame = CGRect(x: bounds.width/4, y: bounds.height/7, width: bounds.width/2, height: bounds.width/2)
        makeLabel(text: "Name: \(event.getName())", size: 20)
        makeLabel(text: "Location: \(event.getLocation())", size: 20)
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
        calendarButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: CGFloat(index) * CGFloat(fixedHeightOfLabel)).isActive = true
        calendarButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        calendarButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        calendarButton.heightAnchor.constraint(equalToConstant: CGFloat(fixedHeightOfLabel)).isActive = true
        calendarButton.addTarget(self, action: #selector(calendarAction), for: .touchUpInside)
    }
    
    @objc func calendarAction() {
        
    }
    
    func makeLabel(text: String, size: CGFloat) {
        let label = UILabel()
        label.text = text
        label.textColor = Theme.sharedInstance.textColor
        label.translatesAutoresizingMaskIntoConstraints=false
        scrollView.addSubview(label)
        label.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: CGFloat(index*fixedHeightOfLabel)).isActive = true
        label.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        label.textAlignment = .center
        label.font = UIFont(name: "San Fransisco", size: size)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        index = index + 2
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
