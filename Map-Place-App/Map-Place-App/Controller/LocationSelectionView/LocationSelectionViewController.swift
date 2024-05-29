//
//  LocationSelectionViewController.swift
//  Map-Place-App
//
//  Created by Teyfik Yılmaz on 8.05.2024.
//


import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import Combine
import CoreLocation
var buttonIndex = 0
var firstLocation = "-1"
class LocationSelectionViewController : UIViewController, LocationSelectionViewDelegate{
    // MARK: - Properties
    var stringURL = ""
    var filterModel : FilterModel = FilterModel.instance
    var placeModel = PlaceListViewModel.instance
    var locationName = "error"
    var isLocationSelected = false

    var polylines: [GMSPolyline] = []
    var markers: [GMSMarker] = []
    
    var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var zoom: Float = 15
    let locationSelectionView = LocationSelectionView()
    private let viewModel : MapViewModel = MapViewModel.instance
    private var cancelable : Set<AnyCancellable> = []
    private let coreLocationManager : CoreLocationManager = CoreLocationManager.instance
    
    let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ara", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
  
    let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Filtrele", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        style()
        layout()
        locationSelectionView.searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        locationSelectionView.filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        locationSelectionView.delegate = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward") , style: .plain, target: self, action: #selector(didTappedBackButton))
        setPlaces()
        setURL()

    }
}
//MARK: - Helpers
extension LocationSelectionViewController {
    func style(){
        view.addSubview(locationSelectionView)
        locationSelectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    func layout(){
        NSLayoutConstraint.activate([
            locationSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            locationSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationSelectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            locationSelectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.65), // İstediğiniz yüksekliği ayarlayın
            
      
        ])
    }
    
    func setupBinders() {
        removeAllMarkers()
        
        viewModel.$isClickedEnterLocations.sink { value in
            self.buildMarker(position: self.viewModel.firstCoordinate!, title: "First Location")
            self.buildMarker(position: self.viewModel.secondCoordinate!, title: "Second Location")
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
    
    @objc func searchButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let searchViewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController// Replace with your initialization
        
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    @objc func filterButtonTapped(_ sender: UIButton) {
        let placeListViewController = PlaceListViewController() // Replace with your initialization
        if let name = locationSelectionView.key_word_tex_field.text{
            if name == ""{
                filterModel.setKeyWord(value:  "-1")
            } else{
                filterModel.setKeyWord(value: locationSelectionView.key_word_tex_field.text ?? "-1")
            }
        } else {
            filterModel.setKeyWord(value:  "-1")
        }
        
        filterModel.setDistanve(value: Double(locationSelectionView.distance_slider.value))
        
        filterModel.printValues()
        self.navigationController?.pushViewController(placeListViewController, animated: true)
    }
    func setPlaces(){
       
        if isLocationSelected{
            if buttonIndex == 0 {
                locationSelectionView.enterLocationTextField[buttonIndex].text = locationName
                firstLocation = locationName
                viewModel.isClickedEnterLocations = false
            }else {
                locationSelectionView.enterLocationTextField[buttonIndex].text = locationName
                locationSelectionView.enterLocationTextField[0].text = firstLocation
            }
            buttonIndex = buttonIndex + 1
            if buttonIndex > 1 {
                buttonIndex = 0
                viewModel.setSecondLocation(value: locationName)
                viewModel.setIsClıckedValue()
            }else {
                viewModel.setFirstLocation(value: locationName)
            }
            
        }
        
    }
}
//MARK: - Map Helpers
extension LocationSelectionViewController {
    
    private func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude:  37.7749, longitude: -122.4194, zoom: zoom)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.35), camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
        mapView?.settings.rotateGestures = true
        mapView?.settings.zoomGestures = true
        view = mapView

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        marker.title = "San Francisco"
        marker.snippet = "California, USA"
        marker.map = mapView
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
    
    func buildMarker(position: CLLocationCoordinate2D , title: String) {
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
//MARK: - CLLocationManagerDelegate
extension LocationSelectionViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last{
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            setupMap()

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
}
//MARK: - LocationSelectionViewDelegate
extension LocationSelectionViewController{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        locationSelectionView.textFieldShouldBeginEditing(textField)
    }
    func navigateToPlaceListViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchViewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController// Replace with your initialization
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
}
//MARK: - NavBar Funcitons
extension LocationSelectionViewController {
    @objc func didTappedBackButton(){
        self.navigationController?.popToRootViewController(animated: true)
    }
}
//MARK: - JSON extensions
extension LocationSelectionViewController {
    func decodeJSON(jsonData: Data) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        
        do {
            let routeResponse = try JSONDecoder().decode(RouteResponse.self, from: jsonData)
                for route in routeResponse.routes {
                        for leg in route.legs {
                            for step in leg.steps {
                                var loc = CLLocationCoordinate2D()
                                loc = .init(latitude : step.end_location.lat, longitude: step.end_location.lng)
                                coordinates.append(loc)
                            }
                        }
                    }
        
                
        } catch {
            print("Hata oluştu: \(error)")
        }
        
        return coordinates
    }
    
    func fetchJSONData(from urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching JSON: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            completion(data)
        }.resume()
    }
    
    func printLocations(){
        fetchJSONData(from: stringURL) { data in
            guard let jsonData = data else {
                print("Failed to fetch JSON data")
                return
            }
            
            let coordinates = self.decodeJSON(jsonData: jsonData)
            for coordinate in coordinates {
                print("Coordinates: \(coordinate.latitude), \(coordinate.longitude)")
                self.placeModel.coordinateList.append(coordinate)
            }
        }
    }
    
    func setURL() {
        if viewModel.isClickedEnterLocations ?? false {
            guard let firstLatitude = viewModel.firstCoordinate?.latitude,
                  let firstLongitude = viewModel.firstCoordinate?.longitude,
                  let secondLatitude = viewModel.secondCoordinate?.latitude,
                  let secondLongitude = viewModel.secondCoordinate?.longitude else {
                print("Koordinatlar bulunamadı.")
                return
            }

            let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(firstLatitude),\(firstLongitude)&destination=\(secondLatitude),\(secondLongitude)&sensor=false&mode=driving&key=\(APIKeyProvider.googleMapsAPIKey)"
            stringURL = url
            print(stringURL)
            printLocations()
        }
    }
}
