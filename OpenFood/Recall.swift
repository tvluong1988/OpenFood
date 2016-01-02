//
//  Event.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import Foundation
import ChameleonFramework

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
class Recall: Equatable {
  
  /**
   Status of the recall investigation.
   
   - Ongoing:    A recall which is currently in progress.
   - Completed:  The recall action reaches the point at which the firm has actually retrieved and impounded all outstanding product that could reasonably be expected to be recovered, or has completed all product corrections.
   - Pending:    Actions that have been determined to be recalls, but that remain in the process of being classified.
   - Terminated: FDA has determined that all reasonable efforts have been made to remove or correct the violative product in accordance with the recall strategy, and proper disposition has been made according to the degree of hazard.
   */
  enum Status: String {
    case Ongoing, Completed, Pending, Terminated
    
    func getBackgroundColor() -> UIColor {
      switch self {
      case .Ongoing: return FlatOrange()
      case .Completed: return FlatGreen()
      case .Pending: return FlatYellow()
      case .Terminated: return FlatGray()
      }
    }
  }
  
  /**
   Recalls are classified into three categories.
   
   - Class1: Class I, a dangerous or defective product that predictably could cause serious health problems or death.
   - Class2: Class II, meaning that the product might cause a temporary health problem, or pose only a slight threat of a serious nature.
   - Class3: Class III, a product that is unlikely to cause any adverse health reaction, but that violates FDA labeling or manufacturing laws.
   */
  enum Classification: String {
    case Class1 = "Class I"
    case Class2 = "Class II"
    case Class3 = "Class III"
    
    func getBackgroundColor() -> UIColor {
      switch self {
      case .Class1: return FlatRed()
      case .Class2: return FlatOrange()
      case .Class3: return FlatYellow()
      }
    }
  }
  
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
  var statusString: String?
  /// Classification of the recall.
  var classificationString: String?
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
  
  var classification: Classification? {
    get {
      if let rawValue = classificationString, let classification = Classification(rawValue: rawValue) {
        return classification
      } else {
        return nil
      }
    }
  }
  
  var status: Status? {
    get {
      if let rawValue = statusString, let status = Status(rawValue: rawValue) {
        return status
      } else {
        return nil
      }
    }
  }
  
}

func ==(lhs: Recall, rhs: Recall) -> Bool {
  return lhs.id == rhs.id
}


















