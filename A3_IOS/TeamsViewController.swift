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

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    
    let db = Firestore.firestore()
    var teams: [TeamSummary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = teams[indexPath.row]
                
        // Dequeue the custom cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTeamSummaryCell", for: indexPath) as! CustomTeamSummaryCell
        
        // Configure the custom cell with team data
        cell.configure(with: team)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTeam = teams[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let teamInfoVC = storyboard.instantiateViewController(withIdentifier: "teamInfoViewController") as? TeamInfoViewController {
            teamInfoVC.teamId = selectedTeam.id  //pass the team ID to TeamInfoViewController
            self.navigationController?.pushViewController(teamInfoVC, animated: true)
        }
    }
}
