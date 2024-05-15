
//  CheckBox.swift
//  Location-Search
//
//  Created by Teyfik Yılmaz on 5.05.2024.
//

import Foundation
import UIKit
class Checkbox: UIButton {
    //MARK: - Properties
    var isChecked: Bool = false {
        didSet {
            if isChecked {
                if let image = UIImage(named: "check") {
                    let newSize = CGSize(width: 20, height: 20)
                    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                    image.draw(in: CGRect(origin: .zero, size: newSize))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    if let resizedImage = resizedImage {
                        setImage(resizedImage, for: .normal)
                    }
                }

            } else {
                if let image = UIImage(named: "square") {
                    let newSize = CGSize(width: 20, height: 20)
                    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                    image.draw(in: CGRect(origin: .zero, size: newSize))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    if let resizedImage = resizedImage {
                        setImage(resizedImage, for: .normal)
                    }
                }
            }
        }
    }
    // MARK: - Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)
        isChecked = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
//MARK: - Helpers
extension Checkbox {
    @objc private func toggleCheckbox() {
        isChecked = !isChecked
    }
    
    func setChecked(_ checked: Bool) {
        isChecked = checked
    }
}
