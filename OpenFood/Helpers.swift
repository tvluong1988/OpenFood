//
//  Helpers.swift
//  Todo
//
//  Created by Thinh Luong on 12/18/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import UIKit

func getAppDelegate() -> AppDelegate {
  return UIApplication.sharedApplication().delegate as! AppDelegate
}

/**
 Add and show an activity indicator onscreen.
 */
func showActivityIndicator(indicator: UIActivityIndicatorView?) {
  indicator?.hidden = false
  indicator?.startAnimating()
}

/**
 Hide and remove an activity indicator.
 */
func hideActivityIndicator(indicator: UIActivityIndicatorView?) {
  indicator?.stopAnimating()
  indicator?.hidden = true
}

/**
 Create and show AlertView
 
 - parameter message: Message to display to user.
 */
func showAlert(message: String, target: UIViewController) {
  let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
  let okButton = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
  alert.addAction(okButton)
  
  target.presentViewController(alert, animated: true, completion: nil)
}
