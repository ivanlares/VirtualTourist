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
    
    // Note: album is already stored to core-data database.
    // Fetch request with lat/lon used to set this value.
    var album: Album? 
    var location: CLLocationCoordinate2D?
    /// maximum number of pages for flickr search
    static let maxPage:Int = 8
    
    
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
        
        collectionView.allowsMultipleSelection = true
        
        configureMapView()
        isEditing = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        guard let location = location else { return }
        
        addMapAnnotation(atLocation: location)
        loadAlbumFromCoreData(withLocation: location)
        
        if let album = album, album.isEmpty{
            downloadPhotos()
        }
    }
    
    // MARK: - Target Action
    
    @IBAction func didPressSelect(_ sender: UIButton) {
        
        toggleSelectButton()
        toggleEditing()
    }
    
    @IBAction func didSelectRefresh(_ sender: UIBarButtonItem) {
        
        var pages: [Int] = Array(1...AlbumViewController.maxPage)
        let pageToRemove: Int? = Int(album?.page ?? 0)
        
        if let pageToRemove = pageToRemove{
            if let indexToRemove = pages.index(of: pageToRemove){
                pages.remove(at: indexToRemove)
            }
        }
        
        pages.shuffle()
        
        let nextPage = pages.first!
        
        downloadPhotos(page: nextPage)
        
    }
    
    @IBAction func didPressDelete(_ sender: Any) {
        
        let stack = AppDelegate.sharedCoreDataStack
        
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else {
            return
        }
        
        selectedIndexPaths.forEach(){ indexPath in
            
            if let photo = album?.photos?.object(at: indexPath.row) as? Photo{
                stack.mainContext.delete(photo)
            }
        }
        
        stack.saveContext()
        collectionView.reloadData()
    }
    
    // MARK: - User Interface
    
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
    
    private func toggleSelectButton() {
        
        selectButton.isSelected = !selectButton.isSelected
    }
    
    // MARK: - Editing
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        deselectAllCells()
        
        if editing{
            bottomButtonConstraint.constant = 0
        } else{
            bottomButtonConstraint.constant = deletePhotosButton.frame.height
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func deselectAllCells(){
        
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else {
            return
        }
        
        collectionView.deselectCells(atIdexPaths: selectedIndexPaths)
        
        if let cells = collectionView.cellsForItems(atIndexPaths: selectedIndexPaths) as? [FlickrCollectionViewCell]{
            
            cells.forEach({$0.shouldDim(false)})
        }
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
        
        guard let flickrCell = collectionView.dequeueReusableCell(withReuseIdentifier: FlickrCollectionViewCell.reuseIdentifier, for: indexPath) as? FlickrCollectionViewCell, let album = album, let photos = album.photos, let selectedPhotoObject = photos[indexPath.row] as? Photo else {
            return UICollectionViewCell()
        }
        
        flickrCell.prepareForReuse()
        
        if let photoData = selectedPhotoObject.photo as Data?, let image = UIImage(data: photoData){
            
            // stop activity indicator when image is set
            flickrCell.activityIndicator.stopAnimating()
            flickrCell.imageView.image = image
        } else if let urlString = selectedPhotoObject.urlString, let url = URL(string: urlString){
            
            // start indicator
            flickrCell.activityIndicator.startAnimating()
            
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
        
        return flickrCell
    }
    
}

// MARK: - Collection View Delegate

extension AlbumViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        return isEditing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch isEditing {
        case true:
            
            if let cell = collectionView.cellForItem(at: indexPath) as? FlickrCollectionViewCell{
                
                cell.shouldDim(cell.isSelected)
                
            }
        case false:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        
        return isEditing
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        switch isEditing {
        case true:
            
            if let cell = collectionView.cellForItem(at: indexPath) as? FlickrCollectionViewCell{
                
                cell.shouldDim(cell.isSelected)
            }
        case false:
            break
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
        
        guard let location = location else {
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
                
                guard let album = self.album else { return }
                
                album.removeAllPhotos()
                
                self.album?.photos = NSOrderedSet(array: photos)
                self.album?.page = Int32(flickrAlbum.page)
                AppDelegate.sharedCoreDataStack.saveContext()
                self.collectionView.reloadData()
            }
        }
    }
}
