//
//  PlaceListViewController.swift
//  Map-Place-App
//
//  Created by Teyfik Yılmaz on 8.05.2024.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import Combine


class PlaceListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{
  
  var locationManager: CoreLocationManager!
  var currentLocation: CLLocation?
  var placesClient: GMSPlacesClient!
  private let viewModel = PlaceListViewModel.instance
  private var cancelable : Set<AnyCancellable> = []

  private let tableView: UITableView = {
    let table = UITableView()
    table.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
    return table
  }()
  
  override func viewWillAppear(_ animated: Bool) {
    
    if viewModel.placeList.isEmpty{
      viewModel.listLikelyPlaces(tableView: self.tableView, placesClient: self.placesClient)
    }
  }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Clear place list when view disappears
        viewModel.placeList = []
    }
    override func viewDidAppear(_ animated: Bool) {
        viewModel.filterModel.$categories.sink { _ in
                // Fetch places when categories change
                self.viewModel.fetchPlaces()
            }.store(in: &cancelable)
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager = CoreLocationManager()
    placesClient = GMSPlacesClient.shared()
    view.addSubview(tableView)
    tableView.backgroundColor = .white
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(PlaceCell.nib(), forCellReuseIdentifier: PlaceCell.identifier)
    
      viewModel.$placeList.sink { [weak self] places in
        self?.tableView.reloadData()
      }.store(in: &cancelable)
      
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.viewModel.placeList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.identifier, for: indexPath) as! PlaceCell
      print("name: \(self.viewModel.placeList[indexPath.row].name ??  "Place")")
    cell.placeNameLabel.text = self.viewModel.placeList[indexPath.row].name
    cell.placeDetailLabel.text = self.viewModel.placeList[indexPath.row].formattedAddress
    if let image = self.viewModel.placeList[indexPath.row].photos?.first{
      self.placesClient.loadPlacePhoto(image) { (photo, error) in
        if let error = error{
          print("Error loading photo metadata: \(error.localizedDescription)")
          return
        } else{
          cell.placeDetailImage.image = photo
        }
      }
    }
    return cell
  }

  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let detailVC = PlaceDetailViewController()
      detailVC.name = self.viewModel.placeList[indexPath.row].name ?? "Test"
      detailVC.type = self.viewModel.placeList[indexPath.row].types?.first ?? "Test"
      detailVC.score = String(self.viewModel.placeList[indexPath.row].rating)
      detailVC.desc = self.viewModel.placeList[indexPath.row].description
      navigationController?.pushViewController(detailVC, animated: true)
      
      
//      let locationLat = self.viewModel.placeList[indexPath.row].coordinate.latitude
//    let locationLong = self.viewModel.placeList[indexPath.row].coordinate.longitude
//    
//    if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)){
//      
//      if let url = URL(string: "comgooglemaps-x-callback://??saddr=&addr=\(locationLat),\(locationLong)&directionsmode=driving") {
//        UIApplication.shared.open(url,options: [:])
//      }
//    } else {
//      if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(locationLat),\(locationLong)&directionsmode=driving"){
//        UIApplication.shared.open(urlDestination)
//        
//      }
//    }
    
  }
  
}



