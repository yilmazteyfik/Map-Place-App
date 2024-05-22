//
//  DirectionAPIModel.swift
//  Map-Place-App
//
//  Created by Teyfik Yılmaz on 22.05.2024.
//

import Foundation

struct EndLocation: Codable {
    let lat: Double
    let lng: Double
}

struct Step: Codable {
    let end_location: EndLocation
}

struct Leg: Codable {
    let steps: [Step]
}

struct Route: Codable {
    let legs: [Leg]
}

struct RouteResponse: Codable {
    let routes: [Route]
}
