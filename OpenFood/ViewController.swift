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
    
    let format = EventSchema.dateFormat
    if dateString == "nil" {
      return nil
    } else {
      
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = format
      return dateFormatter.dateFromString(dateString)
    }
  }
  
  func downloadAndUpdate(searchString: String, skip: Int) {
    
    activityIndicator.startAnimating()
    loadingData = true
    
    let enforcementJSON = "enforcement.json?"
    let apiKey = "api_key=" + OpenFDAAPI.key
    let limitAndSkip = "&limit=25&skip=\(skip)"
    let search = "&search=\(searchString)"
    
    var url = OpenFDAAPI.baseURL
    url += enforcementJSON
    url += apiKey
    url += limitAndSkip
    url += search
    
    Alamofire.request(.GET, url).responseJSON {
      response in
      
      print("Result: " + response.result.description)
      //      print(response.result.value!)
      
      guard let data = response.result.value else {
        return
      }
      
      let json = JSON(data)
      
      let resultsJSON = json["results"]
      
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
    event.reasonForRecall = json[EventSchema.reasonForRecall].string
    
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
    downloadAndUpdate("", skip: eventsManager.eventsCount())
    refreshControl.endRefreshing()
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Events"
    
    eventsManager = EventsManager()
    
    activityIndicator.hidesWhenStopped = true
    
    searchController = UISearchController(searchResultsController: nil)
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    
    let searchBar = searchController.searchBar
    searchBar.scopeButtonTitles = ["Relevance", "Date"]
    searchBar.showsScopeBar = false
    searchBar.delegate = self
    searchBar.sizeToFit()
    
    tableView.tableHeaderView = searchController.searchBar
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: .ValueChanged)
    
    refreshControl.tintColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    
    tableView.addSubview(refreshControl)
    
  }
  
  // MARK: Properties
  var eventsManager: EventsManager!
  var filteredEvents = [Event]()
  var loadingData = false
  var searchController: UISearchController!
  var searchText = ""
  
  var refreshControl: UIRefreshControl!
  
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return eventsManager.eventsCount()
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! EventTableViewCell
    
    let searchBar = searchController.searchBar
    let scopeBarTitle = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
    
    switch scopeBarTitle {
    case "Relevance":
      cell.event = eventsManager.eventsSortedByRelevance[indexPath.row]
    case "Date":
      cell.event = eventsManager.eventsSortedByDate[indexPath.row]
    default: break
    }
    
    cell.textLabel?.text = cell.event?.productDescription
    
    return cell
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let eventsCount = eventsManager.eventsCount()
    
    if !loadingData && indexPath.row == eventsCount - 1 && eventsCount > 2 {
      downloadAndUpdate(searchText, skip: eventsCount)
    }
  }
  
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    print(searchController.searchBar.text)
    
    if let searchText = searchController.searchBar.text where searchText.isEmpty == false {
      eventsManager.removeAllEvents()
      
      self.searchText = searchText
      downloadAndUpdate(searchText, skip: eventsManager.eventsCount())
    }
  }
  
  func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    tableView.reloadData()
  }
}









































