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
        
        // setting initial values for the comp image (banner)
        compImage.layer.borderWidth = 2
        compImage.layer.borderColor = UIColor.gray.cgColor
        compImage.clipsToBounds = true
        compImage.contentMode = .scaleAspectFill
        
        // setting initial values for the comp logo
        compLogo.layer.borderWidth = 2
        compLogo.layer.borderColor = UIColor.gray.cgColor
        compLogo.clipsToBounds = true
        compLogo.contentMode = .scaleAspectFill
        
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
    
    
    @IBAction func onSaveCompPressed(_ sender: Any) {
        guard let name = nameField.text, !name.isEmpty,
              let city = cityField.text, !city.isEmpty,
              let state = selectedState, !state.isEmpty,
              let date = dateField.text else {
            showAlert(title: "Missing Info", message: "Please fill in all required fields.")
            return
        }

        let compID = UUID().uuidString
        let instagram = instagramField.text ?? ""
        

        //default values will be added via edit function NOT at time of creation
        let compJudges: [String] = []
        let placings: [String] = []
        let scoreSheetRef: String = ""
        let feedbackSheetRef = ""
        let videosLink = ""
        let photosLink = ""
        
        uploadImage(compImage.image, path: "comps/comp_banners/\(compID).jpg") { bannerURL in
            self.uploadImage(self.compLogo.image, path: "comps/comp_logos/\(compID).jpg") { logoURL in
                
                let compData: [String: Any] = [
                    "id": compID,
                    "name": name,
                    "city": city,
                    "state": state,
                    "date": date,
                    "instagram": instagram,
                    "bannerURL": bannerURL ?? "",
                    "logoURL": logoURL ?? "",
                    "teams": competingTeams, //this is filled from the select competing teams screen
                    "placings": placings,
                    "judges": compJudges,
                    "scoreSheetRef": scoreSheetRef,
                    "feedbackSheetRef": feedbackSheetRef,
                    "videosLink": videosLink,
                    "photosLink": photosLink,
                ]
                
                Firestore.firestore().collection("competitions").document(compID).setData(compData) { error in
                    if let error = error {
                        print("Error saving comp: \(error)")
                        self.showAlert(title: "Error", message: "Failed to save competition.")
                    } else {
                        self.showAlert(title: "Success", message: "Competition created successfully!")
                    }
                }
            }
        }
    }
    
    func uploadImage(_ image: UIImage?, path: String, completion: @escaping (String?) -> Void) {
        guard let image = image, let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }

        let ref = Storage.storage().reference().child(path)
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Upload error: \(error)")
                completion(nil)
                return
            }
            ref.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

