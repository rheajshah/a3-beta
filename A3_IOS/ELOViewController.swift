//
//  ELOViewController.swift
//  A3_IOS
//
//  Created by Akhilesh Bitla on 3/11/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

struct TeamElo {
    var id: String
    var name: String
    var eloScore: Double
    var eloRank: Int
    var logoURL: String
}

class ELOViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profileButton: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!
    
    var data: [TeamElo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.rowHeight = 100
        fetchAndSortTeams()
    }
    
    func fetchAndSortTeams() {
        let db = Firestore.firestore()
        db.collection("teams").getDocuments(completion: { snapshot, error in
            if let error = error {
                print("Error fetching teams: \(error)")
                return
            }

            var fetchedTeams: [TeamElo] = []

            for document in snapshot?.documents ?? [] {
                let data = document.data()
                guard
                    let name = data["name"] as? String,
                    let eloScore = data["eloScore"] as? Double,
                    let logoURL = data["teamLogoURL"] as? String
                else { continue }

                let id = document.documentID

                let team = TeamElo(id: id, name: name, eloScore: eloScore, eloRank: 0, logoURL: logoURL)
                fetchedTeams.append(team)

            }

            // Sort by eloScore descending
            self.data = fetchedTeams.sorted { $0.eloScore > $1.eloScore }

            // Update eloRank in Firestore
            for (index, team) in self.data.enumerated() {
                let rank = index + 1
                self.data[index].eloRank = rank
                db.collection("teams").document(team.id).updateData([
                    "eloRank": rank
                ])
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath) as! RankingCell
        cell.teamRankLabel.text = String(team.eloRank)
        cell.teamNameLabel.text = team.name
        cell.teamEloLabel.text = String(team.eloScore)
        cell.teamImageView.image = nil
        
        if let logoURL = URL(string: team.logoURL) {
            loadImage(from: logoURL, into: cell.teamImageView)
        }

        return cell
    }
    
    
    func loadImage(from url: URL, into imageView: UIImageView?) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    imageView?.image = UIImage(data: data)
                }
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTeam = data[indexPath.section]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let teamInfoVC = storyboard.instantiateViewController(withIdentifier: "teamInfoViewController") as? TeamInfoViewController {
            teamInfoVC.teamId = selectedTeam.id  
            self.navigationController?.pushViewController(teamInfoVC, animated: true)
        }
        
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
