//
//  TravelMapViewController.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/14/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import MapKit
import CoreData

/// Represents the main map controller that allows users to drop pins
class TravelMapViewController: MapViewController {
    
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
        print(documentsPath)
        
        loadMapViewPins()
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
    
    /// adds pins to map views
    fileprivate func loadMapViewPins() {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let albums = retrieveAlbums()
        
        for album in albums{
            
            guard let latitude = album.latitude?.toDouble(), let longitude = album.longitude?.toDouble() else {
                continue
            }
            
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            addAnnotation(inCoordinate: location, toMapView: mapView, completion: nil)
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
            
            addAnnotation(inCoordinate: mapCoordiante, toMapView: mapView){
                [weak self] annotation in
                // update current pin
                self?.currentPin = annotation
            }
        case .changed:
            currentPin?.coordinate = mapCoordiante
        case .ended:
            // save to core data
            if let location = currentPin?.coordinate{
                storeAlbum(withLocation: location)
            }
            // delete refrence to pin
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == Constants.albumSegueIdentifier else{
            return
        }
        guard let albumViewController = segue.destination as? AlbumViewController else{
            return
        }
        guard let location = sender as? CLLocationCoordinate2D  else{
            return
        }
        
        albumViewController.location = location

        if let annotation = mapView.annotations.first{
            mapView.deselectAnnotation(annotation, animated: false)
        }
        
    }
}

// MARK: Core Data

extension TravelMapViewController{
    
    fileprivate func storeAlbum(withLocation location: CLLocationCoordinate2D){
        
        let stack = AppDelegate.sharedCoreDataStack
        guard let entity = NSEntityDescription.entity(forEntityName: "Album", in: stack.mainContext) else { return }
        
        let _ = Album(entity: entity, insertInto: stack.mainContext, location: location)
        stack.mainContext.perform {
            stack.saveContext()
        }
    }
    
    /// retrieve core data album objects
    fileprivate func retrieveAlbums() -> [Album] {
        
        let fetchRequest = NSFetchRequest<Album>(entityName: "Album")
        let albums = try? AppDelegate.sharedCoreDataStack.mainContext.fetch(fetchRequest)
        
        return albums ?? [Album]()
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
       
        performSegue(withIdentifier: Constants.albumSegueIdentifier, sender: view.annotation?.coordinate)
    }
    
}

// MARK: - Map View Helper Methods

extension TravelMapViewController{

    fileprivate func mapCoordinateFrom(coordinate: CGPoint) ->  CLLocationCoordinate2D{
        
        let mapCoordiante: CLLocationCoordinate2D = mapView.convert(coordinate, toCoordinateFrom: mapView)
        return mapCoordiante
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
