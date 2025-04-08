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
    var competingTeams: [String] = []  // This will store team IDs instead of team names
    var competitionID: String!  // Pass this from CompDescriptionViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Fetch the selected teams from Firestore and the team list
        fetchCompetingTeams()
    }
    
    // Fetch the selected teams for the competition from Firestore
    func fetchCompetingTeams() {
        let compRef = db.collection("comps").document(competitionID)

        compRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching competition data: \(error)")
                return
            }

            // Retrieve the list of selected team IDs from the competition document
            if let data = snapshot?.data(), let selectedTeams = data["competingTeams"] as? [String] {
                self.competingTeams = selectedTeams
                
                // Now fetch the teams data and check the selected ones
                self.fetchTeamsFromFirestore()
            }
        }
    }
    
    // Fetch teams from Firestore
    func fetchTeamsFromFirestore() {
        db.collection("teams").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching teams: \(error)")
                return
            }

            // Update the teams array with the fetched data (including IDs)
            self.teams = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                let teamName = data["name"] as? String ?? ""
                let teamID = doc.documentID  // Using document ID for teamID
                let isSelected = self.competingTeams.contains(teamID)  // Check if the team is selected
                return OptionItem(id: teamID, title: teamName, isSelected: isSelected)
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
        
        return cell
    }
        
    
    @objc func checkboxTapped(_ sender: UIButton) {
        let index = sender.tag
        let teamID = teams[index].id

        teams[index].isSelected.toggle()

        if teams[index].isSelected {
            if !competingTeams.contains(teamID) {
                competingTeams.append(teamID)
                updateTeamDocument(teamID: teamID, add: true)  // ⬅️ add comp to team
            }
        } else {
            competingTeams.removeAll { $0 == teamID }
            updateTeamDocument(teamID: teamID, add: false)  // ⬅️ remove comp from team
        }

        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        
        saveSelectedTeamsToCompetition(compID: competitionID)
    }
    
    // Function to save selected teams to competition (competingTeams array)
    func saveSelectedTeamsToCompetition(compID: String) {
        let compRef = db.collection("comps").document(compID)
        
        compRef.updateData([
            "competingTeams": competingTeams
        ]) { error in
            if let error = error {
                print("Error updating competition with selected teams: \(error)")
            } else {
                print("Competition updated with selected teams!")
            }
        }
    }
    
    func updateTeamDocument(teamID: String, add: Bool) {
        let teamRef = db.collection("teams").document(teamID)

        if add {
            teamRef.updateData([
                "comps": FieldValue.arrayUnion([competitionID])
            ]) { error in
                if let error = error {
                    print("Error adding comp to team \(teamID): \(error)")
                } else {
                    print("Comp \(self.competitionID!) added to team \(teamID)'s comps array")
                }
            }
        } else {
            teamRef.updateData([
                "comps": FieldValue.arrayRemove([competitionID])
            ]) { error in
                if let error = error {
                    print("Error removing comp from team \(teamID): \(error)")
                } else {
                    print("Comp \(self.competitionID!) removed from team \(teamID)'s comps array")
                }
            }
        }
    }
}


class CheckboxTableViewCell: UITableViewCell {
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
}

struct OptionItem {
    let id: String  // Team ID
    let title: String
    var isSelected: Bool
}
