//
//  AppDelegate.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import iAd
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var adBannerView = ADBannerView(adType: .Banner)
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    
    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    
    
    UINavigationBar.appearance().barTintColor = barTintColor
    UINavigationBar.appearance().tintColor = tintColor
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor(contrastingBlackOrWhiteColorOn: barTintColor, isFlat: true)]
    
    
    return true
  }
}















