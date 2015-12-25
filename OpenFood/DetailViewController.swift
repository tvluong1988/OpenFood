//
//  DetailViewController.swift
//  OpenFood
//
//  Created by Thinh Luong on 12/21/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var classLabel: UILabel!
  @IBOutlet weak var locationsLabel: UILabel!
  @IBOutlet weak var productDescriptionLabel: UILabel!
  @IBOutlet weak var problemLabel: UILabel!
  @IBOutlet weak var recallDateLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let center = CLLocationCoordinate2D(latitude: 40, longitude: -90)
    let span = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
    let region = MKCoordinateRegion(center: center, span: span)
    mapView.setRegion(region, animated: true)
    mapView.showsUserLocation = false
    
    title = event?.classification
    productDescriptionLabel.lineBreakMode = .ByWordWrapping
    productDescriptionLabel.numberOfLines = 0
    
    problemLabel.lineBreakMode = .ByWordWrapping
    problemLabel.numberOfLines = 0
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if let event = event {
      statusLabel.text = "Status - \(event.status!)"
      classLabel.text = event.classification
      productDescriptionLabel.text = event.productDescription
      
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateStyle = .MediumStyle
      let date = dateFormatter.stringFromDate(event.recallInitiationDate!)
      recallDateLabel.text = "Recall date: \(date)"
      
      if let states = event.affectedStates {
        if states.contains(.Nationwide) {
          mapView.addOverlays(polygonsForNationwide())
        } else {
          for state in states {
            mapView.addOverlay(polygonForState(state))
          }
        }
        
        let center = CLLocationCoordinate2D(latitude: 40, longitude: -115)
        let span = MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
      }
      
      problemLabel.text = "Problem - \(event.reasonForRecall!)"
      problemLabel.sizeToFit()
      
    }
  }
  
  // MARK: Properties
  var event: Event?
}

// MARK: - MKMapViewDelegate
extension DetailViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolygon {
      let polygonView = MKPolygonRenderer(overlay: overlay)
      polygonView.strokeColor = UIColor.orangeColor()
      
      return polygonView
    }
    
    return MKOverlayRenderer()
  }
}





























