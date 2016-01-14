//
//  OpenFoodTests.swift
//  OpenFoodTests
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import XCTest
@testable import OpenFood

class OpenFoodTests: XCTestCase {
  
  // MARK: Tests
  func testRecallManagerAddRecall() {
    
    recallManager.addRecall(recall1)
    XCTAssert(recallManager.recallSortedByRelevance.count == 1)
    XCTAssert(recallManager.recallSortedByDate.count == 1)
  }
  
  func testRecallManagerGetRecallCount() {
    recallManager.recallSortedByRelevance.append(recall1)
    XCTAssert(recallManager.getRecallCount() == 1)
    
    recallManager.recallSortedByRelevance.append(recall2)
    XCTAssert(recallManager.getRecallCount() == 2)
  }
  
  func testRecallManagerRemoveAllRecall() {
    recallManager.recallSortedByRelevance.append(recall1)
    recallManager.recallSortedByRelevance.append(recall2)
    
    recallManager.removeAllRecall()
    
    XCTAssert(recallManager.recallSortedByRelevance.count == 0)
    
    
    recallManager.recallSortedByDate.append(recall1)
    recallManager.recallSortedByDate.append(recall2)
    
    recallManager.removeAllRecall()
    
    XCTAssert(recallManager.recallSortedByDate.count == 0)
    
  }
  
  func testRecallManagerGetRecallAtIndexReturnNil() {
    XCTAssert(recallManager.getRecallAtIndex(4) == nil)
  }
  
  func testRecallManagerGetRecallAtIndexReturnRecallSortedByRelevance() {
    recallManager.sortMode = .Relevance
    recallManager.recallSortedByRelevance.append(recall1)
    recallManager.recallSortedByRelevance.append(recall2)
    
    let retrievedRecall1 = recallManager.getRecallAtIndex(0)!
    let retrievedRecall2 = recallManager.getRecallAtIndex(1)!
    
    XCTAssert(retrievedRecall1 == recall1)
    XCTAssert(retrievedRecall2 == recall2)
  }
  
  func testRecallManagerGetRecallAtIndexReturnRecallSortedByDate() {
    recallManager.sortMode = .Date
    recallManager.recallSortedByRelevance.append(recall1)
    recallManager.recallSortedByRelevance.append(recall2)
    recallManager.recallSortedByDate.append(recall1)
    recallManager.recallSortedByDate.append(recall2)
    
    let retrievedRecall1 = recallManager.getRecallAtIndex(0)!
    let retrievedRecall2 = recallManager.getRecallAtIndex(1)!
    
    XCTAssert(retrievedRecall1 == recall1)
    XCTAssert(retrievedRecall2 == recall2)
  }
  
  func testPolygonsForNationwide() {
    let polygons = polygonsForNationwide()
    
    XCTAssert(polygons.count == 51)
  }
  
  func textConvertUSStateFullNameToAbbreviation() {
    var set = Set<USStateAbbreviation>()
    
    for state in USStateFullName.allValues {
      set.insert(convertUSStateFullNameToAbbreviation(state))
    }
    
    XCTAssert(set.count == USStateAbbreviation.allValues.count)
  }
  
  // MARK: Lifecycle
  override func setUp() {
    super.setUp()
    recallManager = RecallManager()
  }
  
  override func tearDown() {
    super.tearDown()
    
  }
  
  // MARK: Properties
  var recallManager: RecallManager!
  let recall1 = Recall(id: "Recall1")
  let recall2 = Recall(id: "Recall2")
}
























