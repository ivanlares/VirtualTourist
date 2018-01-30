//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/29/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import MapKit

class MapViewController: UIViewController {

    func addAnnotation(inCoordinate coordinate: CLLocationCoordinate2D, toMapView mapView:MKMapView, completion: ((MKPointAnnotation)->())?){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        completion?(annotation)
    }

}
