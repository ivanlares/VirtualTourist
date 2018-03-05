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
    
    static let reuseIdentifier = "flickrCollectionViewCell"

    
    // MARK: - User Interface
    
    func shouldDim(_ dim: Bool){
        
        imageView.alpha = dim ? 0.2 : 1.0
    }
    
    override func prepareForReuse() {
        
        imageView.image = nil
        isSelected = false
        shouldDim(false)
    }
}
