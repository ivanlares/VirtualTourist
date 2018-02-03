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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    fileprivate let isPad = (UIScreen.main.traitCollection.userInterfaceIdiom == .pad)
    
    fileprivate let sectionInsets: UIEdgeInsets = {
        let isPad = (UIScreen.main.traitCollection.userInterfaceIdiom == .pad)
        
        return UIEdgeInsets(top: 50.0, left: isPad ? 40 : 20.0, bottom: 50.0, right: isPad ? 40 : 20.0)
    }()
    
    var flickrAlbum: FlickrAlbum?
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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        downloadPhotos(location: location){
            (album, error) in
            
            DispatchQueue.main.async {
                
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                
                if let album = album{
                    self.flickrAlbum = album
                }
                
                self.collectionView.reloadData()
            }
        }
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

// MARK: - Collection View Data Source

extension AlbumViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrAlbum?.photos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let flickrCell = collectionView.dequeueReusableCell(withReuseIdentifier: FlickrCollectionViewCell.reuseIdentifier, for: indexPath) as? FlickrCollectionViewCell{
                        
            return flickrCell
        } else{
            return UICollectionViewCell()
        }
    }
}

// MARK: - Collection View Flow Layout Delegate

extension AlbumViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellsPerRow: CGFloat = isPad ? 4 : 3
        let spacingBettweenCells: CGFloat = isPad ? 20 : 10
        let totalRowInset: CGFloat =
            sectionInsets.left + sectionInsets.right + ((cellsPerRow-1) * spacingBettweenCells)
        
        let cellWidth = (collectionView.frame.width - totalRowInset)/cellsPerRow
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
        return sectionInsets
    }
    
}

// MARK: - Networking

extension AlbumViewController{
    
    
    fileprivate func downloadPhotos(location: CLLocationCoordinate2D, completion: @escaping (FlickrAlbum?, Error?) -> ()) {
        
        Client.sharedInstance.flickrPhotoSearch(withlatitude: String(location.latitude), longitude: String(location.longitude), perPage: "10") {
            (album, error) in
            
            completion(album, error)
        }
        
    }
    
}

