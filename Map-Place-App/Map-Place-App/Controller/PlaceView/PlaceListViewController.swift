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
    var currentPage = 0
    let pageSize = 20
    var displayedPlaces: [GMSPlace] = [] // Bu ekranda gösterilen veriler

  private let tableView: UITableView = {
    let table = UITableView()
    table.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
    return table
  }()
  
  override func viewWillAppear(_ animated: Bool) {
      
      if viewModel.placeList.isEmpty && viewModel.coordinateList.isEmpty{
        self.viewModel.listLikelyPlaces(tableView: self.tableView, placesClient: self.placesClient)
        self.viewModel.removeDublicationPlaceList()
    }
      viewModel.filterModel.$categories.sink { _ in
              // Fetch places when categories change
          self.viewModel.placeList.removeAll()
          self.viewModel.filterPlace(tableView: self.tableView)
          self.viewModel.removeDublicationPlaceList()
          }.store(in: &cancelable)
  }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Clear place list when view disappears
        viewModel.placeList = []
    }
    override func viewDidAppear(_ animated: Bool) {
        
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
    
      
      loadMoreData()
      
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return displayedPlaces.count
  }
  
    func handlePlacePhoto( place: GMSPlace , onComplete:@escaping (UIImage?) -> () ) {
        if let image = place.photos?.first{
            
            self.placesClient.loadPlacePhoto(image) { (photo, error) in
                if let error = error{
                    print("Error loading photo metadata: \(error.localizedDescription)")
                    
                } else{
                    onComplete(photo)
                }
            }
        }
         
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.identifier, for: indexPath) as! PlaceCell
      //print("name: \(self.viewModel.placeList[indexPath.row].name ??  "Place")")
      let place = displayedPlaces[indexPath.row]
      cell.placeNameLabel.text = place.name
    cell.placeDetailLabel.text = place.formattedAddress
        self.handlePlacePhoto(place: place) { image in
            cell.placeDetailImage.image = image
        }
    return cell
  }
    func loadMoreData() {
            let start = currentPage * pageSize
        let end = min(start + pageSize, viewModel.placeList.count)
            
            guard start < end else { return }
            
        let newPlaces = viewModel.placeList[start..<end]
            displayedPlaces.append(contentsOf: newPlaces)
            currentPage += 1
            
            tableView.reloadData()
        }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height
            
            if offsetY > contentHeight - height {
                loadMoreData()
            }
        }

  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
      let storyboard = UIStoryboard(name: "Main", bundle: nil)

      let placeDetailView = storyboard.instantiateViewController(withIdentifier: PlaceDetailViewController.identifier) as! PlaceDetailViewController
      
      let place =  self.viewModel.placeList[indexPath.row]
      
      print(place)
      
      placeDetailView.name = place.name
      placeDetailView.type = place.types?.first?.capitalized
      placeDetailView.score = place.rating
      placeDetailView.address = place.formattedAddress
      placeDetailView.desc = place.website?.absoluteString
      placeDetailView.ratingCount = place.userRatingsTotal
      placeDetailView.coordinate = place.coordinate
      self.handlePlacePhoto(place: place) { image in
          placeDetailView.image = image
      }
     // placeDetailView.image = handlePlacePhoto(place: place)
      
      
      self.navigationController?.pushViewController(placeDetailView, animated: true)

    
  }
  
}



