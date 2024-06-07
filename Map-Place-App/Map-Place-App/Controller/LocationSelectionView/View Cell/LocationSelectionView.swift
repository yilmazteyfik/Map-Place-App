//
//  LocationSelectionView.swift
//  Map-Place-App
//
//  Created by Teyfik Yılmaz on 9.05.2024.
//



import Foundation
import UIKit


protocol LocationSelectionViewDelegate: AnyObject {
    func navigateToPlaceListViewController()
    func navigateToPlaceListViewController1()
}


class LocationSelectionView: UIView {
    var filterModel : FilterModel = FilterModel.instance

    
    // MARK: -Properties
    weak var delegate: LocationSelectionViewDelegate?
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white // İstediğiniz arka plan rengini ayarlayabilirsiniz
        return view
    }()
    let catagoryView = CategoryView()
    var enterLocationTextField = [UITextField]()
    
    let enterLocation1TextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Konum 1'i Giriniz"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        //textField.isUserInteractionEnabled = false // Disable user interaction
        return textField
    }()

    let enterLocation2TextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Konum 2'yi Giriniz"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        //textField.isUserInteractionEnabled = false // Disable user interaction
        return textField
    }()
    let key_word_tex_field: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter a key word:"
        textField.borderStyle = .roundedRect
        let blackColor = UIColor.black.cgColor
        textField.layer.borderColor = blackColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = true // Disable user interaction
        textField.layer.shadowColor = blackColor // Gölge rengi siyah
        textField.layer.shadowOffset = CGSize(width: 2, height: 2) // Gölge konumu
        textField.layer.shadowRadius = 2 // Gölge boyutu
        textField.layer.shadowOpacity = 0.5 // Gölge şeffaflığı
        return textField
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear // Arkaplan rengini değiştirebilirsiniz
        
        return scrollView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Location Selection"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0 // Metnin birden fazla satırda gösterilmesini sağlar
        return label
    }()
    let catagory_label: UILabel = {
        let label = UILabel()
        label.text = "Catagories"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0 // Metnin birden fazla satırda gösterilmesini sağlar
        return label
    }()
    let distance_label: UILabel = {
        let label = UILabel()
        label.text = "Distance :"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0 // Metnin birden fazla satırda gösterilmesini sağlar
        return label
    }()
    let key_word_label: UILabel = {
        let label = UILabel()
        label.text = "Enter a key word :"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0 // Metnin birden fazla satırda gösterilmesini sağlar
        return label
    }()
    var sliderValue = 0.0
    let distance_slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0 // Minimum 0 metre
        slider.maximumValue = 2000.0 // Maksimum 2000 metre (2 km)
        slider.value = 500.0 // Varsayılan değer 500 metre
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
      }()
    let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        let blackColor = UIColor.black.cgColor
        button.layer.borderColor = blackColor
        button.layer.shadowColor = blackColor // Gölge rengi siyah
        button.layer.shadowOffset = CGSize(width: 2, height: 2) // Gölge konumu
        button.layer.shadowRadius = 2 // Gölge boyutu
        button.layer.shadowOpacity = 0.5 // Gölge şeffaflığı

        return button
    }()

    let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Filtrele", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 12
        let blackColor = UIColor.black.cgColor
        button.layer.borderColor = blackColor
        button.layer.shadowColor = blackColor // Gölge rengi siyah
        button.layer.shadowOffset = CGSize(width: 2, height: 2) // Gölge konumu
        button.layer.shadowRadius = 2 // Gölge boyutu
        button.layer.shadowOpacity = 0.5 // Gölge şeffaflığı
        return button
    }()
    
    // MARK: - Lİfecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        enterLocation1TextField.delegate = self
        enterLocation2TextField.delegate = self
        enterLocationTextField.append(enterLocation1TextField)
        enterLocationTextField.append(enterLocation2TextField)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
extension LocationSelectionView {
    func style(){
        addSubview(bottomView)
        bottomView.addSubview(scrollView)
        scrollView.addSubview(label)
        scrollView.addSubview(enterLocation1TextField)
        scrollView.addSubview(enterLocation2TextField)
        scrollView.addSubview(clearButton)
        scrollView.addSubview(filterButton)
        scrollView.addSubview(catagoryView)
        scrollView.addSubview(catagory_label)
        scrollView.addSubview(distance_label)
        scrollView.addSubview(distance_slider)
        scrollView.addSubview(key_word_label)
        scrollView.addSubview(key_word_tex_field)
        // Auto Layout constraints ekleyin
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        enterLocation1TextField.translatesAutoresizingMaskIntoConstraints = false
        enterLocation2TextField.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false

        catagory_label.translatesAutoresizingMaskIntoConstraints = false
        catagoryView.translatesAutoresizingMaskIntoConstraints = false
        distance_label.translatesAutoresizingMaskIntoConstraints = false
        distance_slider.translatesAutoresizingMaskIntoConstraints = false
        key_word_label.translatesAutoresizingMaskIntoConstraints = false
        key_word_tex_field.translatesAutoresizingMaskIntoConstraints = false

        
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.maxY)

        
    }
    
    func layout(){
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1), // İstediğiniz yüksekliği ayarlayın
            
            scrollView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: bottomView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
            
            label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            label.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40), // ScrollView'in içeriğiyle aynı genişlikte
            label.heightAnchor.constraint(equalToConstant: 40),
            
            enterLocation1TextField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            enterLocation1TextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            enterLocation1TextField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor ,constant: -20),
            enterLocation1TextField.heightAnchor.constraint(equalToConstant: 40),
            
            enterLocation2TextField.topAnchor.constraint(equalTo: enterLocation1TextField.bottomAnchor, constant: 20),
            enterLocation2TextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            enterLocation2TextField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            enterLocation2TextField.heightAnchor.constraint(equalToConstant: 40),
            
            clearButton.topAnchor.constraint(equalTo: enterLocation2TextField.bottomAnchor, constant: 20),
            clearButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            clearButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            clearButton.heightAnchor.constraint(equalToConstant: 50),
            
            filterButton.topAnchor.constraint(equalTo: clearButton.bottomAnchor, constant: 20),
            filterButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            filterButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            
            catagory_label.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 20),
            catagory_label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            catagory_label.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            catagory_label.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            catagory_label.heightAnchor.constraint(equalToConstant: 40),
            
            catagoryView.topAnchor.constraint(equalTo: catagory_label.bottomAnchor, constant: 20),
            catagoryView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            catagoryView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            catagoryView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            catagoryView.heightAnchor.constraint(equalToConstant: 280),
            
            distance_label.topAnchor.constraint(equalTo: catagoryView.bottomAnchor, constant: 10),
            distance_label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            distance_label.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            distance_label.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            distance_label.heightAnchor.constraint(equalToConstant: 40),
            
            
            distance_slider.topAnchor.constraint(equalTo: distance_label.bottomAnchor, constant: 10),
            distance_slider.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            distance_slider.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            distance_slider.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            distance_slider.heightAnchor.constraint(equalToConstant: 40),
            
            key_word_label.topAnchor.constraint(equalTo: distance_slider.bottomAnchor, constant: 10),
            key_word_label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            key_word_label.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            key_word_label.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            key_word_label.heightAnchor.constraint(equalToConstant: 40),
         
         
            
            key_word_tex_field.topAnchor.constraint(equalTo: key_word_label.bottomAnchor, constant: 10),
            key_word_tex_field.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            key_word_tex_field.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            key_word_tex_field.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            key_word_tex_field.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            key_word_tex_field.heightAnchor.constraint(equalToConstant: 40),
            

        ])

            
    }
    @objc func sliderValueChanged() {
      let sliderValue = distance_slider.value

      let roundedValue = round(sliderValue / 500.0) * 500.0

      distance_slider.value = roundedValue
        

      // Uzaklık değerini label'a yazdırma
      distance_label.text = String(format: "Distance: %.0f meter", roundedValue)
    }
}
extension LocationSelectionView : UITextFieldDelegate{
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == enterLocation1TextField {
            delegate?.navigateToPlaceListViewController()
            return false // TextField'ın editlenmesini engellemek için false döndürüyoruz.
        }
        else if textField == enterLocation2TextField {
            delegate?.navigateToPlaceListViewController1()
            return false 
        }
        return true
    }
}
