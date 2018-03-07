//
//  FlickrCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by ivan lares on 2/1/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import UIKit

class FlickrCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static let reuseIdentifier = "flickrCollectionViewCell"
    private static let placeholderImageName = "placeHolderImage"
    
    // MARK: - User Interface
    
    func shouldDim(_ dim: Bool){
        
        imageView.alpha = dim ? 0.2 : 1.0
    }
    
    override func prepareForReuse() {
        
        imageView.image = nil 
        if let placeHolderImage = UIImage(named: FlickrCollectionViewCell.placeholderImageName){
           imageView.image = placeHolderImage
        }
        isSelected = false
        shouldDim(false)
        activityIndicator.stopAnimating()
    }
}
