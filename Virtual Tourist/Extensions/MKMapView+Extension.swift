//
//  MKMapView+Extension.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/17/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import MapKit

extension MKMapView{
    
    /// Removes all annotations from self
    func removeAllAnotations(){
        
        removeAnnotations(annotations)
    }
    
    func resignAllAnnotations(animated: Bool){
        
        for annotation in selectedAnnotations{
            deselectAnnotation(annotation, animated: animated)
        }
    }
    
    /// True if one or more annotations are selected
    var isAnnotationActive: Bool{
        return !selectedAnnotations.isEmpty
    }
    
}
