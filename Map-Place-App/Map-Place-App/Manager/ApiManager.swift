//
//  ApiManager.swift
//  Location-Search
//
//  Created by Osmancan Akagündüz on 4.04.2024.
//

import Foundation

final class ApiManager {
    
    static var apiKey : String? {
        get{
            guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPI") as? String else {
                fatalError("Google Maps API anahtarı eksik veya yanlış konumda")
            }
            return apiKey
        }
    }
    
    
}
