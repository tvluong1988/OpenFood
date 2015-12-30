//
//  ViewController.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
  
  // MARK: Segues
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowDetail", let detailVC = segue.destinationViewController as? DetailViewController, let sender = sender as? EventTableViewCell {
      detailVC.event = sender.event
    }
  }
  
  // MARK: Outlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // MARK: Functions
  /**
  Convert a string into a NSDate.
  
  - parameter dateString: date of type String
  
  - returns: date of type NSDate
  */
  func convertStringToDate(dateString: String) -> NSDate? {
    
    if dateString == "nil" {
      return nil
    } else {
      
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = EventSchema.dateFormat
      return dateFormatter.dateFromString(dateString)
    }
  }
  
  func getURL(search: String, skip: Int) -> String {
    let enforcementJSON = "enforcement.json?"
    let apiKey = "api_key=" + OpenFDAAPI.key
    let limitAndSkip = "&limit=25&skip=\(skip)"
    let searchString = "&search=\(search.stringByReplacingOccurrencesOfString(" ", withString: "+"))"
    
    var url = OpenFDAAPI.baseURL
    url += enforcementJSON
    url += apiKey
    url += limitAndSkip
    url += searchString
    
    return url
  }
  
  func downloadAndUpdate(search: String, skip: Int) {
    
    activityIndicator.startAnimating()
    loadingData = true
    searchResultsTotal = 0
    
    let url = getURL(search, skip: skip)
    
    Alamofire.request(.GET, url).responseJSON {
      response in
      
      print("Result: " + response.result.description)
      //      print(response.result.value!)
      
      guard let data = response.result.value else {
        return
      }
      
      let json = JSON(data)
      
      let resultsJSON = json["results"]
      let metaJSON = json["meta"]
      if let totals = metaJSON["results"]["total"].int {
        self.searchResultsTotal = totals
      }
      //      print(metaJSON)
      //      print(self.searchResultsTotal)
      
      for (_, item) in resultsJSON {
        print(item)
        
        guard item[EventSchema.id].string != nil  else {
          continue
        }
        
        self.eventsManager.addEvent(self.extractEventFromJSON(item))
      }
      
      self.tableView.reloadData()
      self.activityIndicator.stopAnimating()
      self.loadingData = false
    }
  }
  
  func extractEventFromJSON(json: JSON) -> Event {
    
    let event = Event(id: json[EventSchema.id].string!)
    
    event.city = json[EventSchema.city].string
    event.state = json[EventSchema.state].string
    event.country = json[EventSchema.country].string
    event.classification = json[EventSchema.classification].string
    event.status = json[EventSchema.status].string
    event.productDescription = json[EventSchema.productDescription].string
    
    event.recallInitiationDate = self.convertStringToDate(json[EventSchema.recallInitiationDate].string!)
    event.reportDate = self.convertStringToDate(json[EventSchema.reportDate].string!)
    
    event.reasonForRecall = json[EventSchema.reasonForRecall].string
    event.recallingFirm = json[EventSchema.recallingFirm].string
    
    let locations = json[EventSchema.affectedStates].string
    var states = Set<USStateAbbreviation>()
    
    for state in USStateAbbreviation.allValues {
      if locations!.containsString(state.rawValue) {
        states.insert(state)
      }
    }
    
    for state in USStateFullName.allValues {
      if locations!.lowercaseString.containsString(state.rawValue.lowercaseString) {
        states.insert(convertUSStateFullNameToAbbreviation(state))
      }
    }
    
    if states.contains(.Nationwide) && states.count > 1 {
      states.remove(.Nationwide)
    }
    
    event.affectedStates = states
    
    return event
  }
  
  func handleRefresh(refreshControl: UIRefreshControl) {
    eventsManager.removeAllEvents()
    getLatestUpdates()
    refreshControl.endRefreshing()
  }
  
  func getLatestUpdates() {
    
    let today = NSDate(timeIntervalSinceNow: 0)
    let secondsIn3Months: NSTimeInterval = 60*60*24*120
    let date3MonthsAgo = today.dateByAddingTimeInterval(-secondsIn3Months)
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = EventSchema.dateFormat
    
    let dateRange = "report_date:[\(dateFormatter.stringFromDate(date3MonthsAgo))+TO+\(dateFormatter.stringFromDate(today))]"
    
    searchText = dateRange
    
    downloadAndUpdate(searchText, skip: eventsManager.getEventsCount())
    
    searchBar(searchController.searchBar, selectedScopeButtonIndexDidChange: 1)
    
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Events"
    
    eventsManager = EventsManager()
    
    activityIndicator.hidesWhenStopped = true
    
    searchController = UISearchController(searchResultsController: nil)
    searchController.dimsBackgroundDuringPresentation = true
    definesPresentationContext = true
    
    let searchBar = searchController.searchBar
    searchBar.scopeButtonTitles = [SortOrder.Relevance.rawValue, SortOrder.Date.rawValue]
    searchBar.showsScopeBar = false
    searchBar.delegate = self
    searchBar.sizeToFit()
    
    tableView.tableHeaderView = searchController.searchBar
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: .ValueChanged)
    
    refreshControl.tintColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
    refreshControl.attributedTitle = NSAttributedString(string: "Pull for latest")
    
    tableView.addSubview(refreshControl)
    
  }
  
  // MARK: Properties
  var eventsManager: EventsManager!
  var filteredEvents = [Event]()
  var loadingData = false
  var searchController: UISearchController!
  var searchText = ""
  var searchResultsTotal = 0
  
  var refreshControl: UIRefreshControl!
  
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return eventsManager.getEventsCount()
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! EventTableViewCell
    
    cell.event = eventsManager.getEventAtIndex(indexPath.row)
    
    cell.textLabel?.text = cell.event?.productDescription
    
    return cell
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let eventsCount = eventsManager.getEventsCount()
    
    if !loadingData && indexPath.row == eventsCount - 1 && eventsCount > 2 && eventsCount < searchResultsTotal {
      downloadAndUpdate(searchText, skip: eventsCount)
    }
  }
  
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
  
  func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
    tableView.userInteractionEnabled = false
    return true
  }
  
  func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
    tableView.userInteractionEnabled = true
    return true
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    
    if let searchText = searchController.searchBar.text where !searchText.isEmpty {
      eventsManager.removeAllEvents()
      
      self.searchText = searchText
      downloadAndUpdate(searchText, skip: eventsManager.getEventsCount())
      
    }
  }
  
  func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    switch selectedScope {
    case 0: eventsManager.sortMode = .Relevance
    case 1: eventsManager.sortMode = .Date
    default: break
    }
    
    searchController.searchBar.selectedScopeButtonIndex = selectedScope
    
    tableView.reloadData()
  }
}









































