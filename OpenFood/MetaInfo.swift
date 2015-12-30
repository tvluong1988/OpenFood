//
//  MetaInfo.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/28/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import Foundation

/**
 *  Meta information from openFDA
 */
struct MetaInfo {
  static let license = "http://open.fda.gov/license"
  static let disclaimer = "openFDA is a beta research project and not for clinical use. While we make every effort to ensure that data is accurate, you should assume all results are unvalidated."
  
  let dateLastUpdated: NSDate
  
}