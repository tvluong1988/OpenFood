//
//  OpenFoodSnapshot.swift
//  OpenFoodSnapshot
//
//  Created by Thinh Luong on 1/12/16.
//  Copyright © 2016 Thinh Luong. All rights reserved.
//

import XCTest

class OpenFoodSnapshot: XCTestCase {
  
  // MARK: Snapshot
  func testSnapshot() {
    app.buttons["About"].tap()
    snapshot("dFourth")
    
    app.buttons["Back"].tap()
    snapshot("aFirst")
    
    app.tables.buttons["Date"].tap()
    let searchField = app.searchFields["Search"]
    searchField.tap()
    searchField.typeText("Iowa")
    snapshot("bSecond")
    
    let recall = app.tables.cells.staticTexts["Dijon Mustard Potato Salad, NET WT 3 LB (1.36 kg)"]
    let exists = NSPredicate(format: "exists == true")
    expectationForPredicate(exists, evaluatedWithObject: recall, handler: nil)
    
    app.buttons["Search"].tap()
    app.buttons["Cancel"].tap()
    
    waitForExpectationsWithTimeout(5, handler: nil)
    
    XCTAssert(recall.exists)
    
    recall.tap()
    
    snapshot("cThird")
  }
  
  // MARK: Lifecycle
  override func setUp() {
    super.setUp()
    
    continueAfterFailure = false
    
    setupSnapshot(app)
    app.launch()
    
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: Properties
  let app = XCUIApplication()
  
}
