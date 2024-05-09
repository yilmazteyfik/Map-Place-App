//
//  SearchViewController.swift
//  Location-Search
//
//  Created by Osmancan Akagündüz on 3.04.2024.
//

import UIKit


class SearchViewController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    
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
        print(searchText)
    }
    
}

extension SearchViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        cell.handleCell(model: data[indexPath.section][indexPath.row])
        
        
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     return  section == 0 ? "" : "Geçmiş"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = (view as! UITableViewHeaderFooterView)
        headerView.textLabel?.font.withSize(60)
    }
}


