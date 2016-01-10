//
//  DetailViewController.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import iAd
import UIKit
import MapKit

class DetailViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!
  
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var classLabel: UILabel!
  @IBOutlet weak var recallDateLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  
  @IBOutlet weak var problemLabel: UILabel!
  @IBOutlet weak var productDescriptionTextView: UITextView!
  
  @IBOutlet weak var recallingFirmLabel: UILabel!
  
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let isPaid = Product.store.isProductPurchased(Product.RemoveAds)
    canDisplayBannerAds = !isPaid
    
    let center = CLLocationCoordinate2D(latitude: 40, longitude: -90)
    let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    let region = MKCoordinateRegion(center: center, span: span)
    mapView.setRegion(region, animated: true)
    mapView.showsUserLocation = false
    
    problemLabel.lineBreakMode = .ByWordWrapping
    problemLabel.numberOfLines = 0
    
    recallingFirmLabel.lineBreakMode = .ByWordWrapping
    recallingFirmLabel.numberOfLines = 0
    
    productDescriptionTextView.backgroundColor = UIColor.flatWhiteColorDark().lightenByPercentage(0.1)
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    adBannerView = getAppDelegate().adBannerView
    adBannerView.delegate = self
    
    view.addSubview(adBannerView)
    
    if let recall = recall {
      statusLabel.text = "Status: \(recall.status!)"
      
      if let status = recall.status {
        statusLabel.backgroundColor = status.getBackgroundColor()
        statusLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: status.getBackgroundColor(), isFlat: true)
        statusLabel.text = status.rawValue
      }
      
      if let classification = recall.classification {
        classLabel.backgroundColor = classification.getBackgroundColor()
        classLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: classification.getBackgroundColor(), isFlat: true)
        classLabel.text = classification.rawValue
      }
      
      
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateStyle = .MediumStyle
      let date = dateFormatter.stringFromDate(recall.reportDate!)
      recallDateLabel.text = "Recall date: \(date)"
      recallDateLabel.sizeToFit()
      
      if let states = recall.affectedStates {
        if states.contains(.Nationwide) {
          mapView.addOverlays(polygonsForNationwide())
        } else {
          for state in states {
            mapView.addOverlay(polygonForState(state))
          }
        }
        
        let center = CLLocationCoordinate2D(latitude: 40, longitude: -115)
        let span = MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
      }
      
      problemLabel.text = recall.reasonForRecall
      problemLabel.sizeToFit()
      
      productDescriptionTextView.text = recall.productDescription
      productDescriptionTextView.sizeToFit()
      
      recallingFirmLabel.text = recall.recallingFirm
      recallingFirmLabel.sizeToFit()
      
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
    adBannerView.delegate = nil
    adBannerView.removeFromSuperview()
  }
  
  // MARK: Properties
  /// Recall information to display.
  var recall: Recall?
  var adBannerView: ADBannerView!
}

// MARK: - MKMapViewDelegate
extension DetailViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolygon {
      let polygonView = MKPolygonRenderer(overlay: overlay)
      polygonView.strokeColor = recall?.status?.getBackgroundColor() ?? UIColor.orangeColor()
      
      return polygonView
    }
    
    return MKOverlayRenderer()
  }
}

// MARK: - ADBannerViewDelegate
extension DetailViewController: ADBannerViewDelegate {
  func bannerViewDidLoadAd(banner: ADBannerView!) {
    adBannerView.hidden = false
  }
  
  func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
    adBannerView.hidden = true
  }
}



























