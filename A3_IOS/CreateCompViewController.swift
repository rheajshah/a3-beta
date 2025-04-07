//
//  CreateCompViewController.swift
//  A3_IOS
//
//  Created by Eshitha B on 4/4/25.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

var competingTeams: [String] = []

class CreateCompViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var compImage: UIImageView!
    @IBOutlet weak var compLogo: UIImageView!
    @IBOutlet weak var statePickerView: UIPickerView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var instagramField: UITextField!
    
    let states = [
        "Alabama", "Alaska", "American Samoa", "Arizona", "Arkansas", "California", "Colorado",
        "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Guam", "Hawaii",
        "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine",
        "Maryland", "Massachusetts", "Michigan", "Minnesota", "Minor Outlying Islands",
        "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey",
        "New Mexico", "New York", "North Carolina", "North Dakota", "Northern Mariana Islands",
        "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Puerto Rico", "Rhode Island",
        "South Carolina", "South Dakota", "Tennessee", "Texas", "U.S. Virgin Islands", "Utah",
        "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
    ]
    
    var selectedState: String?
    var isSelectingBanner = false
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting starting values for the date picker
        let datePicker = UIDatePicker ()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector (dateChange (datePicker:)), for:
        UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        dateField.inputView = datePicker
        dateField.text = formatDate(date: Date())
        
        // setting initial values for the comp image
        compImage.layer.borderWidth = 2
        compImage.layer.borderColor = UIColor.gray.cgColor
        compImage.clipsToBounds = true
        compImage.contentMode = .scaleAspectFill
        
        // State Picker View
        statePickerView.delegate = self
        statePickerView.dataSource = self
        //set default to Alabama
        let defaultIndex = states.firstIndex(of: "Alabama") ?? 0
        statePickerView.selectRow(defaultIndex, inComponent: 0, animated: false)
        selectedState = states[defaultIndex]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedState = states[row]
    }
   
    @objc func dateChange(datePicker: UIDatePicker) {
        dateField.text = formatDate(date: datePicker.date)
    }
    
    func formatDate (date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        return formatter.string (from: date)
    }
    
    @IBAction func chooseCompImage(_ sender: Any) {
//        imagePicker.sourceType = .photoLibrary
//        imagePicker.allowsEditing = true
//        present(imagePicker, animated: true, completion: nil)
        isSelectingBanner = true
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
         picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    
    
    @IBAction func chooseCompLogo(_ sender: Any) {
        isSelectingBanner = false
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            if isSelectingBanner {
                compImage.image = selectedImage
            } else {
                compLogo.image = selectedImage
            }
            // uploadProfileImage(selectedImage)
            // do stuff above to add to firebase
        }
        dismiss(animated: true)
    }
    
    
    @IBAction func saveCompClicked(_ sender: Any) {
        // Firestore Data
        var id = UUID().uuidString
        var compName = nameField.text!
        var city = cityField.text!
        var state = selectedState!
        var date = dateField.text!
        var compJudges: [String] = []
        var placings: [String] = []
        var compBannerRef = "comps/\(id)/banner.jpg"
        var compLogoRef: String = "comps/\(id)/logo.jpg"
        var scoreSheetRef: String = ""
        var feedbackSheetRef = ""
        var videosLink = ""
        var photosLink = ""
        var instagram = instagramField.text!
        
        
        // Image Uploading to Firebase storage
        let storageRef = Storage.storage().reference()
        guard let logo = compImage.image,
              let compLogoData = logo.jpegData(compressionQuality: 0.8) else {
            print("Image conversion failed")
            return
        }
        
        var fileRef = storageRef.child("comps/\(id)/logo.jpg")
        
        var uploadTask = fileRef.putData(compLogoData, metadata: nil) {
            metadata, error in
            
            if error == nil && metadata != nil {
                print("Successfully uploaded to Storage")
                // TODO Save a reference to the file in Firestore DB
                compLogoRef = "comps/\(id)/logo.jpg"
            } else {
                print("Error while trying to upload to Storage")
            }
        }
        
        
        guard let banner = compImage.image,
              let compBannerData = banner.jpegData(compressionQuality: 0.8) else {
            print("Image conversion failed")
            return
        }
        
        
        fileRef = storageRef.child("comps/\(id)/banner.jpg")
        
        uploadTask = fileRef.putData(compBannerData, metadata: nil) {
            metadata, error in
            
            if error == nil && metadata != nil {
                print("Successfully uploaded to Storage")
                // TODO Save a reference to the file in Firestore DB
                compBannerRef = "comps/\(id)/banner.jpg"
            } else {
                print("Error while trying to upload to Storage")
            }
        }
        
        let data: [String: Any] = [
            "id": id,
            "name": compName,
            "city": city,
            "state": state,
            "date": date,
            "competingTeams": competingTeams,
            "placings": placings,
            "judges": compJudges,
            "compBannerRef": compBannerRef,
            "compLogoRef": compLogoRef,
            "scoreSheetRef": scoreSheetRef,
            "feedbackSheetRef": feedbackSheetRef,
            "videosLink": videosLink,
            "photosLink": photosLink,
            "instagram": instagram
        ]
        
        let db = Firestore.firestore()
        db.collection("comps").addDocument(data: data) {
            error in
            if let error = error {
                print("Failed to write document: \(error)")
            } else {
                print("Succeeded in writing document")
            }
        }
    }
}

