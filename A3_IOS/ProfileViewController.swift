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

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var selectTeamButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.image = UIImage(named: "defaultProfilePic")
        
        profileImageView.clipsToBounds = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor, multiplier: 1).isActive = true
        profileImageView.contentMode = .scaleAspectFill
//        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    
        
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.gray.cgColor
        
        selectTeamButton.showsMenuAsPrimaryAction = true
        selectTeamButton.changesSelectionAsPrimaryAction = true
        
        let menu = UIMenu(title: "", children: [
                UIAction(title: "Option 1", handler: { [weak self] action in
                    self?.selectTeamButton.setTitle(action.title, for: .normal)
                }),
                UIAction(title: "Option 2", handler: { [weak self] action in
                    self?.selectTeamButton.setTitle(action.title, for: .normal)
                }),
                UIAction(title: "Option 3", handler: { [weak self] action in
                    self?.selectTeamButton.setTitle(action.title, for: .normal)
                })
            ])
        
        selectTeamButton.menu = menu
        
    }
    

    @IBAction func logoutPressed(_ sender: Any) {
        print("AHAHAH")
        do {
            print("REACHED 1")
            try Auth.auth().signOut()
            print("REACHED 2")
            navigateToLogin()
        } catch {
            print("REACHED 4")
            print("Sign out error")
        }
    }
    
    @IBAction func logoutTestPressed(_ sender: Any) {
        print("AHAHAH")
        do {
            print("REACHED 1")
            try Auth.auth().signOut()
            print("REACHED 2")
            navigateToLogin()
        } catch {
            print("REACHED 4")
            print("Sign out error")
        }
    }
    
    
    private func navigateToLogin() {
        print("REACHED 3")
        if let loginVC = storyboard?.instantiateViewController(identifier: "LoginVC") as? LoginViewController {
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        }
    }
    

}
