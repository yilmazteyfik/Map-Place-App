//
//  PlaceDetailViewController.swift
//  Map-Place-App
//
//  Created by Bartuğ Kaan Çelebi on 13.05.2024.
//

import UIKit
import CoreLocation
class PlaceDetailViewController: UIViewController {

    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var detailTypeLabel: UILabel!
    @IBOutlet weak var detailScoreLabel: UILabel!
    @IBOutlet weak var detailAddressLabel: UILabel!
    @IBOutlet weak var webSiteLabel: UILabel!
    
    var name : String?
    var type : String?
    var score : Float?
    var address : String?
    var desc : String?
    var image : UIImage?
    var ratingCount : UInt?
    var coordinate : CLLocationCoordinate2D?
    
    static let identifier = String(describing: PlaceDetailViewController.self)


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
     func setup(){
         if let image = image {
             self.detailImage.image = image
             print("Image: \(image)")
         }
         self.detailNameLabel.text = name
         if let type = type {
             self.detailTypeLabel.text = "Type: \(type)"
         }
         if let score = score , let ratingCount = ratingCount {
             self.detailScoreLabel.text = "\(score) (\(ratingCount) review) "
         }
         if let address = address {
             self.detailAddressLabel.text = "Address: \(address)"
         }
         
         if let webSite = desc {
             self.webSiteLabel.text = "Website: \(webSite)"

         }
   }
    

    @IBAction func oepnMapTapped(_ sender: Any) {
        guard (self.coordinate?.latitude) != nil else {
            return
        }
        
        guard (self.coordinate?.longitude) != nil else {
            return
        }
        let locationLat = self.coordinate!.latitude
        let locationLong = self.coordinate!.longitude
      
        print("Latitude: \(locationLat)")
        print("Longitude: \(locationLong)")
        
      if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)){
        
          if let url = URL(string: "comgooglemaps-x-callback://??saddr=&addr=\(String(describing: locationLat)),\(String(describing: locationLong))&directionsmode=driving") {
          UIApplication.shared.open(url,options: [:])
        }
      } else {
          if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(String(describing: locationLat)),\(String(describing: locationLong))&directionsmode=driving"){
          UIApplication.shared.open(urlDestination)
          
        }
      }
    }
    

}
