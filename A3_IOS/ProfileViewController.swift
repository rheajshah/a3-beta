//
//  ProfileViewController.swift
//  A3_IOS
//
//  Created by Aryan Samal on 3/9/25.
//

import UIKit
import FirebaseAuth
import CoreData
import Foundation
import FirebaseFirestore
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var selectTeamButton: UIButton!
    @IBOutlet weak var adminYesNoLabel: UILabel!
    @IBOutlet weak var allowNotifsToggle: UISwitch!
    @IBOutlet weak var darkModeToggle: UISwitch!
    
    let db = Firestore.firestore()
    var userID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = Auth.auth().currentUser?.uid
        emailTextField.isUserInteractionEnabled = false // Email is not editable
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.gray.cgColor
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        selectTeamButton.showsMenuAsPrimaryAction = true
        selectTeamButton.changesSelectionAsPrimaryAction = true
        
        loadUserProfile()
        setupTeamDropdown()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }

    //Load User Data from Firebase
    func loadUserProfile() {
        guard let userID = userID else { return }
        
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.fullNameTextField.text = data?["fullName"] as? String
                self.emailTextField.text = data?["email"] as? String
                self.adminYesNoLabel.text = (data?["isAdmin"] as? Bool ?? false) ? "Admin" : "Not Admin"
                self.allowNotifsToggle.isOn = data?["allowNotifications"] as? Bool ?? false
                self.darkModeToggle.isOn = data?["darkMode"] as? Bool ?? false
                self.selectTeamButton.setTitle(data?["team"] as? String ?? "Select Team", for: .normal)
                
                if let profileURL = data?["profileImage"] as? String {
                    self.loadProfileImage(from: profileURL)
                }
            }
        }
    }
    
    //Team Dropdown
    func setupTeamDropdown() {
        let menu = UIMenu(title: "Select Team", children: [
            UIAction(title: "Team A", handler: { action in self.selectTeamButton.setTitle(action.title, for: .normal) }),
            UIAction(title: "Team B", handler: { action in self.selectTeamButton.setTitle(action.title, for: .normal) }),
            UIAction(title: "Team C", handler: { action in self.selectTeamButton.setTitle(action.title, for: .normal) })
        ])
        selectTeamButton.menu = menu
    }

    //Edit Profile Photo
    @IBAction func editPhotoButtonPressed(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            profileImageView.image = selectedImage
            uploadProfileImage(selectedImage)
        }
        dismiss(animated: true)
    }

    //Upload Profile Image to Firebase Storage
    func uploadProfileImage(_ image: UIImage) {
        guard let userID = userID, let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let storageRef = Storage.storage().reference().child("profileImages/\(userID).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload image: \(error)")
                return
            }
            storageRef.downloadURL { url, _ in
                if let profileURL = url?.absoluteString {
                    self.db.collection("users").document(userID).updateData(["profileImage": profileURL])
                }
            }
        }
    }

    //Load Profile Image from URL
    func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                }
            }
        }
    }

    //Save Changes to Firebase
    @IBAction func saveChangesButtonPressed(_ sender: Any) {
        guard let userID = userID else { return }
        
        let updatedData: [String: Any] = [
            "fullName": fullNameTextField.text ?? "",
            "team": selectTeamButton.title(for: .normal) ?? "Select Team",
            "allowNotifications": allowNotifsToggle.isOn,
            "darkMode": darkModeToggle.isOn
        ]
        
        db.collection("users").document(userID).updateData(updatedData) { error in
            if let error = error {
                print("Error updating profile: \(error)")
            } else {
                print("Profile updated successfully!")
            }
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigateToLogin()
        } catch {
            print("Sign out error")
        }
    }
    
    private func navigateToLogin() {
        if let loginVC = storyboard?.instantiateViewController(identifier: "LoginVC") as? LoginViewController {
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        }
    }
    

}
