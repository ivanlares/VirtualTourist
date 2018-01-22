//
//  MKCoordinateRegion+Extension.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/21/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import MapKit

/* Note:
        MKMapView region will be a bit off.
        This issue is documented on Stackoverflow.
        It will only be an issue if we need super precise measurements but we don't.
*/

extension MKCoordinateRegion: Encodable, Decodable{
    
    enum CoordinateKeys: String, CodingKey {
        case latitude = "latitudeKey"
        case longitude = "longitudeKey"
        case latitudeDelta = "latitudeDeltaKey"
        case longitudeDelta = "longitudeDeltaKey"
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CoordinateKeys.self)
        
        try container.encode(self.center.latitude, forKey: CoordinateKeys.latitude)
        try container.encode(self.center.longitude, forKey: CoordinateKeys.longitude)
        try container.encode(self.span.latitudeDelta, forKey: CoordinateKeys.latitudeDelta)
        try container.encode(self.span.longitudeDelta, forKey: CoordinateKeys.longitudeDelta)
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CoordinateKeys.self)
        
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        let latitudeDelta = try values.decode(Double.self, forKey: .latitudeDelta)
        let longitudeDelta = try values.decode(Double.self, forKey: .longitudeDelta)
        
        center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        span  =  MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }

}
