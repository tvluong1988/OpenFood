//
//  Constants.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import Foundation
import ChameleonFramework

/**
 *  Important App information
 */
struct App {
  static let id = "1071420301"
  static let name = "Food Check: Search for Recall"
}

/**
 *  openFDA API information
 */
struct OpenFDAAPI {
  static let key     = "xmoLdqh4LzCDbAPMLhdxJmKIHhcLaR6eB32ohYUa"
  static let baseURL = "https://api.fda.gov/food/"
}

/**
 Sort recall information
 
 - Relevance: Sort by relevance to the user's search
 - Date:      Sort by date starting from latest
 */
enum SortOrder: String {
  case Relevance, Date
}

/**
 *  Notification keys
 */
struct Notification {
  static let rateApp = "RateApp"
  static let postFacebook = "PostFacebook"
  static let postTweet = "PostTweet"
  static let removeAds = "RemoveAds"
  static let restorePurchases = "RestorePurchases"
}

/**
 *  Image assets
 */
struct Image {
  static let shareApp = "ShareApp"
}

let barTintColor = FlatLimeDark()
let tintColor = FlatWhite()
let fontName = "Helvetica Neue"

let currentDevice = UIDevice.currentDevice().userInterfaceIdiom

























