//
//  CreateTeamViewController.swift
//  A3_IOS
//
//  Created by Akhilesh Bitla on 4/6/25.
//

import UIKit

class CreateTeamViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var teamPictureImageView: UIImageView!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var teamUniversityTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var statePickerView: UIPickerView!
    
    var imagePicker = UIImagePickerController()
    
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
    var isSelectingTeamPicture = false

    override func viewDidLoad() {
        super.viewDidLoad()

        statePickerView.delegate = self
        statePickerView.dataSource = self
        
        let defaultIndex = states.firstIndex(of: "Texas") ?? 0
        statePickerView.selectRow(defaultIndex, inComponent: 0, animated: false)
        selectedState = states[defaultIndex]

        // Image view styles
        [teamPictureImageView, teamLogoImageView].forEach { imageView in
            imageView?.layer.borderWidth = 2
            imageView?.layer.borderColor = UIColor.gray.cgColor
            imageView?.clipsToBounds = true
            imageView?.contentMode = .scaleAspectFill
        }

        imagePicker.delegate = self
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

    @IBAction func onSelectTeamPictureTapped(_ sender: Any) {
        isSelectingTeamPicture = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @IBAction func onSelectTeamLogoTapped(_ sender: Any) {
        isSelectingTeamPicture = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.editedImage] as? UIImage {
                if isSelectingTeamPicture {
                    teamPictureImageView.image = selectedImage
                } else {
                    teamLogoImageView.image = selectedImage
                }
            }
            dismiss(animated: true)
        }

    
    @IBAction func onSaveTeamButtonPressed(_ sender: Any) {
        if let name = teamNameTextField.text,
           let university = teamUniversityTextField.text,
           let city = cityTextField.text,
           let state = selectedState {
            
            let team = Team(
                name: name,
                university: university,
                city: city,
                state: state,
                teamPicture: teamPictureImageView.image,
                teamLogo: teamLogoImageView.image
            )
        }
    }
}
