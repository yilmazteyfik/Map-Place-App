//
//  PlaceCell.swift
//  Location-Search
//
//  Created by Bartuğ Kaan Çelebi on 4.04.2024.
//

import UIKit

class PlaceCell: UITableViewCell {

    @IBOutlet weak var placeDetailImage: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeDetailLabel: UILabel!
    @IBOutlet weak var placeDetailButton: UIButton!
    
    static let identifier = "placeCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "PlaceCell", bundle: nil)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        placeDetailButton.addTarget(self, action: #selector(viewDetailTapped), for: .touchUpInside)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func viewDetailTapped(_ sender: UIButton) {
        
    }
}
