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


    let data = [[SearchMenuModel(name: "Konumunuz", image: "location"),SearchMenuModel(name: "Haritadan seç", image: "rectangle.and.hand.point.up.left"),], [SearchMenuModel(name: "İstanbul Söğütlüçeşme", image: "clock"),SearchMenuModel(name: "İstanbul Söğütlüçeşme", image: "clock"),SearchMenuModel(name: "İstanbul Söğütlüçeşme", image: "clock"),SearchMenuModel(name: "İstanbul Söğütlüçeşme", image: "clock"),SearchMenuModel(name: "İstanbul Söğütlüçeşme", image: "clock"),]]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.register(SearchTableViewCell.nib(), forCellReuseIdentifier: SearchTableViewCell.identifier)
     
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
        return isLoadLocations ? places.count : data[section].count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        
        if(isLoadLocations){
            cell.handleCell(model: SearchMenuModel(name: places[indexPath.row].name, image: "location"))

        }else{
            cell.handleCell(model:  data[indexPath.section][indexPath.row])

        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isLoadLocations ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isLoadLocations ? "":( section == 0 ? "" : "Geçmiş")
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = (view as! UITableViewHeaderFooterView)
        headerView.textLabel?.font.withSize(60)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
         
         tableView.isHidden = true
         
         let place = places[indexPath.row]
         GooglePlacesManeger.shared.resolveLocation(for: place) {[weak self] result in
           
             switch result {
               
           case .success(let coordinate ):
             
               DispatchQueue.main.async{
               self?.delegate?.didTapPlaceWithCoordinate(with: coordinate)
             }
           case .failure(let error):
             print(error)
           }
             
         /*  if let locVC = self?.navigationController?.viewControllers[1] as? LocationsViewController {
             locVC.isLocationSelected = true
             locVC.locationName = place.name
             
           }
          self?.navigationController?.popViewController(animated: true)

          */
         }
         
         
       }
}


