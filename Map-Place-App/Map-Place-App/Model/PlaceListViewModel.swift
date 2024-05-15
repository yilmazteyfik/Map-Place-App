//
//  PlaceListViewModel.swift
//  Map-Place-App
//
//  Created by Teyfik Yılmaz on 9.05.2024.
//

import Foundation
import GooglePlaces
import GoogleMaps
import Combine

final class PlaceListViewModel {
    
    static let instance : PlaceListViewModel = PlaceListViewModel()
    @Published var placeList:[GMSPlace] = []
    private let placeManager: GooglePlacesManeger = GooglePlacesManeger.shared
    var filterModel : FilterModel = FilterModel.instance
    private var cancelable : Set<AnyCancellable> = []

    
    
    
    func fetchPlaces()  {
        let mapViewModel = MapViewModel.instance
        
        var location1: String = ""
        var location2: String = ""
        if let latitude = mapViewModel.firstCoordinate?.latitude, let longitude = mapViewModel.firstCoordinate?.longitude {
            location1 = "\(latitude),\(longitude)"
//            print(location1)
        } else {
            print("Koordinat bulunamadı")
        }
        
        if let latitude = mapViewModel.secondCoordinate?.latitude, let longitude = mapViewModel.secondCoordinate?.longitude {
            location2 = "\(latitude),\(longitude)"
//            print(location2)
        } else {
            print("Koordinat bulunamadı")
        }
        
        GooglePlacesManeger.shared.findPlacesBetweenLocations(location1: location1, location2: location2) { places in
            self.placeList = places
            print("GelenSonuc \(places.count)")
        }
        
    }
}

extension PlaceListViewModel {
    
    func listLikelyPlaces(tableView: UITableView, placesClient: GMSPlacesClient) {
           placeList.removeAll()

           let placesField: GMSPlaceField = [.name, .types, .all]
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

               // Get selected categories from FilterModel
               let selectedCategories = FilterModel.instance.categories.filter { $0.flag }.map { $0.name }
               var isCategorySelected = false
               // Use Combine to listen for changes in key_word
               FilterModel.instance.$key_word.sink { keyWord in
                   // Loop through each likelihood
                   
                   for likelihood in placeLikelihoods {
                       let place = likelihood.place

                       // Check if any of the selected categories match the place types
                       
                       if let types = place.types {
                           for category in selectedCategories {
                               // Check if the place types contain selected category and the place name contains the keyword
                               if types.contains(category){
                                   isCategorySelected = true
                                   if let name = place.name?.lowercased() , name.contains(keyWord.lowercased()), keyWord != "-1"{
                                       if self.placeList.contains(place){
                                           continue
                                       } else {
                                           self.placeList.append(place)
                                           print(name)
                                       }
                                       //tableView.reloadData()
                                   } else if (keyWord == "-1"){
                                       if self.placeList.contains(place){
                                           continue
                                       } else {
                                           self.placeList.append(place)
                                       }
                                   }
                               }
                           }
                           if (!isCategorySelected){
                               if let types = place.types, types.contains("food") || types.contains("cafe") || types.contains("restaurant") || types.contains("bar") || types.contains("pub") || types.contains("fast_food") || types.contains("fine_dining") ||
                                    types.contains("bakery") || types.contains("ice_cream_shop") {
                                   if let name = place.name?.lowercased() , name.contains(keyWord.lowercased()), keyWord != "-1"{
                                       self.placeList.append(place)
                                       print(name)
                                   } else if (keyWord == "-1"){
                                       self.placeList.append(place)
                                   }
                                }
                           }
                       }
                   


                       DispatchQueue.main.async {
                           tableView.reloadData()
                       }
                   }
               }.store(in: &self.cancelable) // Store the cancellable to avoid memory leaks
           }
       }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    func listPlacesNearby(latitude: Double, longitude: Double, tableView: UITableView, placesClient: GMSPlacesClient) {
        placeList.removeAll()
        
        // Belirli bir koordinat oluştur
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // 2 km yarıçapında olan bir dairesel bölge oluştur
        let radius = 2000.0 // Metre cinsinden
        let region = GMSVisibleRegion.nearbyRegion(forCoordinate: coordinate, latLngRadius: radius)
        
        // Yakındaki mekanları bul
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        placesClient.findAutocompletePredictions(fromBounds: nil, filter: filter, sessionToken: nil) { (results, error) in
            guard error == nil else {
                print("Yakındaki mekanlar alınamadı. Hata: \(error!.localizedDescription)")
                return
            }
            
            guard let results = results else {
                print("Yakındaki mekanlar alınamadı.")
                return
            }
            
            // Bulunan mekanları işle
            for result in results {
                let placeID = result.placeID
                placesClient.lookUpPlaceID(placeID) { (place, error) in
                    guard error == nil else {
                        print("Mekan bilgileri alınamadı. Hata: \(error!.localizedDescription)")
                        return
                    }
                    
                    guard let place = place else {
                        print("Mekan bilgileri alınamadı.")
                        return
                    }
                    
                    // Mekanın türlerini kontrol et ve listeye ekle
                    if let types = place.types, types.contains("food") || types.contains("cafe") || types.contains("restaurant") || types.contains("bar") {
                        self.placeList.append(place)
                    }
                    
                    // TableView'i güncelle
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
            }
        }
    }*/





  
}
