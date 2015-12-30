//
//  Event.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import Foundation

struct EventSchema {
  static let dateFormat = "yyyyMMdd"
  
  static let id = "event_id"
  static let country = "country"
  static let state = "state"
  static let city = "city"
  static let productDescription = "product_description"
  static let status = "status"
  static let classification = "classification"
  static let recallInitiationDate = "recall_initiation_date"
  static let affectedStates = "distribution_pattern"
  static let reasonForRecall = "reason_for_recall"
  static let reportDate = "report_date"
  static let recallingFirm = "recalling_firm"
  
}

class Event {
  
  // MARK: Lifecycle
  init(id: String) {
    self.id = id
  }
  
  // MARK: Properties
  let id: String
  var country: String?
  var state: String?
  var city: String?
  var productDescription: String?
  var status: String?
  var classification: String?
  var recallInitiationDate: NSDate?
  var reasonForRecall: String?
  var affectedStates: Set<USStateAbbreviation>?
  var reportDate: NSDate?
  var recallingFirm: String?
}