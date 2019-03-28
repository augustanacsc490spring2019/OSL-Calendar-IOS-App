//
//  SearchViewController.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/26/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SimpleCheckbox
import Toast_Swift

enum Sort {
    case az
    case za
    // other cases
}

protocol DisplayEvent {
    func getEvent(event: Event)
}

class SearchViewController: UITableViewController, Return {
    
    let themeManager = ThemeManager()
    var sortedArray: [Event] = []
    var database: DatabaseReference!
    var fixedHeightOfLabel: CGFloat = 45
    var index: Double = 0.6
    var labels: [UILabel] = []
    var isDown = true
    var sortView = UIView()
    var options: [Checkbox] = []
    var firstSort = true
    var sortButton = UIBarButtonItem()
    var sortBy: Sort = Sort.az
    var eventController = EventViewController()
    var isEvent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = false
        self.navigationController?.view.makeToastActivity(.center)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        getTheme()
        database = Database.database().reference().child("current-events")
        databaseListener()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellIdentifier")
        
        print("\(#function) --- section = \(indexPath.section), row = \(indexPath.row)")
        
        let event = sortedArray[indexPath.row]
        cell.textLabel?.text = "\(event.getName())"
        cell.imageView?.image = UIImage(named: "augieIcon")
        cell.detailTextLabel?.text = "\(event.getDate()), \(event.getLocation()), \(event.getOrganization())"
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = Theme.sharedInstance.textColor
        cell.detailTextLabel?.textColor = Theme.sharedInstance.textColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isEvent = true
        let event = sortedArray[indexPath.row]
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        eventController = self.storyboard?.instantiateViewController(withIdentifier: "event") as? EventViewController ?? EventViewController()
        self.definesPresentationContext = true
        eventController.delegate = self
        self.eventController.getEvent(event: event)
        let navigationController = UINavigationController(rootViewController: eventController)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.present(navigationController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View Will Appear: Search")
        if (isEvent == true) {
            eventController.viewWillAppear(animated)
        }
        setTheme()
    }
    
    func returnFromEventView() {
        isEvent = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.setNeedsLayout()
        tableView.reloadData()
    }
    
    @IBAction func sortAction(_ sender: Any) {
        if (self.isDown) {
            tableView.isScrollEnabled = false
            if (firstSort) {
                firstSort = false
                setUpSortView()
            }
            tableView.backgroundColor = Theme.sharedInstance.darkerBackground
            sortView.isHidden = false
            self.view.bringSubviewToFront(sortView)
            self.sortButton.image = UIImage(named: "upSort")
            self.isDown = false
        } else {
            closeSortView()
        }
    }
    
    func closeSortView() {
        sortView.isHidden = true
        tableView.isScrollEnabled = true
        tableView.backgroundColor = Theme.sharedInstance.backgroundColor
        self.sortButton.image = UIImage(named: "downSort")
        self.isDown = true
        if (self.options[0].isChecked) {
            self.sortedArray = self.sortedArray.sorted(by: { $0.name < $1.name })
            self.sortBy = Sort.az
        } else if (self.options[1].isChecked) {
            self.sortedArray = self.sortedArray.sorted(by: { $0.name > $1.name })
            self.sortBy = Sort.za
        } //else if (self.options[2].isChecked) {
//            self.sortedArray = self.sortedArray.sorted(by: { $0.price < $1.price })
//            self.sortBy = Sort.priceLowToHigh
//        } else if (self.options[3].isChecked) {
//            self.sortedArray = self.sortedArray.sorted(by: { $0.price > $1.price })
//            self.sortBy = Sort.priceHighToLow
//        } else if (self.options[4].isChecked) {
//            self.sortedArray = self.sortedArray.sorted(by: { $0.rating > $1.rating })
//            self.sortBy = Sort.bestRatingsFirst
//        } else if (self.options[5].isChecked) {
//            self.sortedArray = self.sortedArray.sorted(by: { $0.rating < $1.rating })
//            self.sortBy = Sort.worstRatingsFirst
//        }
        tableView.reloadData()
    }
    
    func setUpSortView() {
        index = 0.6
        options = []
        sortView = UIView()
        sortView.isHidden = true
        sortView.backgroundColor = Theme.sharedInstance.backgroundColor
        sortView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationController?.view.addSubview(sortView)
        sortView.layer.borderWidth = 0.5
        sortView.layer.borderColor = UIColor.lightGray.cgColor
        let top = 20 + UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.size.height ?? 0)
        sortView.topAnchor.constraint(equalTo: (self.navigationController?.view.topAnchor)!, constant: top).isActive = true
        sortView.leftAnchor.constraint(equalTo: (self.navigationController?.view.leftAnchor)!, constant: 20).isActive = true
        sortView.rightAnchor.constraint(equalTo: (self.navigationController?.view.rightAnchor)!, constant: -20).isActive = true
        sortView.bottomAnchor.constraint(equalTo: (self.navigationController?.view.safeAreaLayoutGuide.bottomAnchor)!, constant: -20).isActive = true
        makeLabelForRadio(text: "Sort", left: 40)
        makeRadioOption(optionText: "A-Z", left: 40)
        makeRadioOption(optionText: "Z-A", left: 40)
//        makeRadioOption(optionText: "Price: Low to High", left: 40)
//        makeRadioOption(optionText: "Price: High to Low", left: 40)
//        makeRadioOption(optionText: "Best Ratings First", left: 40)
//        makeRadioOption(optionText: "Worst Ratings First", left: 40)
        if (sortBy == Sort.az) {
            options[0].isChecked = true
        } else if (sortBy == Sort.za) {
            options[1].isChecked = true
        } //else if (sortBy == Sort.priceLowToHigh) {
//            options[2].isChecked = true
//        } else if (sortBy == Sort.priceHighToLow) {
//            options[3].isChecked = true
//        } else if (sortBy == Sort.bestRatingsFirst) {
//            options[4].isChecked = true
//        } else if (sortBy == Sort.worstRatingsFirst) {
//            options[5].isChecked = true
//        }
        setOptionColors()
    }
    
    func makeLabelForRadio(text: String, left: CGFloat) {
        let label = UILabel()
        label.text = text
        label.textColor = Theme.sharedInstance.textColor
        label.translatesAutoresizingMaskIntoConstraints=false
        sortView.addSubview(label)
        label.topAnchor.constraint(equalTo: sortView.topAnchor, constant: CGFloat(index) * fixedHeightOfLabel).isActive = true
        label.leftAnchor.constraint(equalTo: sortView.leftAnchor, constant: left).isActive = true
        label.trailingAnchor.constraint(equalTo: sortView.trailingAnchor).isActive = true
        index = index + 1
        labels.append(label)
    }
    
    func makeOption(optionText: String, left: CGFloat) -> Checkbox {
        let option = Checkbox()
        option.translatesAutoresizingMaskIntoConstraints=false
        sortView.addSubview(option)
        option.topAnchor.constraint(equalTo: sortView.topAnchor, constant: CGFloat(index) * fixedHeightOfLabel).isActive = true
        option.leftAnchor.constraint(equalTo: sortView.leftAnchor, constant: left).isActive = true
        option.heightAnchor.constraint(equalToConstant: 25).isActive = true
        option.widthAnchor.constraint(equalToConstant: 25).isActive = true
        option.increasedTouchRadius = 10
        makeLabelForRadio(text: optionText, left: left+45)
        options.append(option)
        return option
    }
    
    func makeRadioOption(optionText: String, left: CGFloat) {
        let option = makeOption(optionText: optionText, left: left)
        option.borderStyle = .circle
        option.borderWidth = 3
        option.checkmarkStyle = .circle
        option.valueChanged = { (isChecked) in
            let index = self.options.firstIndex(of: option) ?? 0
            self.options[0].isChecked = false
            self.options[1].isChecked = false
//            self.options[2].isChecked = false
//            self.options[3].isChecked = false
//            self.options[4].isChecked = false
//            self.options[5].isChecked = false
            self.options[index].isChecked = true
            self.closeSortView()
        }
    }
    
    func databaseListener() {
        database.observe(DataEventType.value, with: { (snapshot) in
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                let postDict = snap.value as? NSDictionary
                let name = postDict?["name"] as? String ?? ""
                let location = postDict?["location"] as? String ?? ""
                let date = postDict?["date"] as? String ?? ""
                let organization = postDict?["organization"] as? String ?? ""
                let type = postDict?["type"] as? String ?? ""
                let tags = postDict?["tags"] as? String ?? ""
                let imgid = postDict?["imgid"] as? String ?? ""
                let description = postDict?["description"] as? String ?? ""
                let event = Event(name: name, location: location, date: date, organization: organization, type: type, tags: tags, imgid: imgid, description: description)
                self.sortedArray.append(event)
            }
            self.tableView.reloadData()
            self.navigationController?.view.hideToastActivity()
            self.view.isUserInteractionEnabled = true
        })
    }
    
    func setTheme() {
        self.view.backgroundColor = Theme.sharedInstance.backgroundColor
        tableView.backgroundColor = Theme.sharedInstance.backgroundColor
        sortView.backgroundColor = Theme.sharedInstance.backgroundColor
        if (!isDown) {
            tableView.backgroundColor = Theme.sharedInstance.darkerBackground
        }
        self.setNeedsStatusBarAppearanceUpdate()
        setTextColors()
        setOptionColors()
        tableView.reloadData()
    }
    
    func setTextColors() {
        for label in labels {
            label.textColor = Theme.sharedInstance.textColor
        }
    }
    
    func setOptionColors() {
        for option in options {
            option.checkboxBackgroundColor = Theme.sharedInstance.checkboxBackground
            option.checkedBorderColor = Theme.sharedInstance.checkboxColor
            option.uncheckedBorderColor = Theme.sharedInstance.checkboxColor
            option.checkmarkColor = Theme.sharedInstance.checkboxColor
            option.setNeedsDisplay()
        }
    }
    
    func getTheme() {
        let preferences = UserDefaults.standard
        if let theme = preferences.string(forKey: "theme") {
            themeManager.setInitialTheme(theme: theme)
        }
    }
    
}
