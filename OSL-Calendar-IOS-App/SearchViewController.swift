//
//  SearchViewController.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/26/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//
//  https://www.natashatherobot.com/custom-uitableviewcell-selection-style-color/

import Foundation
import UIKit
import Firebase
import SimpleCheckbox
import Toast_Swift

let impact = UIImpactFeedbackGenerator()

enum Sort {
    case az
    case za
    case soonestFirst
    case organization
}

protocol DisplayEvent {
    func getEvent(event: Event)
}

class SearchViewController: UITableViewController, Return {
    
    @IBOutlet weak var sortButton: UIBarButtonItem!
    let themeManager = ThemeManager()
    var sortedArray: [Event] = []
    var filteredEvents: [Event] = []
    var database: DatabaseReference!
    var fixedHeightOfLabel: CGFloat = 45
    var index: Double = 0.6
    var labels: [UILabel] = []
    var isDown = true
    var sortView = UIView()
    var options: [Checkbox] = []
    var firstSort = true
    var sortBy: Sort = Sort.soonestFirst
    var eventController = EventViewController()
    var isEvent = false
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.isUserInteractionEnabled = false
        self.navigationController?.view.makeToastActivity(.center)
        tableView.register(EventCell.self, forCellReuseIdentifier: "cellIdentifier")
        definesPresentationContext = true
        getTheme()
        database = Database.database().reference().child("current-events")
        databaseListener()
        setUpSearchBar()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredEvents.count
        }
        return sortedArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! EventCell
        
        let event: Event
        if isFiltering() {
            event = filteredEvents[indexPath.row]
        } else {
            event = sortedArray[indexPath.row]
        }
        cell.event = event
        
        cell.backgroundColor = UIColor.clear
        cell.eventNameLabel.textColor = Theme.sharedInstance.textColor
        cell.eventDescriptionLabel.textColor = Theme.sharedInstance.textColor
        
        let customColorView = UIView()
        customColorView.backgroundColor = Theme.sharedInstance.darkerBackground
        cell.selectedBackgroundView =  customColorView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isEvent = true
        let event: Event
        if isFiltering() {
            event = filteredEvents[indexPath.row]
            searchController.dismiss(animated: false) {
                self.presentEvent(event: event)
            }
        } else {
            event = sortedArray[indexPath.row]
            presentEvent(event: event)
        }
    }
    
    func presentEvent(event: Event) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        eventController = self.storyboard?.instantiateViewController(withIdentifier: "event") as? EventViewController ?? EventViewController()
        eventController.delegate = self
        self.eventController.getEvent(event: event)
        let navigationController = UINavigationController(rootViewController: eventController)
        navigationController.modalPresentationStyle = .overCurrentContext
        navigationController.definesPresentationContext = true
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
            tableView.isUserInteractionEnabled = false
            tableView.backgroundColor = Theme.sharedInstance.darkerBackground
            sortView.isHidden = false
            self.view.bringSubviewToFront(sortView)
            self.sortButton.image = UIImage(named: "upSort")
            self.isDown = false
        } else {
            closeSortView()
        }
        impact.impactOccurred()
    }
    
    func setUpSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredEvents = sortedArray.filter({( event: Event) -> Bool in
            let text = searchText.lowercased()
            return event.name.lowercased().contains(text) || event.location.lowercased().contains(text) || event.organization.lowercased().contains(text) || event.tags.lowercased().contains(text)
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }
    
    func closeSortView() {
        sortView.isHidden = true
        tableView.isUserInteractionEnabled = true
        tableView.backgroundColor = Theme.sharedInstance.backgroundColor
        self.sortButton.image = UIImage(named: "downSort")
        self.isDown = true
        sortArray()
    }
    
    func sortArray() {
        if (self.options[0].isChecked) {
            self.sortedArray = self.sortedArray.sorted(by: { $0.name < $1.name })
            self.sortBy = Sort.az
        } else if (self.options[1].isChecked) {
            self.sortedArray = self.sortedArray.sorted(by: { $0.name > $1.name })
            self.sortBy = Sort.za
        } else if (self.options[2].isChecked) {
            self.sortedArray = self.sortedArray.sorted(by: { $0.getStartDate() < $1.getStartDate() })
            self.sortBy = Sort.soonestFirst
        } else if (self.options[3].isChecked) {
            self.sortedArray = self.sortedArray.sorted(by: { $0.organization < $1.organization })
            self.sortBy = Sort.organization
        }
        if (isFiltering()){
            self.filterContentForSearchText(searchController.searchBar.text!)
        }
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
        makeRadioOption(optionText: "Soonest First", left: 40)
        makeRadioOption(optionText: "Organization", left: 40)
        initialSort()
        setOptionColors()
    }
    
    func initialSort() {
        if (sortBy == Sort.az) {
            options[0].isChecked = true
        } else if (sortBy == Sort.za) {
            options[1].isChecked = true
        } else if (sortBy == Sort.soonestFirst) {
            options[2].isChecked = true
        } else if (sortBy == Sort.organization) {
            options[3].isChecked = true
        }
    }
    
    func makeLabelForRadio(text: String, left: CGFloat) -> UILabel {
        let label = CustomLabel()
        label.text = text
        label.textColor = Theme.sharedInstance.textColor
        label.translatesAutoresizingMaskIntoConstraints=false
        sortView.addSubview(label)
        label.topAnchor.constraint(equalTo: sortView.topAnchor, constant: CGFloat(index) * fixedHeightOfLabel).isActive = true
        label.leftAnchor.constraint(equalTo: sortView.leftAnchor, constant: left).isActive = true
        label.trailingAnchor.constraint(equalTo: sortView.trailingAnchor).isActive = true
        index = index + 1
        labels.append(label)
        return label
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
        let label = makeLabelForRadio(text: optionText, left: left+45)
        options.append(option)
        createGestures(label: label)
        return option
    }
    
    func makeRadioOption(optionText: String, left: CGFloat) {
        let option = makeOption(optionText: optionText, left: left)
        option.borderStyle = .circle
        option.borderWidth = 3
        option.checkmarkStyle = .circle
        option.valueChanged = { (isChecked) in
            self.handleOptionClick(option: option)
        }
    }
    
    func databaseListener() {
        self.setTheme()
        self.setUpSortView()
        database.observe(DataEventType.value, with: { (snapshot) in
            self.sortedArray = []
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                let postDict = snap.value as? NSDictionary
                let name = postDict?["name"] as? String ?? ""
                let location = postDict?["location"] as? String ?? ""
                let startDate = postDict?["startDate"] as? String ?? ""
                let duration = postDict?["duration"] as? Int ?? 0
                let organization = postDict?["organization"] as? String ?? ""
                let tags = postDict?["tags"] as? String ?? ""
                let imgid = postDict?["imgid"] as? String ?? ""
                let description = postDict?["description"] as? String ?? ""
                let event = Event(name: name, location: location, startDate: startDate, duration: duration, organization: organization, tags: tags, imgid: imgid, description: description)
                self.sortedArray.append(event)
            }
            group.notify(queue: .main, execute: {
                self.sortArray()
                self.tableView.reloadData()
                self.navigationController?.view.hideToastActivity()
                self.navigationController?.view.isUserInteractionEnabled = true
            })
        })
    }
    
    func createGestures(label: UILabel) {
        if options.count == 1 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap1(sender:)))
            label.addGestureRecognizer(gestureRecognizer)
        } else if options.count == 2 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap2(sender:)))
            label.addGestureRecognizer(gestureRecognizer)
        } else if options.count == 3 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap3(sender:)))
            label.addGestureRecognizer(gestureRecognizer)
        } else if options.count == 4 {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap4(sender:)))
            label.addGestureRecognizer(gestureRecognizer)
        }
        label.isUserInteractionEnabled = true
    }
    
    @objc func handleTap1(sender: UIGestureRecognizer) {
        handleOptionClick(option: options[0])
    }
    
    @objc func handleTap2(sender: UIGestureRecognizer) {
        handleOptionClick(option: options[1])
    }
    
    @objc func handleTap3(sender: UIGestureRecognizer) {
        handleOptionClick(option: options[2])
    }
    
    @objc func handleTap4(sender: UIGestureRecognizer) {
        handleOptionClick(option: options[3])
    }
    
    func handleOptionClick(option: Checkbox) {
        let index = self.options.firstIndex(of: option) ?? 0
        for option in options {
            option.isChecked = false
        }
        self.options[index].isChecked = true
        self.closeSortView()
        impact.impactOccurred()
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

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}
