//
//  PlaceCellView.swift
//  Location-Search
//
//  Created by Bartuğ Kaan Çelebi on 7.03.2024.
//

import UIKit
import GoogleMaps
import GooglePlaces

class PlaceCellView: UITableViewCell {
  @IBOutlet weak var placeImageView: UIImageView!
  @IBOutlet weak var placeNameLabel: UILabel!
  @IBOutlet weak var placeAddressLabel: UILabel!
  @IBOutlet weak var placeRatingLabel: UILabel!
  
  static let identifier = "placeCell"
  
  static func nib() -> UINib{
    return UINib(nibName: "PlaceCellView", bundle: nil)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .none
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
}
