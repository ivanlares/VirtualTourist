//
//  TravelMapViewController.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/14/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import MapKit

/// Represents the main map controller that allows users to drop pins
class TravelMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var currentPin: MKPointAnnotation?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addGestures()
    }
    
    // MARK: Helper
    
    fileprivate func addGestures(){
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didPressMapWith(gesture:)))
        mapView.addGestureRecognizer(longPressGesture)
    }
    

    
    
    // MARK: Target Action
    
    @objc func didPressMapWith(gesture: UILongPressGestureRecognizer){
        
        let state = gesture.state
        let mapCoordiante = mapCoordinateFrom(gesture: gesture)
        
        switch state{
        case .began:
            addAnnotation(inCoordinate: mapCoordiante)
        case .changed:
            currentPin?.coordinate = mapCoordiante
        case .ended:
            currentPin = nil
        default: break
        }
    }
    
    // MARK: Map View Methods
    
    fileprivate func mapCoordinateFrom(gesture: UIGestureRecognizer) ->  CLLocationCoordinate2D{
        
        let coordinate:CGPoint = gesture.location(in: mapView)
        let mapCoordiante: CLLocationCoordinate2D = mapView.convert(coordinate, toCoordinateFrom: mapView)
        return mapCoordiante
    }
    
    fileprivate func addAnnotation(inCoordinate coordinate: CLLocationCoordinate2D){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        // update current pin
        currentPin = annotation
    }

}

// MARK: - Map View Delegate

extension TravelMapViewController: MKMapViewDelegate{
    
}
