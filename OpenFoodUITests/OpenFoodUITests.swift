//
//  OpenFoodUITests.swift
//  OpenFoodUITests
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import XCTest

class OpenFoodUITests: XCTestCase {
  
  // MARK: Tests
  func testScrolling() {
    app.cells.elementBoundByIndex(0).swipeUp()
    app.cells.elementBoundByIndex(20).swipeUp()
    app.cells.elementBoundByIndex(40).swipeUp()
  }
  
  func testFacebookButton() {
    pressAboutButton()
    app.buttons["FacebookButton"].tap()
    pressAlertOK()
  }
  
  func testTwitterButton() {
    pressAboutButton()
    app.buttons["TwitterButton"].tap()
    pressAlertOK()
  }
  
  func testAppStoreButton() {
    pressAboutButton()
    app.buttons["AppStoreButton"].tap()
    pressAlertCancel()
  }
  
  func testSearchBarFailed() {
    app.tables.buttons["Date"].tap()
    
    let searchField = app.searchFields["Search"]
    searchField.tap()
    searchField.typeText("asdfghjkl")
    
    let errorMessage = app.staticTexts["No matches found!"]
    let exists = NSPredicate(format: "exists == true")
    expectationForPredicate(exists, evaluatedWithObject: errorMessage, handler: nil)
    
    app.buttons["Search"].tap()
    
    waitForExpectationsWithTimeout(5, handler: nil)
    
    XCTAssert(errorMessage.exists)
    
    pressAlertOK()
  }
  
  func testSearchBarSuccess() {
    app.tables.buttons["Date"].tap()
    
    let searchField = app.searchFields["Search"]
    searchField.tap()
    searchField.typeText("Iowa")
    
    let recall = app.tables.cells.staticTexts["Dry Grated Romano, Tipico Item #1-00111000, Net Wt. 50 lbs."]
    let exists = NSPredicate(format: "exists == true")
    expectationForPredicate(exists, evaluatedWithObject: recall, handler: nil)
    
    app.buttons["Search"].tap()
    app.buttons["Cancel"].tap()
    
    waitForExpectationsWithTimeout(5, handler: nil)
    
    XCTAssert(recall.exists)
    
  }
  
  /**
   Cannot tap "Cancel" button on Sign In system alert.
   */
   //  func testRestorePurchaseButton() {
   //    pressAboutButton()
   //    
   //    addUIInterruptionMonitorWithDescription("Sign In") {
   //      alert -> Bool in
   //      alert.buttons["Cancel"].tap()
   //      return true
   //    }
   //    
   //    app.buttons["RestorePurchaseButton"].tap()
   //    app.tap()
   //  }
   //  
   //  func testRemoveAdsButton() {
   //    pressAboutButton()
   //    
   //    addUIInterruptionMonitorWithDescription("Sign In") {
   //      alert -> Bool in
   //      alert.buttons["Cancel"].tap()
   //      return true
   //    }
   //    
   //    app.buttons["RemoveAdsButton"].tap()
   //    app.tap()
   //  }
   
   // MARK: Functions
  func pressAboutButton() {
    app.buttons["About"].tap()
  }
  
  func pressAlertCancel() {
    app.alerts.buttons["Cancel"].tap()
  }
  
  func pressAlertOK() {
    app.alerts.buttons["OK"].tap()
  }
  
  // MARK: Lifecycle
  override func setUp() {
    super.setUp()
    
    continueAfterFailure = false
    
    app.launch()
    
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: Properties
  let app = XCUIApplication()
  
}
