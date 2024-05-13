//
//  PlaceDetailViewController.swift
//  Map-Place-App
//
//  Created by Bartuğ Kaan Çelebi on 13.05.2024.
//

import UIKit

class PlaceDetailViewController: UIViewController {

    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var detailTypeLabel: UILabel!
    @IBOutlet weak var detailScoreLabel: UILabel!
    @IBOutlet weak var detailAddressLabel: UILabel!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var name = " "
    var type = " "
    var score = " "
    var address = " "
    var desc = " "
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.detailNameLabel.text = name
        self.detailTypeLabel.text = type
        self.detailScoreLabel.text = score
        self.detailAddressLabel.text = address
        self.detailDescriptionLabel.text = desc
        
    }
    

    @IBAction func oepnMapTapped(_ sender: Any) {
    }
    

}
