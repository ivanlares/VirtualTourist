//
//  AlbumViewController.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/29/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import CoreData
import MapKit

class AlbumViewController: MapViewController {

    @IBOutlet weak var deletePhotosButton: UIButton!
    @IBOutlet weak var bottomButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var album: Album? 
    var location: CLLocationCoordinate2D?
    
    fileprivate let sectionInsets: UIEdgeInsets = {
        let isPad = DeviceHelper.isPad
        
        let sideInset:CGFloat = isPad ? 40 : 20.0
        let verticalInset: CGFloat = isPad ? 50 : 30.0
        
        return UIEdgeInsets(top: verticalInset, left: sideInset, bottom: verticalInset, right: sideInset)
    }()
    
    fileprivate let interItemSpacing: CGFloat = {
        let inset: CGFloat = DeviceHelper.isPad ? 40 : 20.0
        return inset
    }()
    
    fileprivate let rowSpacing: CGFloat = {
        let inset: CGFloat = DeviceHelper.isPad ? 40 : 20.0
        return inset
    }()
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        configureDeleteButton(isHidden: true)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        guard let location = location else { return }

        addMapAnnotation(atLocation: location)
        loadAlbumFromCoreData(withLocation: location)
        
        downloadPhotos()
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
    
    func addAnnotation(atLocation location: CLLocationCoordinate2D, withZoomLevel level: CLLocationDistance = 100000){
        
        addAnnotation(inCoordinate: location, toMapView: mapView, completion: { annoation in
            
            // zoom in
            self.mapView.camera.centerCoordinate = annoation.coordinate
            self.mapView.camera.altitude = level
        })
    }
    
    func configureMapView(){
        
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isScrollEnabled = false
    }
    
    /// adds map annotation at specified location
    func addMapAnnotation(atLocation location: CLLocationCoordinate2D){
        
        addAnnotation(atLocation: location)
    }
}

// MARK: - Core Data

extension AlbumViewController{
    
    
    func performAlbumFetchRequest(withLocation location: CLLocationCoordinate2D) -> [Album]? {
        
        let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
        
        let searchPredicate = NSPredicate(format: "longitude == %@ && latitude == %@", argumentArray: [String(location.longitude), String(location.latitude)])
        
        fetchRequest.predicate = searchPredicate
        
        let context = AppDelegate.sharedCoreDataStack.mainContext
        
        let results = try? context.fetch(fetchRequest)
        return results
    }
    
    /// Fetches initial album from core data and
    /// sets self.album
    func loadAlbumFromCoreData(withLocation location: CLLocationCoordinate2D){
        
        guard let album = performAlbumFetchRequest(withLocation: location)?.first else {
            return
        }
        self.album = album
    }
}

// MARK: - Collection View Data Source

extension AlbumViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return album?.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let flickrCell = collectionView.dequeueReusableCell(withReuseIdentifier: FlickrCollectionViewCell.reuseIdentifier, for: indexPath) as? FlickrCollectionViewCell{
            
            if let album = album, let photos = album.photos, let selectedPhotoObject = photos[indexPath.row] as? Photo, let photoData = selectedPhotoObject.photo as Data?, let image = UIImage(data: photoData){
                
                flickrCell.imageView.image = image
            } else {
                
                if let album = album, let photos = album.photos, let selectedPhotoObject = photos[indexPath.row] as? Photo, let urlString = selectedPhotoObject.urlString, let url = URL(string: urlString){
                    
                    // download photo
                   
                    let task = URLSession.shared.dataTask(with: url){
                            data, _, error in
                        
                            DispatchQueue.main.async {
                                if let data = data{
                                    
                                    selectedPhotoObject.photo = data as NSData
                                    AppDelegate.sharedCoreDataStack.saveContext()
                                    collectionView.reloadItems(at: [indexPath])
                                } else if let error = error{
                                    print(error.localizedDescription)
                                }
                                
                            }
                            
                        }
                        task.resume()
                }
            }
            
            
            return flickrCell
        } else{
            return UICollectionViewCell()
        }
    }
}

// MARK: - Collection View Flow Layout Delegate

extension AlbumViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let isPad = DeviceHelper.isPad
        let cellsPerRow: CGFloat = isPad ? 4 : 3
        
        let totalRowInset: CGFloat =
            sectionInsets.left + sectionInsets.right + ((cellsPerRow-1) * interItemSpacing)
        
        let cellWidth = (collectionView.frame.width - totalRowInset)/cellsPerRow
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
        return sectionInsets
    }
    
    /*
     Spacing between the rows or columns
    */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return rowSpacing
    }
    
    /*
     Spacing in-between cells.
    */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return interItemSpacing
    }
    
}

// MARK: - Networking

extension AlbumViewController{
    
    fileprivate func downloadPhotos(location: CLLocationCoordinate2D, page: Int? = nil, completion: @escaping (FlickrAlbum?, Error?) -> ()) {
        
        Client.sharedInstance.flickrPhotoSearch(withlatitude: String(location.latitude), longitude: String(location.longitude), perPage: "10", page: page ?? 1) {
            (album, error) in
            
            completion(album, error)
        }
    }
    
    fileprivate func downloadPhotos(page: Int? = nil) {
        
        guard let album = album, let location = location else {
            return
        }
        guard !album.isEmpty else{
            return
        }
        
        downloadPhotos(location: location, page: page){
            (flickrAlbum, error) in
            
            DispatchQueue.main.async {
                
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                guard let flickrAlbum = flickrAlbum else{
                    return
                }
                
                var photos = [Photo]()
                for flickrPhoto in flickrAlbum.photos{
                    
                    let photo = Photo.photo(fromFlickrPhoto: flickrPhoto, inContext: AppDelegate.sharedCoreDataStack.mainContext)
                    photos.append(photo)
                }
                
                self.album?.photos = NSOrderedSet(array: photos)
                AppDelegate.sharedCoreDataStack.saveContext()
                self.collectionView.reloadData()
            }
        }
    }
}
