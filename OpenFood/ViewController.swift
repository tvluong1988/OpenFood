//
//  ViewController.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import Social
import iAd
import StoreKit
import UIKit
import Alamofire
import SwiftyJSON

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
   - parameter skip:   number of previous item to skip
   
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
   - parameter skip:   number of previous item to skip
   */
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
      print(metaJSON)
      //            print(self.searchResultsTotal)
      
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
    recall.classification = json[RecallSchema.classification].string
    recall.status = json[RecallSchema.status].string
    recall.productDescription = json[RecallSchema.productDescription].string
    
    recall.recallInitiationDate = convertStringToDate(json[RecallSchema.recallInitiationDate].string!)
    recall.reportDate = convertStringToDate(json[RecallSchema.reportDate].string!)
    
    recall.reasonForRecall = json[RecallSchema.reasonForRecall].string
    recall.recallingFirm = json[RecallSchema.recallingFirm].string
    
    let locations = json[RecallSchema.affectedStates].string
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
    
    recall.affectedStates = states
    
    return recall
  }
  
  /**
   User pull down refresh to get latest recall information.
   
   - parameter refreshControl: refreshControl
   */
  func handleRefresh(refreshControl: UIRefreshControl) {
    recallManager.removeAllRecall()
    getLatestUpdates()
    refreshControl.endRefreshing()
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
    
    recallManager = RecallManager()
    
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
    refreshControl.attributedTitle = NSAttributedString(string: "Pull for latest recalls")
    
    tableView.addSubview(refreshControl)
    
    loadNotifications()
    
    loadProductStore()
    
    isPaid = Product.store.isProductPurchased(Product.RemoveAds)
    canDisplayBannerAds = !isPaid
    
    getLatestUpdates()
    
  }
  
  // MARK: Properties
  var recallManager: RecallManager!
  /// Is currently getting new data?
  var loadingData = false
  var searchController: UISearchController!
  /// User search text.
  var searchText = ""
  /// Total count of search results.
  var searchResultsTotal = 0
  var refreshControl: UIRefreshControl!
  /// Meta information from openFDA.
  var metaInfo: MetaInfo?
  /// Has the user paid to remove iAds?
  var isPaid = false
  /// IAP products
  var products = [SKProduct]()
  
  
}

// MARK: - IAP and Notifications
extension ViewController {
  /**
   Initialize the Product store to handle IAP.
   */
  private func loadProductStore() {
    
    Product.store.requestProductsWithCompletionHandler {
      success, products in
      
      if success {
        self.products = products
        print("Success, products: \(self.products)")
      } else {
        print("failed")
      }
    }
  }
  
  /**
   Initialize notifications: Facebook, Twitter, App Store, Restore Purchases, Remove Ads.
   */
  private func loadNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showFacebook", name: Notification.postFacebook, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showTwitter", name: Notification.postTweet, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAppStore", name: Notification.rateApp, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeAds", name: Notification.removeAds, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "restorePurchases", name: Notification.restorePurchases, object: nil)
  }
  
  /**
   Update and process IAP purchases.
   
   - parameter notification: notification with productIdentifier
   */
  func productPurchased(notification: NSNotification) {
    if let productIdentifier = notification.object as? String {
      for product in products {
        if product.productIdentifier == productIdentifier {
          canDisplayBannerAds = false
          isPaid = true
        }
      }
    }
  }
  
  /**
   Show Facebook compost view.
   */
  func showFacebook() {
    
    // Check if Facebook is available
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
      
      // Create the post
      let post = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
      post.title = App.name
      post.addImage(UIImage(named: Image.shareApp))
      presentViewController(post, animated: true, completion: nil)
      
    } else {
      
      // Facebook is not available. Show a warning.
      let alert = UIAlertController(title: "Facebook Unavailable", message: "User is not signed in", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  /**
   Show Twitter compost view.
   */
  func showTwitter() {
    
    // Check if Twitter is available
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      
      // Create the tweet
      let tweet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      tweet.setInitialText("I want to share this fun game: \(App.name)")
      tweet.addURL(NSURL(string: "https://itunes.apple.com/app/id\(App.id)"))
      tweet.addImage(UIImage(named: Image.shareApp))
      
      presentViewController(tweet, animated: true, completion: nil)
      
    } else {
      
      // Twitter not available. Show a warning.
      let alert = UIAlertController(title: "Twitter Unavailable", message: "User is not signed in", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  /**
   Open link to app on App Store for rating and review.
   */
  func showAppStore() {
    
    let alert = UIAlertController(title: "Rate App", message: nil, preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "Rate", style: .Default){
      _ in
      // Open App in AppStore
      let link = "https://itunes.apple.com/app/id\(App.id)"
      
      UIApplication.sharedApplication().openURL(NSURL(string: link)!)
      })
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
    
  }
  
  /**
   Initiate IAP purchase to remove iAds.
   */
  func removeAds() {
    if let product = products.first {
      Product.store.purchaseProduct(product)
    }
  }
  
  /**
   Initiate IAP restore purchases.
   */
  func restorePurchases() {
    Product.store.restoreCompletedTransactions()
  }
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
    
    return cell
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let recallCount = recallManager.getRecallCount()
    
    if !loadingData && indexPath.row == recallCount - 1 && recallCount > 2 && recallCount < searchResultsTotal {
      downloadAndUpdate(searchText, skip: recallCount)
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









































