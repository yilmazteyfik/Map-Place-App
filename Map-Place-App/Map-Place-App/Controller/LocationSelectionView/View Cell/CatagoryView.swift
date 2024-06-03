//
//  CatagoryView.swift
//  Map-Place-App
//
//  Created by Teyfik Yılmaz on 9.05.2024.
//


import Foundation
import UIKit

class CategoryView: UIView {
  // MARK: - Properties
    var filterModel : FilterModel = FilterModel.instance
  private let categories: [String] = [
    "Restoran",
    "Kafe",
    "Bar",
    "Pub",
    "Fast food",
    "Gurme restoran",
    "Pastane",
    "Dondurma dükkanı"
  ]

  private var checkboxes: [Checkbox] = []
    

  // MARK: - Initialization

  init() {
    super.init(frame: .zero)
    style()
    layout()

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }



}
// MARK: - Helpers
extension CategoryView {
    func style(){
        self.backgroundColor = .systemGray6 // Set background color to pink
        self.layer.cornerRadius = 12

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 0 // Initial opacity set to 0
        setupSubviews()
    }
    func layout(){
        var topAnchor = self.topAnchor

        for checkbox in checkboxes {
          checkbox.translatesAutoresizingMaskIntoConstraints = false
          checkbox.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
          checkbox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
          topAnchor = checkbox.bottomAnchor // Update top anchor for next checkbox
        }
    }
    private func setupSubviews() {
      for (index, category) in categories.enumerated() {
        let checkBox = Checkbox(frame: CGRect(x: 30, y: 10 + index * 30, width: 20, height: 20)) // Adjust position and size
        checkBox.setTitle("  \(category)", for: .normal)
          checkBox.setTitleColor(.black, for: .normal)
        checkBox.addTarget(self, action: #selector(categorySelected(_:)), for: .touchUpInside)
        checkBox.tag = index // Set tag to identify the selected category
          //checkBox.setImage(UIImage(named: "square"), for: .normal)
          
          if let image = UIImage(named: "square") {
              let newSize = CGSize(width: 20, height: 20)
              UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
              image.draw(in: CGRect(origin: .zero, size: newSize))
              let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
              UIGraphicsEndImageContext()
              
              if let resizedImage = resizedImage {
                  checkBox.setImage(resizedImage, for: .normal)
              }
          }
          
          
        checkboxes.append(checkBox)
        addSubview(checkBox)
      }
    }
    // MARK: - Checkbox Action

    @objc func categorySelected(_ sender: Checkbox) {
      let selectedIndex = sender.tag
      let selectedCategory = categories[selectedIndex]
        filterModel.categories[selectedIndex].flag = checkboxes[selectedIndex].isChecked
        filterModel.printValues()
      print("Category selected: \(selectedCategory)")

      // Implement your logic here based on the selected category
    }
    func clearCheckBox(){
        for checkbox in self.checkboxes {
            checkbox.isChecked = false
        }
    }
}
