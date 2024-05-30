import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import Combine

class PlaceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    var locationManager: CoreLocationManager!
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    private let viewModel = PlaceListViewModel.instance
    private var cancelable: Set<AnyCancellable> = []
    var currentPage = 0
    let pageSize = 20
    var displayedPlaces: [GMSPlace] = []

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
  
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleInitialPlaceLoad()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
      //  viewModel.placeList = []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        handleInitialPlaceLoad()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setupView() {
        locationManager = CoreLocationManager()
        placesClient = GMSPlacesClient.shared()
        
        view.addSubview(tableView)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceCell.nib(), forCellReuseIdentifier: PlaceCell.identifier)
        
        // Add activity indicator to the view
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func handleInitialPlaceLoad() {
        if viewModel.placeList.isEmpty && viewModel.coordinateList.isEmpty {
            activityIndicator.startAnimating() // Show activity indicator
            
            viewModel.listLikelyPlaces(tableView: tableView, placesClient: placesClient)
            viewModel.removeDublicationPlaceList()
        }
    }

    private func bindViewModel() {
        viewModel.$placeList
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.activityIndicator.startAnimating()

                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    self.activityIndicator.stopAnimating() // Hide activity indicator
                    self.displayedPlaces.removeAll()
                    self.currentPage = 0
                    self.loadMoreData()
                }
            }
            .store(in: &cancelable)

        viewModel.filterModel.$categories
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.placeList.removeAll()
                self.viewModel.filterPlace(tableView: self.tableView)
            }
            .store(in: &cancelable)
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedPlaces.count
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

    private func loadMoreData() {
        let start = currentPage * pageSize
        let end = min(start + pageSize, viewModel.placeList.count)
        
        guard start < end else {
            print("ERROR: start: \(start) end: \(end)")
            return
        }
        
        let newPlaces = viewModel.placeList[start..<end]
        displayedPlaces.append(contentsOf: newPlaces)
        tableView.reloadData()
        
        currentPage += 1
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
