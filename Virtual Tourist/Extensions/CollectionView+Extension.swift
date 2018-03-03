//
//  CollectionView+Extension.swift
//  Virtual Tourist
//
//  Created by ivan lares on 3/2/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import UIKit

extension UICollectionView{
    
    /// deselects cells at the specified index paths
    func deselectCells(atIdexPaths indexPaths: [IndexPath], animated: Bool = false){
        
        for indexPath in indexPaths{
            deselectItem(at: indexPath, animated: animated)

        }
    }
    
    /// Deselects all cells
    func deselectAllCells(animated: Bool = false){
       
        if let indexPaths = indexPathsForSelectedItems{
            
            deselectCells(atIdexPaths: indexPaths)
        }
    }
    
    func cellsForItems(atIndexPaths indexPaths: [IndexPath]) -> [UICollectionViewCell]{
        
        var cells = [UICollectionViewCell]()
        
        for indexPath in indexPaths{
            if let cell = cellForItem(at: indexPath){
                cells.append(cell)
            }
        }
        
        return cells
    }
    
}

