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
    var rightBarButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addGestures()
        setEditLabel(hidden: true, animated: false)
        
        rightBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        setMapRegionWithDefaults()
        // set map view delegate after map view region is set
        mapView.delegate = self
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("\n\n", documentsPath, "\n\n")
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
        if !Platform.isSimulator{
            pinLocation.y -= Constants.thumbOffset
        }
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

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // Probably not a good feature, but this is part of the rubric.
        // It would be more useful to save the location of the last pin.
        saveMapLocation()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        performSegue(withIdentifier: Constants.albumSegueIdentifier, sender: nil)
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
        mapView.addAnnotation(annotation)
        // update current pin
        currentPin = annotation
    }
    
    /// Save map view region and camera into user defaults
    fileprivate func saveMapLocation(){
        
        // archive camera (NSCoding implemented by default)
        let mapViewCamera = mapView.camera
        let archivedMapCamera = NSKeyedArchiver.archivedData(withRootObject: mapViewCamera)
        UserDefaults.standard.set(archivedMapCamera, forKey: Constants.mapCameraKey)
        
        // archived region (with Codable because it's a struct)
        let mapViewRegion = mapView.region
        if let archivedMapRegion = try? PropertyListEncoder().encode(mapViewRegion){
            
            UserDefaults.standard.set(archivedMapRegion, forKey: Constants.mapRegionKey)
        }
    }
    
    /// Sets self.mapView with region stored in user defaults
    fileprivate func setMapRegionWithDefaults(){
        
        if let mapRegionFromDefaults = getMapRegionFromUserDefaults(){
            
            mapView.region = mapRegionFromDefaults
        }
        if let mapCameraFromDefaults = getMapCameraFromUserDefaults(){
            
            mapView.camera = mapCameraFromDefaults
        }
    }
    
    /// Returns map view region from user defaults
    ///
    /// - Returns: nil if no data is present
    fileprivate func getMapRegionFromUserDefaults()  -> MKCoordinateRegion? {
        
        guard let archivedRegionData = UserDefaults.standard.object(forKey: Constants.mapRegionKey) as? Data else {
            return nil
        }
 
        guard let regionPropertyList = try? PropertyListDecoder().decode(MKCoordinateRegion.self, from: archivedRegionData) else {
            return nil
        }
        
        return regionPropertyList
    }
    
    fileprivate func getMapCameraFromUserDefaults() -> MKMapCamera?{
        
        if let archivedCamera = UserDefaults.standard.object(forKey: Constants.mapCameraKey) as? Data{
            
            return NSKeyedUnarchiver.unarchiveObject(with: archivedCamera) as? MKMapCamera
        }
        
        return nil
    }
}

// MARK: Constants

extension TravelMapViewController{
    
    struct Constants{
        
        /// Y-offset to account for user's finger/thumb.
        static let thumbOffset: CGFloat = 35
        static let annotationViewReuseIdentifier = "reusableAnnotation"
        
        // Keys used to store map location in user defaults
        static let mapRegionKey = "mapViewRegionKey"
        static let mapCameraKey = "mapViewCameraKey"
        
        // Segue identifier
        static let albumSegueIdentifier = "albumSegueIdentifier"
        
        private init() {}
    }
}
