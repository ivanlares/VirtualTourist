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
    @IBOutlet weak var editingLabel: UILabel!
    var currentPin: MKPointAnnotation?
    static let annotationViewReuseIdentifier = "reusableAnnotation"
    var rightBarButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addGestures()
        mapView.delegate = self
        setEditLabel(hidden: true, animated: false)
        
        rightBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    // MARK: Helper Methods
    
    fileprivate func addGestures(){
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didPressMapWith(gesture:)))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    fileprivate func setEditLabel(hidden: Bool, animated: Bool){
        
        UIView.animate(withDuration: animated ? 0.5 : 0){
            self.editingLabel.alpha = (hidden ? 0.0 : 1.0)
        }
    }
    
    // MARK: Target Action
    
    @objc func didPressMapWith(gesture: UILongPressGestureRecognizer){
        
        // return if annotation view is active
        guard !mapView.isAnnotationActive else { return }
        
        // adjust touch location and create coordinate
        var pinLocation = gesture.location(in: mapView)
        pinLocation.y -= Constants.thumbOffset
        let mapCoordiante = mapCoordinateFrom(coordinate:pinLocation)
        
        switch gesture.state {
        case .began:
            addAnnotation(inCoordinate: mapCoordiante)
        case .changed:
            currentPin?.coordinate = mapCoordiante
        case .ended:
            currentPin = nil
        default: break
        }
    }
    
    @objc func showWebView(){
        
        print(#function)
    }
    
    // MARK: Editing
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        mapView.resignAllAnnotations(animated: animated)
        
        if editing{
            rightBarButtonItem?.title = "Done"
            setEditLabel(hidden: false, animated: true)
        } else {
            rightBarButtonItem?.title = "Edit"
            setEditLabel(hidden: true, animated: true)
        }
    }
}

// MARK: - Map View Delegate

extension TravelMapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TravelMapViewController.annotationViewReuseIdentifier){
            return annotationView
        }else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: TravelMapViewController.annotationViewReuseIdentifier)
            configure(annotationView: annotationView)
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        
        if view.rightCalloutAccessoryView == control{
            print("\nRight accessory")
        }
    }
    
}

// MARK: - Map View Helper Methods

extension TravelMapViewController{

    fileprivate func mapCoordinateFrom(coordinate: CGPoint) ->  CLLocationCoordinate2D{
        
        let mapCoordiante: CLLocationCoordinate2D = mapView.convert(coordinate, toCoordinateFrom: mapView)
        return mapCoordiante
    }
    
    fileprivate func addAnnotation(inCoordinate coordinate: CLLocationCoordinate2D){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale  = Locale.current
        
        let date = Date()
        
        annotation.title = dateFormatter.string(from: date)
        annotation.subtitle = "subtitle"
        mapView.addAnnotation(annotation)
        
        // update current pin
        currentPin = annotation
    }
    
    /// Right callout button for annotation view
    ///
    /// - Returns: system info button
    fileprivate func annotationViewRightCallOutButton() -> UIButton{
        
        let button = UIButton(type: .infoLight)
        return button
    }
    
    /// Configures annotation view
    ///
    /// - Parameter annotationView: view to configure
    fileprivate func configure(annotationView: MKAnnotationView){
        
        annotationView.canShowCallout = true
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = annotationViewRightCallOutButton()
    }
}

extension TravelMapViewController{
    
    struct Constants{
        
        static let thumbOffset: CGFloat = 35
    }
}
