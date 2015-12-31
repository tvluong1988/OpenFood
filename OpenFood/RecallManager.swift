//
//  EventsManager.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/25/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

/// RecallManager handles the recall object model.
class RecallManager {
  
  // MARK: Functions
  /**
  Add recall object to the current array.
  
  - parameter recall: recall object to add
  */
  func addRecall(recall: Recall) {
    recallSortedByRelevance.append(recall)
    
    recallSortedByDate = recallSortedByRelevance.sort {
      if let firstRecallReportDate = $0.reportDate, let secondRecallReportDate = $1.reportDate {
        return firstRecallReportDate.compare(secondRecallReportDate) == .OrderedDescending
      } else {
        return false
      }
    }
  }
  
  /**
   Remove all recall objects in the current array.
   */
  func removeAllRecall() {
    recallSortedByRelevance.removeAll()
    recallSortedByDate.removeAll()
  }
  
  /**
   Retrieve the count of recall objects in the current array.
   
   - returns: count of recall objects
   */
  func getRecallCount() -> Int {
    return recallSortedByRelevance.count
  }
  
  /**
   Retrieve recall object at specified index of the current array.
   
   - parameter index: index
   
   - returns: recall object
   */
  func getRecallAtIndex(index: Int) -> Recall? {
    guard index < getRecallCount() else {
      return nil
    }
    
    switch sortMode {
    case .Relevance: return recallSortedByRelevance[index]
    case .Date: return recallSortedByDate[index]
    }
  }
  
  // MARK: Lifecycle
  init() {
    recallSortedByRelevance = [Recall]()
    recallSortedByDate = [Recall]()
  }
  
  // MARK: Properties
  /// Recall sorted by relevance.
  var recallSortedByRelevance: [Recall]
  /// Recall sorted by date starting from latest.
  var recallSortedByDate: [Recall]
  /// Current sort mode.
  var sortMode: SortOrder = .Relevance
}


















