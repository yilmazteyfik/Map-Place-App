//
//  SearchPlaceModel.swift
//  Map-Place-App
//
//  Created by Osmancan Akagündüz on 23.05.2024.
//

import Foundation
import CoreLocation

struct SearchPlaceModel: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
