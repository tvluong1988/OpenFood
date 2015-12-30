//
//  Event.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import Foundation

/**
 *  Schema of Recall object for openFDA json data.
 */
struct RecallSchema {
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
  static let lastUpdated = "last_updated"
  
}

/// Recall object.
class Recall {
  
  // MARK: Lifecycle
  init(id: String) {
    self.id = id
  }
  
  // MARK: Properties
  /// Primary key of Recall object.
  let id: String
  /// Country of firm who initiated recall.
  var country: String?
  /// State of firm who initiated recall.
  var state: String?
  /// City of firm who inititated recall.
  var city: String?
  /// Detail description of recalled products.
  var productDescription: String?
  /// Current status of the recall investigation.
  var status: String?
  /// Classification of the recall.
  var classification: String?
  /// Date of when the firm initiated the investigation.
  var recallInitiationDate: NSDate?
  /// Reason for the recall.
  var reasonForRecall: String?
  /// Set of US states affected by the recall.
  var affectedStates: Set<USStateAbbreviation>?
  /// Date of when the recall began to take affect.
  var reportDate: NSDate?
  ///  Name of the recalling firm who initiated the recall investigation.
  var recallingFirm: String?
}



















