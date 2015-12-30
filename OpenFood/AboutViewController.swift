//
//  AboutViewController.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/30/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var lastUpdatedLabel: UILabel!
  
  // MARK: Actions
  @IBAction func removeAds(sender: UIButton) {
    NSNotificationCenter.defaultCenter().postNotificationName(Notification.removeAds, object: nil)
  }
  
  @IBAction func restorePurchases(sender: UIButton) {
    NSNotificationCenter.defaultCenter().postNotificationName(Notification.restorePurchases, object: nil)
  }
  
  @IBAction func rateApp(sender: UIButton) {
    NSNotificationCenter.defaultCenter().postNotificationName(Notification.rateApp, object: nil)
  }
  
  @IBAction func postTweet(sender: UIButton) {
    NSNotificationCenter.defaultCenter().postNotificationName(Notification.postTweet, object: nil)
  }
  
  @IBAction func postFacebook(sender: UIButton) {
    NSNotificationCenter.defaultCenter().postNotificationName(Notification.postFacebook, object: nil)
  }
  
  
  // MARK: Lifecycle
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if let metaInfo = metaInfo {
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateStyle = .MediumStyle
      let date = dateFormatter.stringFromDate(metaInfo.dateLastUpdated)
      
      lastUpdatedLabel.text = "Last updated: \(date)"
    }
    
  }
  
  // MARK: Properties
  /// Meta information to display.
  var metaInfo: MetaInfo?
}






















