//
//  CoreLocationManagert.swift
//  Location-Search
//
//  Created by Osmancan Akagündüz on 4.04.2024.
//

import Foundation

//
//  CoreLocationManager.swift
//  Location-Search
//
//  Created by Teyfik Yılmaz on 28.02.2024.
//

import Foundation
import CoreLocation
import GoogleMaps

class CoreLocationManager: NSObject, CLLocationManagerDelegate{
    let locationManager = CLLocationManager()
    static let instance : CoreLocationManager = CoreLocationManager()
    
    
        
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 50
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      let location: CLLocation = locations.last!
      print("Location: \(location)")

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      // Check accuracy authorization
      let accuracy = manager.accuracyAuthorization
      switch accuracy {
      case .fullAccuracy:
          print("Location accuracy is precise.")
      case .reducedAccuracy:
          print("Location accuracy is not precise.")
      @unknown default:
        fatalError()
      }
    

      // Handle authorization status
      switch status {
      case .restricted:
        print("Location access was restricted.")
      case .denied:
        print("User denied access to location.")
        // Display the map using the default location.
       
      case .notDetermined:
        print("Location status not determined.")
      case .authorizedAlways: fallthrough
      case .authorizedWhenInUse:
        print("Location status is OK.")
      @unknown default:
        fatalError()
      }
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      locationManager.stopUpdatingLocation()
      print("Error here: \(error)")
    }
    
    private func updateMapView(onComplete :@escaping (String)-> () , origin:String , destination:String)  {
        guard let apiKey = ApiManager.apiKey else {
            fatalError("Google Maps API anahtarı eksik veya yanlış konumda")
        }
        
        let directionsURL : String = "https://maps.googleapis.com/maps/api/directions/json?origin=\(String(describing: origin))&destination=\(String(describing: destination))&key=\(apiKey)"
        
        guard let url = URL(string: directionsURL) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }
            DispatchQueue.main.async {
                do {
                   
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let routes = json["routes"] as? [[String: Any]] {
                            if let route = routes.first, let overviewPolyline = route["overview_polyline"] as? [String: Any], let points = overviewPolyline["points"] as? String {
                               
                                onComplete(points)
                            }
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
           
        }

        task.resume()
    }
    
    func updateUIView(_ onComplete : @escaping (String)-> (),origin:String , destination:String) {
            updateMapView(onComplete: onComplete, origin: origin , destination: destination)
    }
    
    func formatLocationName(in string: String , onComplete: @escaping (String)->() )  {
        let turkishCharacters: [Character: Character] = [
            "ç": "c", "ğ": "g", "ı": "i", "ö": "o", "ş": "s", "ü": "u",
            "Ç": "C", "Ğ": "G", "İ": "I", "Ö": "O", "Ş": "S", "Ü": "U"
        ]
        var replacedString = string
        turkishCharacters.forEach { (oldChar, newChar) in
            replacedString = replacedString.replacingOccurrences(of: String(oldChar), with: String(newChar))
        }
        replacedString = replacedString.replacingOccurrences(of: " ", with: "%20")
        
        onComplete(replacedString)
    }
    
    
    func resolveCoordinates(loca : inout CLLocationCoordinate2D, url_string : String){
        guard let url = URL(string: url_string) else {
            print("Invalid URL geo")
            return
        }
        
        
        let data = try! Data(contentsOf: url)
            let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            if let result = json["results"] as? [[String: Any]] {
                if let geometry = result[0]["geometry"] as? [String: Any] {
                    if let location = geometry["location"] as? [String: Any] {
                        print("girdi 6")
                        let latitude = location["lat"] as! NSNumber
                        let longitude = location["lng"] as! NSNumber
                        print("\nlatitude: \(latitude), longitude: \(longitude)")
                        loca.latitude = latitude.doubleValue
                        loca.longitude = longitude.doubleValue
                    }
                }
            }
    }
}
