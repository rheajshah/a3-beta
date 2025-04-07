//
//  SelectTeamsViewController.swift
//  A3_IOS
//
//  Created by Eshitha B on 4/4/25.
//

import UIKit
import FirebaseFirestore

class SelectTeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    var teams: [OptionItem] = []
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        //Fetch team names from Firestore
        fetchTeamsFromFirestore()
    }
    
    // Fetch teams from Firestore
    func fetchTeamsFromFirestore() {
        db.collection("teams").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching teams: \(error)")
                return
            }
            
            // Update the teams array with the fetched data
            self.teams = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                let teamName = data["name"] as? String ?? ""
                return OptionItem(title: teamName, isSelected: false)
            } ?? []
            
            // Reload table view with the fetched data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CheckboxCell", for: indexPath) as? CheckboxTableViewCell else {
                return UITableViewCell()
            }

            let team = teams[indexPath.row]
            cell.titleLabel.text = team.title

            let imageName = team.isSelected ? "checkmark.square.fill" : "square"
            cell.checkboxButton.setImage(UIImage(systemName: imageName), for: .normal)

            // Tag the button with the row index so we can know which one was tapped
            cell.checkboxButton.tag = indexPath.row
            cell.checkboxButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
            
            // use below to upload teams to firebase
            //let selectedTeamNames = teams.filter { $0.isSelected}.map { $0.title }
        
            //print(selectedTeamNames)
            return cell
    }
    
    @objc func checkboxTapped(_ sender: UIButton) {
        let index = sender.tag
        teams[index].isSelected.toggle()
        
        let teamName = teams[index].title
        
        if teams[index].isSelected {
            if !competingTeams.contains(teamName) {
                competingTeams.append(teamName)
            }
        } else {
            competingTeams.removeAll { $0 == teamName}
        }
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}


class CheckboxTableViewCell: UITableViewCell {
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
}

struct OptionItem {
    let title: String
    var isSelected: Bool
}
