//
//  AlbumViewController.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/29/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import UIKit
import MapKit

class AlbumViewController: MapViewController {

    @IBOutlet weak var deletePhotosButton: UIButton!
    @IBOutlet weak var bottomButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    var location: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDeleteButton(isHidden: true)
        
        guard let location = location else { return }
        
        addAnnotation(inCoordinate: location, toMapView: mapView, completion: { annoation in
            
            // zoom in
            self.mapView.camera.centerCoordinate = annoation.coordinate
            self.mapView.camera.altitude = 100000
        })
    }
    
    // MARK: - Target Action
    
    @IBAction func didPressSelect(_ sender: UIButton) {
        
        // select or unselect button
        sender.isSelected = !sender.isSelected
        
        // if button is selected, unhide delete button
        configureDeleteButton(isHidden: !sender.isSelected)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func didSelectRefresh(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - User Interface
    
    func configureDeleteButton(isHidden hidden: Bool){
        
        if hidden{
            bottomButtonConstraint.constant = deletePhotosButton.frame.height
        } else{
            bottomButtonConstraint.constant = 0
        }
    }
    
}

