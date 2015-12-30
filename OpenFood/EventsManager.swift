//
//  EventsManager.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/25/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//



class EventsManager {
  
  // MARK: Functions
  func addEvent(event: Event) {
    eventsSortedByRelevance.append(event)
    eventsSortedByDate = eventsSortedByRelevance.sort {return $0.reportDate!.compare($1.reportDate!) == .OrderedDescending}
  }
  
  func removeAllEvents() {
    eventsSortedByRelevance.removeAll()
    eventsSortedByDate.removeAll()
  }
  
  func getEventsCount() -> Int {
    return eventsSortedByRelevance.count
  }
  
  func getEventAtIndex(index: Int) -> Event? {
    guard index < getEventsCount() else {
      return nil
    }
    
    switch sortMode {
    case .Relevance: return eventsSortedByRelevance[index]
    case .Date: return eventsSortedByDate[index]
    }
  }
  
  // MARK: Lifecycle
  init() {
    eventsSortedByRelevance = [Event]()
    eventsSortedByDate = [Event]()
  }
  
  // MARK: Properties
  var eventsSortedByRelevance: [Event]
  var eventsSortedByDate: [Event]
  var sortMode: SortOrder = .Relevance
}