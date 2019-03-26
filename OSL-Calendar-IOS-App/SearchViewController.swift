//
//  SearchViewController.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/26/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UITableViewController {
    
    let themeManager = ThemeManager()
    var sortedArray: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
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
        cell.textLabel?.text = event.getName()
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = Theme.sharedInstance.textColor
        cell.detailTextLabel?.textColor = Theme.sharedInstance.textColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View Will Appear: Search")
    }
    
    func getTheme() {
        let preferences = UserDefaults.standard
        if let theme = preferences.string(forKey: "theme") {
            themeManager.setInitialTheme(theme: theme)
        }
    }
    
}
