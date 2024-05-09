//
//  SearchTableViewCell.swift
//  Location-Search
//
//  Created by Osmancan Akagündüz on 29.04.2024.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    static let identifier = "searchCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func handleCell(model: SearchMenuModel)  {
        self.cellImage.image = UIImage(systemName: model.image)
        self.cellLabel.text = model.name
    }
    
    static func nib() -> UINib{
            return UINib(nibName: "SearchTableViewCell", bundle: nil)
        }
    
}
