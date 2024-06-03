


//
//  Filter.swift
//  Map-Place-App
//
//  Created by Teyfik Yılmaz on 9.05.2024.
//

import Foundation


struct Category {
    let name: String
    var flag: Bool
    
    init(name: String, flag: Bool) {
        self.name = name
        self.flag = flag
    }
}
final class FilterModel {
    static let instance : FilterModel = FilterModel()
    @Published var categories: [Category]
    @Published var key_word : String = "-1"
    @Published var distance : Double = -1
    
    
    fileprivate func initCategories() {
        categories.append(Category(name: "restaurant", flag: false))
        categories.append(Category(name: "cafe", flag: false))
        categories.append(Category(name: "bar", flag: false))
        categories.append(Category(name: "pub", flag: false))
        categories.append(Category(name: "fast_food", flag: false))
        categories.append(Category(name: "fine_dining", flag: false))
        categories.append(Category(name: "bakery", flag: false))
        categories.append(Category(name: "ice_cream_shop", flag: false))
    }
    
    init() {
        self.categories = []
        initCategories()
        
    }
    func setKeyWord(value : String){
        key_word = value
    }
    func setDistanve(value : Double){
        distance = value
    }
    func setCatagory(index : Int , flag_tag : Bool){
        categories[index].flag = flag_tag
    }
    func printValues(){
        for category in categories {
            if category.flag {
                print(category.name)
            }
        }
        print("key word : \(key_word)")
        print("distance : \(distance)")
    }
    
    func clearAll()  {
        self.categories.removeAll()
        self.initCategories()
        self.key_word = "-1"
        self.distance = -1
    }

}
