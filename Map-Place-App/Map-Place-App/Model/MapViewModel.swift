//
//  MapViewModel.swift
//  Map-Place-App
//
//  Created by Teyfik Yılmaz on 9.05.2024.
//



import Foundation
import CoreLocation

final class MapViewModel {
    
   static let instance : MapViewModel = MapViewModel()
    
  @Published  var firstLocation : String?
  @Published  var secondLocation : String?
  @Published  var isClickedEnterLocations : Bool?
  @Published  var firstCoordinate : CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
  @Published  var secondCoordinate : CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
   
    
    func clearLocations()  {
        firstLocation = nil
        secondLocation = nil
        firstCoordinate =  CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        secondCoordinate =   CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    }
    
    func setFirstLocation(value:String)  {
    
        firstLocation = value
        print("bambam1")

        CoreLocationManager.instance.formatLocationName(in: firstLocation!) { locationName in
            let url = self.generateGeocodeUrl(location_name: locationName)
            print("bambam1")
            
            CoreLocationManager.instance.resolveCoordinates(loca: &(self.firstCoordinate)!, url_string: url)
        }
       
       
        
    }
    
    func setSecondLocation(value:String)  {
        secondLocation = value
        print("bambam1")

        CoreLocationManager.instance.formatLocationName(in: secondLocation!) { locationName in
            let url = self.generateGeocodeUrl(location_name: locationName)
            print("bambam1")

            CoreLocationManager.instance.resolveCoordinates(loca: &(self.secondCoordinate)!, url_string: url)
        }
        
        
    }
    
    func setIsClıckedValue()  {
        isClickedEnterLocations = true
    }
    
    func generateGeocodeUrl(location_name : String) -> String{
        guard let apiKey = ApiManager.apiKey else {
            fatalError("Google Maps API anahtarı eksik veya yanlış konumda")
        }
        return "https://maps.googleapis.com/maps/api/geocode/json?address=\(location_name)&key=\(apiKey)"
    }
    
}
