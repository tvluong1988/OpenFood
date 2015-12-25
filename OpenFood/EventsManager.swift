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
    eventsSortedByDate = eventsSortedByRelevance.sort {return $0.recallInitiationDate!.compare($1.recallInitiationDate!) == .OrderedDescending}
  }
  
  func removeAllEvents() {
    eventsSortedByRelevance.removeAll()
    eventsSortedByDate.removeAll()
  }
  
  func eventsCount() -> Int {
    return eventsSortedByRelevance.count
  }
  
  // MARK: Lifecycle
  init() {
    eventsSortedByRelevance = [Event]()
    eventsSortedByDate = [Event]()
  }
  
  // MARK: Properties
  var eventsSortedByRelevance: [Event]
  var eventsSortedByDate: [Event]
}