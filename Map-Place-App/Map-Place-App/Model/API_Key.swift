//
//  API_Key.swift
//  Map-Place-App
//
//  Created by Teyfik Yılmaz on 24.05.2024.
//

import Foundation

struct APIKeyProvider {
    static var googleMapsAPIKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPI") as? String else {
            fatalError("Google Maps API anahtarı eksik veya yanlış konumda")
        }
        return apiKey
    }
}
