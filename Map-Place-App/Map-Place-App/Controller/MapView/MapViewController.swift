//
//  MapViewController.swift
//  Location-Search
//
//  Created by Osmancan Akagündüz on 3.04.2024.
//

import UIKit
import MapKit
import GoogleMaps
import CoreLocation
import Combine
class MapViewController: UIViewController {

    var polylines: [GMSPolyline] = []
    var markers: [GMSMarker] = []

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var googleMapsView: UIView!
    var locationManager = CLLocationManager()
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var mapView : GMSMapView?
    var zoom: Float = 15
      
    private let viewModel : MapViewModel = MapViewModel.instance
    private var cancelable : Set<AnyCancellable> = []
    private let coreLocationManager : CoreLocationManager = CoreLocationManager.instance
    
    private let textField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.placeholder = "Metin girin..."
        
        return textField
    }()
    
    override func viewDidLoad() {
       super.viewDidLoad()
       locationManager.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
                locationManager.requestWhenInUseAuthorization()
            }else{
                locationManager.startUpdatingLocation()
            }
    setupBinders()
    }
    
      @IBAction func zoomIn(_ sender: Any) {
          zoom += 1
          mapView?.animate(toZoom: zoom)
      }
      
      @IBAction func zoomOut(_ sender: Any) {
          zoom -= 1
          mapView?.animate(toZoom: zoom)
      }

}

extension MapViewController : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        _ = UIStoryboard(name: "Main", bundle: nil)
        let searchViewController = LocationSelectionViewController()
        Lat = self.latitude
        Long  = self.longitude
        self.navigationController?.pushViewController(searchViewController, animated: true)
        searchBar.resignFirstResponder()

    }
}

extension MapViewController : CLLocationManagerDelegate {
    
   
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            buildMapView()
           
            buildMarker(position: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), title: "Me")
            
           
      }
    }
    
   
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            print("location permission denied")
        }
    }
 
    func buildMapView()  {
        removeAllMarkers()
        //MARK: - Crating Google Maps
        let camera = GMSCameraPosition.camera(withLatitude:  latitude!, longitude: longitude!, zoom: zoom)
        mapView = GMSMapView.map(withFrame: self.googleMapsView.bounds, camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
        mapView?.settings.rotateGestures = true
        mapView?.settings.zoomGestures = true
        if let mapView = mapView {
              googleMapsView.addSubview(mapView)
        }
        
    }
    
    func setupBinders() {
        removeAllMarkers()
        
        viewModel.$isClickedEnterLocations.sink { value in
            
        
            self.buildMarker(position: self.viewModel.firstCoordinate, title: "First Location")
            self.buildMarker(position: self.viewModel.secondCoordinate, title: "Second Location")
            if value != nil {
                
                PlaceListViewModel.instance.fetchPlaces()
                
                self.coreLocationManager.formatLocationName(in: self.viewModel.firstLocation ?? "") { origin in
                    self.coreLocationManager.formatLocationName(in: self.viewModel.secondLocation ?? "") { destination in
                        self.coreLocationManager.updateUIView({ points in
                             self.addPolyLineWithEncodedStringInMap(encodedString: points)
                        }, origin: origin,destination: destination)
                    }
                }
                
                
            }

        }.store(in: &cancelable)
    }

    
    
    func addPolyLineWithEncodedStringInMap(encodedString: String) {
        for polyline in polylines {
            polyline.map = nil
        }
        polylines.removeAll()

        let path = GMSMutablePath(fromEncodedPath: encodedString)
        //print(path)
        
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 5
        polyLine.strokeColor = .red
        polyLine.map = mapView
        
        polylines.append(polyLine)
        
        let mapBounds = GMSCoordinateBounds(path: path!)
        let cameraUpdate = GMSCameraUpdate.fit(mapBounds)
        self.mapView?.moveCamera(cameraUpdate)
        

        }
    
    func buildMarker(position: CLLocationCoordinate2D? , title: String) {
        guard let position = position else {
            return
        }
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        marker.map = mapView
        
        markers.append(marker)
    }

    func removeAllMarkers(){
        for marker in markers{
            marker.map = nil
        }
        markers.removeAll()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Error at " +  #function + ", Error code: \(error)")
    }
    
}
