//
//  PlaceListDetailViewController.swift
//  Map-Place-App
//
//  Created by Teyfik Yılmaz on 8.05.2024.
//

import Foundation
import UIKit

class PlaceListDetailViewController: UIViewController {
    //var placeArray = [Place]()
    @IBOutlet weak var searchbarView: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceCell.nib(), forCellReuseIdentifier: PlaceCell.identifier)
        tableView.separatorColor = .clear
        searchbarView.delegate = self
    }
}

//MARK: - TableView Delegate and DataSource
extension PlaceListDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.identifier, for: indexPath) as! PlaceCell
        //Veriye Göre değişicek
        cell.placeNameLabel.text = "Place \(indexPath.row + 1)"
        cell.placeDetailImage.image = UIImage(systemName: "house")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       
    }
    
}

extension PlaceListDetailViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //TODO: Arraydeki elemanlardan isim araması yapıp tableView'ı reload edicek
    }
}
