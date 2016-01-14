//
//  ViewController.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import iAd
import UIKit
import Alamofire
import SwiftyJSON
import ChameleonFramework
import DZNEmptyDataSet

class ViewController: UIViewController {
  
  // MARK: Segues
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowDetail", let detailVC = segue.destinationViewController as? DetailViewController, let sender = sender as? RecallTableViewCell {
      
      detailVC.recall = sender.recall
    }
    
    if segue.identifier == "ShowAbout", let aboutVC = segue.destinationViewController as? AboutViewController {
      aboutVC.metaInfo = metaInfo
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
      dateFormatter.dateFormat = RecallSchema.dateFormat
      return dateFormatter.dateFromString(dateString)
    }
  }
  
  /**
   Retrieve a url formatted for openFDA.
   
   - parameter search: user search text
   - parameter skip:   offset of results
   
   - returns: formatted url
   */
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
  
  /**
   Send HTTP request with search text and skip parameter to openFDA.
   
   - parameter search: user search text
   - parameter skip:   offset of results
   */
  func downloadAndUpdate(search: String, skip: Int) {
    
    activityIndicator.startAnimating()
    loadingData = true
    searchResultsTotal = 0
    
    let url = getURL(search, skip: skip)
    
    Alamofire.request(.GET, url).responseJSON {
      response in
      
      guard response.result.description == "SUCCESS" else {
        return
      }
      
      guard let data = response.result.value else {
        return
      }
      
//      print(response)
      
      
      let json = JSON(data)
      
      if let errorCode = json["error"]["code"].string where errorCode == "NOT_FOUND", let message = json["error"]["message"].string {
        showAlert(message, target: self)
      }
      
      let metaJSON = json["meta"]
      if let dateString = metaJSON[RecallSchema.lastUpdated].string {
        let formattedDateString = dateString.stringByReplacingOccurrencesOfString("-", withString: "")
        if let date = self.convertStringToDate(formattedDateString) {
          self.metaInfo = MetaInfo(dateLastUpdated: date)
        }
      }
      
      if let totals = metaJSON["results"]["total"].int {
        self.searchResultsTotal = totals
      }
      
      
      let resultsJSON = json["results"]
      for (_, item) in resultsJSON {
        //        print(item)
        
        guard item[RecallSchema.id].string != nil  else {
          continue
        }
        
        self.recallManager.addRecall(self.extractRecallFromJSON(item))
      }
      
      self.tableView.reloadData()
      self.activityIndicator.stopAnimating()
      self.loadingData = false
    }
  }
  
  /**
   Extract the json and construct a Recall object to hold all the relevant information.
   
   - parameter json: json recall item
   
   - returns: Recall object
   */
  func extractRecallFromJSON(json: JSON) -> Recall {
    
    let recall = Recall(id: json[RecallSchema.id].string!)
    
    recall.city = json[RecallSchema.city].string
    recall.state = json[RecallSchema.state].string
    recall.country = json[RecallSchema.country].string
    recall.classificationString = json[RecallSchema.classification].string
    recall.statusString = json[RecallSchema.status].string
    recall.productDescription = json[RecallSchema.productDescription].string
    
    recall.recallInitiationDate = convertStringToDate(json[RecallSchema.recallInitiationDate].string!)
    recall.reportDate = convertStringToDate(json[RecallSchema.reportDate].string!)
    
    recall.reasonForRecall = json[RecallSchema.reasonForRecall].string
    recall.recallingFirm = json[RecallSchema.recallingFirm].string
    
    let locations = json[RecallSchema.affectedStates].string
    var states = Set<USStateAbbreviation>()
    
    for state in USStateAbbreviation.all51States {
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
    
    recall.affectedStates = states
    
    return recall
  }
  
  /**
   User pull down refresh to get latest recall information.
   
   - parameter refreshControl: refreshControl
   */
  func handleRefresh(refreshControl: UIRefreshControl) {
    
    refreshControl.endRefreshing()
    guard case .Online(_) = Reach.connectionStatus() else {
      
      showAlert("No Internet connection", target: self)
      return
    }
    
    recallManager.removeAllRecall()
    getLatestUpdates()
  }
  
  /**
   Request openFDA for latest recall information and update tableview.
   */
  func getLatestUpdates() {
    
    let today = NSDate(timeIntervalSinceNow: 0)
    let secondsIn3Months: NSTimeInterval = 60*60*24*120
    let date3MonthsAgo = today.dateByAddingTimeInterval(-secondsIn3Months)
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = RecallSchema.dateFormat
    
    let dateRange = "report_date:[\(dateFormatter.stringFromDate(date3MonthsAgo))+TO+\(dateFormatter.stringFromDate(today))]"
    
    searchText = dateRange
    
    downloadAndUpdate(searchText, skip: recallManager.getRecallCount())
    
    searchBar(searchController.searchBar, selectedScopeButtonIndexDidChange: 1)
    
    navigationItem.title = "Lastest Recall"
    
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.hidesNavigationBarHairline = true
    
    recallManager = RecallManager()
    
    activityIndicator.hidesWhenStopped = true
    
    searchController = UISearchController(searchResultsController: nil)
    searchController.dimsBackgroundDuringPresentation = true
    definesPresentationContext = true
    
    let searchBar = searchController.searchBar
    searchBar.barTintColor = barTintColor
    
    let colors = NSArray(ofColorsWithColorScheme: .Triadic, with: barTintColor, flatScheme: true)
    
    let color = colors[0] as! UIColor
    
    searchBar.tintColor = color
    
    
    searchBar.setScopeBarButtonTitleTextAttributes([NSForegroundColorAttributeName : UIColor.flatWhiteColor()], forState: UIControlState.Normal)
    searchBar.setScopeBarButtonTitleTextAttributes([NSForegroundColorAttributeName : UIColor.flatWhiteColor()], forState: UIControlState.Selected)
    
    
    searchBar.scopeButtonTitles = [SortOrder.Relevance.rawValue, SortOrder.Date.rawValue]
    searchBar.showsScopeBar = false
    searchBar.delegate = self
    searchBar.sizeToFit()
    
    tableView.tableHeaderView = searchController.searchBar
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: .ValueChanged)
    
    refreshControl.tintColor = UIColor.flatBlueColorDark()
    refreshControl.attributedTitle = NSAttributedString(string: "Pull for latest recalls")
    
    tableView.addSubview(refreshControl)
    
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    
    
    let isPaid = Product.store.isProductPurchased(Product.RemoveAds)
    canDisplayBannerAds = !isPaid
    
    guard case .Online(_) = Reach.connectionStatus() else {
      navigationItem.title = "Recalls"
      return
    }
    
    getLatestUpdates()
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if canDisplayBannerAds {
      adBannerView = getAppDelegate().adBannerView
      adBannerView.delegate = self
      
      view.addSubview(adBannerView)
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
    if canDisplayBannerAds {
      adBannerView.delegate = nil
      adBannerView.removeFromSuperview()
    }
  }
  
  // MARK: Properties
  var recallManager: RecallManager!
  /// Is currently getting new data?
  var loadingData = false
  var searchController: UISearchController!
  /// User search criteria.
  var searchText = ""
  /// Total number of records matching the search criteria.
  var searchResultsTotal = 0
  var refreshControl2: UIRefreshControl!
  /// Meta information from openFDA.
  var metaInfo: MetaInfo?
  var adBannerView: ADBannerView!
  var refreshControl: UIRefreshControl!
  
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recallManager.getRecallCount()
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! RecallTableViewCell
    
    cell.recall = recallManager.getRecallAtIndex(indexPath.row)
    
    cell.textLabel?.text = cell.recall?.productDescription
    
    switch currentDevice {
    case .Pad:
      cell.textLabel?.font = UIFont(name: fontName, size: 30)
    default:
      cell.textLabel?.font = UIFont(name: fontName, size: 16)
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    let recallCount = recallManager.getRecallCount()
    
    if !loadingData && indexPath.row == recallCount - 1 && recallCount > 2 && recallCount < searchResultsTotal {
      
      guard case .Online(_) = Reach.connectionStatus() else {
        showAlert("No Internet connection", target: self)
        return
      }
      
      downloadAndUpdate(searchText, skip: recallCount)
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
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
      
      guard case .Online(_) = Reach.connectionStatus() else {
        
        showAlert("No Internet connection", target: self)
        return
      }
      
      recallManager.removeAllRecall()
      
      self.searchText = searchText
      downloadAndUpdate(searchText, skip: recallManager.getRecallCount())
      
      navigationItem.title = searchText
    }
  }
  
  func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    switch selectedScope {
    case 0: recallManager.sortMode = .Relevance
    case 1: recallManager.sortMode = .Date
    default: break
    }
    
    searchController.searchBar.selectedScopeButtonIndex = selectedScope
    
    tableView.reloadData()
  }
}

// MARK: - ADBannerViewDelegate
extension ViewController: ADBannerViewDelegate {
  func bannerViewDidLoadAd(banner: ADBannerView!) {
    adBannerView.hidden = false
  }
  
  func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
    adBannerView.hidden = true
  }
}

// MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension ViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
  func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let text = ""
    let attributes: [String: AnyObject] = [NSFontAttributeName: UIFont(name: fontName, size: 20)!, NSForegroundColorAttributeName: FlatRedDark()]
    
    return NSAttributedString(string: text, attributes: attributes)
  }
  
  func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
    return FlatWhite()
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let text = "There doesn't seem to be anything here."
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .ByWordWrapping
    paragraphStyle.alignment = .Center
    
    var fontSize: CGFloat = 12
    switch currentDevice {
    case .Pad:
      fontSize = 30
    default: break
    }
    
    let attributes: [String: AnyObject] = [NSFontAttributeName: UIFont(name: fontName, size: fontSize)!, NSForegroundColorAttributeName: FlatRed(), NSParagraphStyleAttributeName: paragraphStyle]
    
    return NSAttributedString(string: text, attributes: attributes)
  }
  
  func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
    return true
  }
}




































