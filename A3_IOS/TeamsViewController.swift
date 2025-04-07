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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = teams[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath)
        
        // Set team name and university in the text labels
        cell.textLabel?.text = team.name
        cell.detailTextLabel?.text = team.university
        
        // Fetch team logo image from URL
        if let logoURL = URL(string: team.teamLogoURL) {
            loadImage(from: logoURL, into: cell.imageView)
        }
        
        // Make the image circular once it is loaded
        cell.imageView?.layer.borderWidth = 2
        cell.imageView?.layer.borderColor = UIColor.gray.cgColor
        cell.imageView?.clipsToBounds = true
        cell.imageView?.contentMode = .scaleAspectFill
        
        // Ensure the corner radius is updated once the image is loaded and frame is set
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width ?? 0) / 2
        
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
    
    func loadImage(from url: URL, into imageView: UIImageView?) {
        // Load the image asynchronously
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    // Ensure the image is set before updating the corner radius
                    imageView?.image = UIImage(data: data)
                    
                    // Update the corner radius after the image is loaded
                    imageView?.layer.cornerRadius = (imageView?.frame.size.width ?? 0) / 2
                }
            }
        }.resume()
    }
}
