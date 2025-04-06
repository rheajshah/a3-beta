//
//  CreateCompViewController.swift
//  A3_IOS
//
//  Created by Eshitha B on 4/4/25.
//

import UIKit

class CreateCompViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var compImage: UIImageView!
    
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
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
         picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            compImage.image = selectedImage
            // uploadProfileImage(selectedImage)
            // do stuff above to add to firebase
        }
        dismiss(animated: true)
    }
    
    
    @IBAction func saveCompClicked(_ sender: Any) {
        // add code to save to FireBase
    }
}

