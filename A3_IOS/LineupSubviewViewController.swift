//
//  LineupSubviewViewController.swift
//  A3_IOS
//
//  Created by Rhea Shah on 4/4/25.
//

import UIKit
import FirebaseFirestore

class LineupSubviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var competitionID: String!
    var attendingTeams: [LineupTeam] = []
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Fetch the list of teams attending the competition
        fetchAttendingTeams()
    }

    // Fetch the teams attending the competition based on the competitionID
    func fetchAttendingTeams() {
        let compRef = db.collection("comps").document(competitionID)
        
        compRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching competition data: \(error)")
                return
            }

            if let data = snapshot?.data(), let teamIDs = data["competingTeams"] as? [String] {
                // Now fetch the details of each team using their teamIDs
                self.fetchTeamDetails(teamIDs: teamIDs)
            }
        }
    }

    // Fetch details of the teams using their IDs
    func fetchTeamDetails(teamIDs: [String]) {
        db.collection("teams").whereField(FieldPath.documentID(), in: teamIDs).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching team details: \(error)")
                return
            }

            // Map the teams data to our LineupTeam model and append them to attendingTeams
            self.attendingTeams = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                let teamName = data["name"] as? String ?? "Unknown"
                let logoURL = data["logoURL"] as? String ?? ""
                let eloScore = data["elo"] as? Int ?? 0
                
                return LineupTeam(id: doc.documentID, name: teamName, logoURL: logoURL, elo: eloScore)
            } ?? []

            // Reload table view with the fetched data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // Table View Data Source Methods
    // Set the height of the cells (make them bigger)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendingTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LineupTeamCell", for: indexPath) as? LineupTeamCell else {
            return UITableViewCell()
        }

        let team = attendingTeams[indexPath.row]
        
        // Set the team name and Elo score
        cell.teamName.text = team.name
        cell.eloLabel.text = "ELO: \(team.elo)"
        
        // Load the team logo image
        if let url = URL(string: team.logoURL) {
            cell.loadImage(from: url, into: cell.teamLogoImageView)
        }

        return cell
    }

    // Prepare for segue to SelectTeamsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelectTeamsView" {
            // Get the destination view controller (SelectTeamsViewController)
            if let selectTeamsVC = segue.destination as? SelectTeamsViewController {
                // Pass the competitionID to the SelectTeamsViewController
                selectTeamsVC.competitionID = self.competitionID
            }
        }
    }
}

class LineupTeam {
    var id: String
    var name: String
    var logoURL: String
    var elo: Int

    init(id: String, name: String, logoURL: String, elo: Int) {
        self.id = id
        self.name = name
        self.logoURL = logoURL
        self.elo = elo
    }
}

