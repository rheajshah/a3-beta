//
//  ProfileViewController.swift
//  A3_IOS
//
//  Created by Aryan Samal on 3/9/25.
//

import UIKit

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
