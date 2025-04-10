//
//  TeamsViewController.swift
//  A3_IOS
//
//  Created by Eshitha B on 3/10/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

struct TeamSummary {
    let id: String
    let name: String
    let university: String
    let teamLogoURL: String
}

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamSearchBar: UISearchBar!
    
    let db = Firestore.firestore()
    var teams: [TeamSummary] = []
    var filteredTeams: [TeamSummary] = []
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        teamSearchBar.delegate = self

        fetchTeamsFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTeamsFromFirestore()  // Fetch teams again when the view appears (after adding a new team)
    }
    
    func fetchTeamsFromFirestore() {
        db.collection("teams").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching teams: \(error)")
                return
            }
            
            self.teams = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                return TeamSummary(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    university: data["university"] as? String ?? "",
                    teamLogoURL: data["teamLogoURL"] as? String ?? ""
                )
            } ?? []
            
            //sort teams alphabetically by team name
            self.teams.sort { $0.name.lowercased() < $1.name.lowercased() }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //TableView Methods
    // Set the height of the cells (make them bigger)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTeams.count : teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = isSearching ? filteredTeams[indexPath.row] : teams[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTeamSummaryCell", for: indexPath) as! CustomTeamSummaryCell
        cell.configure(with: team)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTeam = isSearching ? filteredTeams[indexPath.row] : teams[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let teamInfoVC = storyboard.instantiateViewController(withIdentifier: "teamInfoViewController") as? TeamInfoViewController {
            teamInfoVC.teamId = selectedTeam.id
            self.navigationController?.pushViewController(teamInfoVC, animated: true)
        }
    }
    
    // Swipe actions for Delete and Edit for teams
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let team = teams[indexPath.row]

        // DELETE action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            self.deleteTeam(teamId: team.id, indexPath: indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed

        // EDIT action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            self.editTeam(team: team)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    // delete team from databasse
    func deleteTeam(teamId: String, indexPath: IndexPath) {
        db.collection("teams").document(teamId).delete { error in
            if let error = error {
                print("Error deleting team: \(error)")
            } else {
                print("Team deleted successfully.")
                self.teams.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    // edit team takes you to a new View Controller
    func editTeam(team: TeamSummary) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let createTeamVC = storyboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as? CreateTeamViewController {
            createTeamVC.teamId = team.id  // Pass the team ID to CreateTeamVC
            self.navigationController?.pushViewController(createTeamVC, animated: true)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let lowercasedSearchText = searchText.lowercased()

        if searchText.isEmpty {
            isSearching = false
            filteredTeams = []
        } else {
            isSearching = true
            filteredTeams = teams.filter { team in
                return team.name.lowercased().contains(lowercasedSearchText) ||
                       team.university.lowercased().contains(lowercasedSearchText)
            }
        }

        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    // Code to dismiss the keyboard:
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
