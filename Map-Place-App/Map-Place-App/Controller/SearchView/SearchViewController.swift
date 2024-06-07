//
//  SearchViewController.swift
//  Location-Search
//
//  Created by Osmancan Akagündüz on 3.04.2024.
//

import UIKit
import CoreLocation

protocol SearchLocationViewControllerDelegate : AnyObject{
  func didTapPlaceWithCoordinate(with coordinates: CLLocationCoordinate2D)
}


class SearchViewController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var places: [Place] = []
    var isLoadLocations : Bool = false
    weak var delegate : SearchLocationViewControllerDelegate?

    @IBOutlet weak var clearHistoryButton: UIButton!
    
    var historyPlace : [SearchPlaceModel] =  []
    
    func fetchHistoryPlaces() {
        let userDefaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
        if let data = userDefaults.data(forKey: "historyPlace"),
           var decodedArray = try? decoder.decode([SearchPlaceModel].self, from: data) {
            decodedArray.reverse()
            historyPlace = decodedArray
            
        } else {
            historyPlace = []
        }
        
        self.menuTableView.reloadData() // Assuming menuTableView is a UITableView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.register(SearchTableViewCell.nib(), forCellReuseIdentifier: SearchTableViewCell.identifier)
        fetchHistoryPlaces()
        clearHistoryButton.addTarget(self, action: #selector(clearHistoryPlaces), for: .touchUpInside)
    }
    
   @objc func clearHistoryPlaces(_ sender: UIButton)  {
       print("clicked")
        historyPlace = []
        self.menuTableView.reloadData()
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "historyPlace")
          
    }

  
}


extension SearchViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            isLoadLocations = false
            self.menuTableView.reloadData()
        }
        guard let query = searchBar.text,
                 !query.trimmingCharacters(in: .whitespaces).isEmpty else {
             return
           }
        DispatchQueue.main.async {
            GooglePlacesManeger.shared.findPlaces(query: query) { result in
              switch result{
              case .success(let places):
                self.isLoadLocations = true
                self.menuTableView.isHidden = false
                self.places = places
                self.menuTableView.reloadData()
                
                
              case .failure(let error):
                print(error)
              }
            }
        }
              }
    
}

extension SearchViewController : UITableViewDelegate , UITableViewDataSource {
   
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoadLocations ? places.count : historyPlace.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        
        if(isLoadLocations){
            cell.handleCell( name: places[indexPath.row].name, image: "location")

        }else{
            cell.handleCell(name: historyPlace[indexPath.row].name, image: "clock")

        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isLoadLocations ? 1 : 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isLoadLocations ? "": "Geçmiş"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = (view as! UITableViewHeaderFooterView)
        headerView.textLabel?.font.withSize(60)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.isHidden = true
        
        let place = isLoadLocations ? places[indexPath.row] : Place(name: historyPlace[indexPath.row].name, identifier: "-")
    
        GooglePlacesManeger.shared.resolveLocation(for: place) {[weak self] result in
            switch result {
            case .success(let coordinate ):
                DispatchQueue.main.async{ [self] in
                    self?.delegate?.didTapPlaceWithCoordinate(with: coordinate)
                    
                    self?.addHistoryPlace(name: place.name, coordinate: coordinate)
                   
                    
                }
            case .failure(let error):
                print("Error resolving location: \(error.localizedDescription)")
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let view = storyboard.instantiateViewController(withIdentifier: "LocationSelectionViewController") as? LocationSelectionViewController{
                //view.isLocationSelected = true
                //view.locationName = place.name
                if whichTextField[0] {
                    print(" TEXT 1 OKAY !!!!!")
                    view.locationSelectionView.enterLocationTextField[0].text = place.name
                    view.viewModel.setFirstLocation(value: place.name)
                    firstLocation = place.name
                    if whichTextField[1]{
                        view.isLocationSelected = true
                    }
                    whichTextField = [false,false]
                    
                    
                    
                }
                else if whichTextField[1] {
                    print(" TEXT 2 OKAY !!!!!")
                    view.locationSelectionView.enterLocationTextField[1].text = place.name
                    view.viewModel.setSecondLocation(value: place.name)
                    secondLocation = place.name
                    view.isLocationSelected = true
                    if whichTextField[0]{
                        view.isLocationSelected = true
                    }
                    whichTextField = [false,false]

                }
                self?.navigationController?.pushViewController(view, animated: true)
            }
        }
    }

    func addHistoryPlace(name: String, coordinate: CLLocationCoordinate2D) {
        let userDefaults = UserDefaults.standard
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        var array: [SearchPlaceModel] = []
        
        if let data = userDefaults.data(forKey: "historyPlace"),
           let decodedArray = try? decoder.decode([SearchPlaceModel].self, from: data) {
            array = decodedArray
        }
        
        
        let isContain = array.contains { $0.name == name }
        

        if !isContain  {
            array.append(SearchPlaceModel(name: name, coordinate: coordinate))
        }
        
        
        
        if let encodedData = try? encoder.encode(array) {
            userDefaults.set(encodedData, forKey: "historyPlace")
        }
        
       
    }
        
        
}


