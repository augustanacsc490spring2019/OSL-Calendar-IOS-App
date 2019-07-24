//
//  SearchViewController.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/26/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//
//  The find events/search tab for the application, takes you to the event view controller when an event is tapped
//
//  https://www.natashatherobot.com/custom-uitableviewcell-selection-style-color/

import Foundation
import UIKit
import Firebase
import SimpleCheckbox
import Toast_Swift

// Impact generator for haptic feedback
let impact = UIImpactFeedbackGenerator()

// Protocol for getting the event in the detailed event view controller
protocol DisplayEvent {
    func getEvent(event: Event)
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, Return {
    
    
    @IBOutlet weak var startSearchButton: UIButton!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var weekTraversalBar: UINavigationBar!
    @IBOutlet weak var currentWeekLabel: UINavigationItem!
    @IBOutlet weak var prevWeekButton: UIButton!
    @IBOutlet weak var nextWeekButton: UIButton!
    let themeManager = ThemeManager()
    var sortedArray: [Event] = []
    var filteredEvents: [Event] = []
    var dateFilteredEvents: [Event] = []
    var database: DatabaseReference!
    var fixedHeightOfLabel: CGFloat = 45
    var index: Double = 0.6
    var labels: [UILabel] = []
    var isDown = true
    var sortView = UIView()
    var options: [Checkbox] = []
    var firstSort = true
    var eventController = EventViewController()
    var isEvent = false
    let searchController = UISearchController(searchResultsController: nil)
    var dateFilter = WeeklyDateFilter(currentDate: Date())
    var favoriteFilter = MyEventsFilter(user: "")
    var searchFilter = SearchMultiFieldFilter(query: "")
    var user : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Auth.auth().currentUser
        let separated = email?.email?.split(separator: "@")
        user = String(separated!.first!)
        favoriteFilter = MyEventsFilter(user: user)
        self.navigationController?.view.isUserInteractionEnabled = false
        self.navigationController?.view.makeToastActivity(.center)
        tableView.register(EventCell.self, forCellReuseIdentifier: "cellIdentifier")
        definesPresentationContext = true
        getTheme()
        database = Database.database().reference().child("current-events")
        databaseListener()
        setUpSearchBar()
        let font = UIFont(name: "Helvetica", size: 15)
        weekTraversalBar.titleTextAttributes = [NSAttributedString.Key.font: font!]
        nextWeekButton.addTarget(self, action: Selector(("nextWeekButtonClicked")), for: .touchUpInside)
        prevWeekButton.addTarget(self, action: Selector(("prevWeekButtonClicked")), for: .touchUpInside)
        startSearchButton.addTarget(self, action: Selector(("startSearch")), for: .touchUpInside)
        prevWeekButton.isEnabled = false
    }
    
    func filter() {
        if (self.tabBarController?.selectedIndex == 0 && !isFiltering()) {
            weekTraversalBar.isHidden = false
            dateFilter.setEnabled(enabled: true)
            favoriteFilter.setEnabled(enabled: false)
        } else if (self.tabBarController?.selectedIndex == 1 && !isFiltering()) {
            weekTraversalBar.isHidden = true
            dateFilter.setEnabled(enabled: false)
            favoriteFilter.setEnabled(enabled: true)
        }
        filteredEvents.removeAll()
        for event in sortedArray {
            if (dateFilter.applyFilter(event: event) && favoriteFilter.applyFilter(event: event) && searchFilter.applyFilter(event: event)) {
                filteredEvents.append(event)
            }
        }
        currentWeekLabel.title = dateFilter.getCurrentWeekLabel()
        if (searchFilter.isEnabled()) {
            weekTraversalBar.isHidden = true
        }
        tableView.reloadData()
    }
    
    // Number of sections in the table
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    // Number of rows in the table, changes if filtering is active
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredEvents.count
        }
        return filteredEvents.count
    }
    
    // Construct the table cells, different when filtering is active
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! EventCell
        
        let event: Event
        if isFiltering() {
            event = filteredEvents[indexPath.row]
        } else {
            event = filteredEvents[indexPath.row]
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
    
    // Action for clicking a row in the table view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isEvent = true
        let event: Event
        if isFiltering() {
            print("filtered")
            event = filteredEvents[indexPath.row]
            if (searchController.isActive) {
                searchController.dismiss(animated: false) {
                    self.presentEvent(event: event)
                }
            } else {
                presentEvent(event: event)
            }
        } else {
            event = filteredEvents[indexPath.row]
            if (searchController.isActive) {
                searchController.dismiss(animated: false) {
                    self.presentEvent(event: event)
                }
            } else {
                presentEvent(event: event)
            }
        }
    }
    
    // Present detailed event view controller
    func presentEvent(event: Event) {
        print("presenting event")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        eventController = self.storyboard?.instantiateViewController(withIdentifier: "event") as? EventViewController ?? EventViewController()
        eventController.delegate = self
        self.eventController.getEvent(event: event)
        let navigationController = UINavigationController(rootViewController: eventController)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // View will appear, pass to detailed event view when it is presented
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View Will Appear: Search")
        if (isEvent == true) {
            eventController.viewWillAppear(animated)
        }
        setTheme()
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // View did appear, hide search bar when scrolling
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        filter()
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    // Method called when returning from detailed event view
    func returnFromEventView() {
        isEvent = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.setNeedsLayout()
        tableView.reloadData()
    }
    
    // Set up the search bar
    func setUpSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        searchController.hidesNavigationBarDuringPresentation = true
//        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        
    }
    
    // Returns true when the search bar is empty
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // Filter the search bar content on name, location, organization, and tags
    //TODO: May need to make SearchMultiFieldFilter in addition to MyEventsFilter
    //          See if this really needs to be done (but you probably should)
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if (searchText.count >= 3) {
            weekTraversalBar.isHidden = true
            searchFilter = SearchMultiFieldFilter(query: searchText.lowercased())
            searchFilter.setEnabled(enabled: true)
            dateFilter.setEnabled(enabled: false)
            filter()
        } else {
            filter()
        }
        tableView.reloadData()
    }
    
    // Returns true filtering is active
    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }
    
    // Action for pressing the cancel button in the search bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Search is cancelled")
        searchFilter.setEnabled(enabled: false)
        weekTraversalBar.isHidden = false
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        navigationItem.searchController = nil
        //filterContentForSearchText("")
    }
    
    @IBAction func startSearch() {
        navigationItem.searchController = searchController
        searchController.isActive = true
    }
    
    // Sort the table based on the selected sort type
    func sortArray() {
        if (isFiltering()){
            self.filterContentForSearchText(searchController.searchBar.text!)
        }
        tableView.reloadData()
    }
    
    // Listener for the current events in the database
    func databaseListener() {
        self.setTheme()
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
                let favoritedBy = postDict?["favoritedBy"] as? Dictionary<String, Bool> ?? [:]
                let webLink = postDict?["webLink"] as? String ?? ""
                let event = Event(name: name, location: location, startDate: startDate, duration: duration, organization: organization, tags: tags, imgid: imgid, description: description, favoritedBy: favoritedBy, webLink: webLink)
                event.setEventID(eventID: snap.key)
                self.sortedArray.append(event)
            }
            group.notify(queue: .main, execute: {
                self.sortArray()
                self.filter()
                self.tableView.reloadData()
                self.navigationController?.view.hideToastActivity()
                self.navigationController?.view.isUserInteractionEnabled = true
            })
        })
    }
    
    @IBAction func nextWeekButtonClicked() {
        dateFilter.moveToNextWeek()
        prevWeekButton.isEnabled = !dateFilter.isFilteringCurrentWeek()
        filter()
    }
    
    @IBAction func prevWeekButtonClicked() {
        dateFilter.moveToPreviousWeek()
        prevWeekButton.isEnabled = !dateFilter.isFilteringCurrentWeek()
        filter()
    }
    
    // Sets the theme of the view controller
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
    
    // Sets the text colors of the view controller
    func setTextColors() {
        for label in labels {
            label.textColor = Theme.sharedInstance.textColor
        }
    }
    
    // Sets the radio option colors of the sort view
    func setOptionColors() {
        for option in options {
            option.checkboxBackgroundColor = Theme.sharedInstance.checkboxBackground
            option.checkedBorderColor = Theme.sharedInstance.checkboxColor
            option.uncheckedBorderColor = Theme.sharedInstance.checkboxColor
            option.checkmarkColor = Theme.sharedInstance.checkboxColor
            option.setNeedsDisplay()
        }
    }
    
    // Gets the initial theme saved to the device
    func getTheme() {
        let preferences = UserDefaults.standard
        if let theme = preferences.string(forKey: "theme") {
            themeManager.setInitialTheme(theme: theme)
        } else {
            themeManager.setInitialTheme(theme: "augie")
        }
    }
    
}

// Extension for filtering using the search bar
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if (searchController.isActive) {
            searchFilter.setEnabled(enabled: true)
        } else {
            searchFilter.setEnabled(enabled: false)
        }
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}
