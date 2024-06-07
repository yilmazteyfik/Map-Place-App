//
//  GooglePlaceManager.swift
//  Map-Place-App
//
//  Created by Teyfik Yılmaz on 9.05.2024.
//

import Foundation
import GooglePlaces
import GoogleMaps
import CoreLocation



final class GooglePlacesManeger{
    static let shared = GooglePlacesManeger()
    private let client  = GMSPlacesClient.shared()
    var placesClient: GMSPlacesClient!

    enum PlacesError: Error{
        case failedToFind
        case failToGetCoordinate
    }
    
    private init(){
        
    }
  
    public func findPlaces(
        query: String ,
        completion : @escaping (Result<[Place], Error>) -> Void){
            let filter = GMSAutocompleteFilter()
            filter.type = .geocode
            
            client.findAutocompletePredictions(
                fromQuery: query,
                filter: filter,
                sessionToken: nil
            ) { results , error in
                guard let results = results , error == nil else{
                    completion(.failure(PlacesError.failedToFind))
                    return
                }
                let places : [Place] = results.compactMap({
                    Place(
                        name: $0.attributedFullText.string,
                        identifier: $0.placeID
                    )
                })
                
                completion(.success(places))
        }
    }
    
    public func resolveLocation(for place: Place, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        client.fetchPlace(fromPlaceID: place.identifier, placeFields: .coordinate, sessionToken: nil) { googlePlace, error in
            if let error = error {
                print("Error fetching place: \(error.localizedDescription)")
                completion(.failure(PlacesError.failToGetCoordinate))
                return
            }
            guard let googlePlace = googlePlace else {
                completion(.failure(PlacesError.failToGetCoordinate))
                return
            }
            let coordinate = CLLocationCoordinate2D(
                latitude: googlePlace.coordinate.latitude,
                longitude: googlePlace.coordinate.longitude)
            
            completion(.success(coordinate))
        }
    }
    func findPlacesBetweenLocations(location1: String, location2: String, completion: @escaping ([GMSPlace]) -> Void) {
        guard let apiKey = ApiManager.apiKey else {
            fatalError("Google Maps API anahtarı eksik veya yanlış konumda")
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location1)&location=\(location2)&radius=5000&type=restaurant&key=\(apiKey)"
        print("1")
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        print("2")
        
        
    
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    completion([])
                    return
                }
//                print(data)
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let results = json["results"] as? [[String: Any]] {
//                        print("JSON: \(json)")

                        var places = [GMSPlace]()
                        for result in results {
                            if let placeID = result["place_id"] as? String {
                                DispatchQueue.main.async {
                                    GMSPlacesClient.shared().lookUpPlaceID(placeID) { (place, error) in
                                        if let place = place {
                                            places.append(place)
                                            if places.count == results.count {
                                                print("Sonuc: \(places.count)")
                                                completion(places)
                                            }
                                        } else {
                                            print("Place lookup error: \(error?.localizedDescription ?? "")")
                                        }
                                    }
                                }
                               
                            }
                        }
                        return
                    }
                } catch {
                    print("JSON serialization error: \(error.localizedDescription)")
                }
                
                completion([])
            }
            
            task.resume()
        
        }
    
    
    
    func fetchLikelyPlaces(onComplete:@escaping ([GMSPlaceLikelihood]?)-> ())  {
        let placesField: GMSPlaceField = [.name,.types, .all]
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placesField) { (placeLikehoods, error) in
          guard error == nil else {
            // TODO: Handle the error.
            print("Current Place error: \(error!.localizedDescription)")
            return
          }

          guard let placeLikelihoods = placeLikehoods else {
            print("No places found.")
            return
          }
            
         onComplete(placeLikelihoods)
            
        }
    }
    
    func findPlacesNearby(location1: CLLocationCoordinate2D, radius: Double, completion: @escaping ([GMSPlace]) -> Void) {
        guard let apiKey = ApiManager.apiKey else {
            fatalError("Google Maps API anahtarı eksik veya yanlış konumda")
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location1.latitude),\(location1.longitude)&radius=\(radius)&type=restaurant&key=\(apiKey)"
        print("1")
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        print("2")
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let results = json["results"] as? [[String: Any]] {
                    print("JSON: \(json)")

                    var places = [GMSPlace]()
                    for result in results {
                        if let placeID = result["place_id"] as? String {
                            DispatchQueue.main.async {
                                GMSPlacesClient.shared().lookUpPlaceID(placeID) { (place, error) in
                                    if let place = place {
                                        places.append(place)
                                        if places.count == results.count {
                                            completion(places)
                                        }
                                    } else {
                                        print("Place lookup error: \(error?.localizedDescription ?? "")")
                                    }
                                }
                            }
                        }
                    }
                    return
                }
            } catch {
                print("JSON serialization error: \(error.localizedDescription)")
            }
            
            completion([])
        }
        
        task.resume()
    }
}
