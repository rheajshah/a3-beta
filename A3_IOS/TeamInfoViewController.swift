//
//  TeamInfoViewController.swift
//  A3_IOS
//
//  Created by Akhilesh Bitla on 3/12/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class TeamInfoViewController: UIViewController {
    
    @IBOutlet weak var teamPicture: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var university: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var instagram: UILabel!
    @IBOutlet weak var eloRank: UILabel!
    @IBOutlet weak var eloScore: UILabel!
    
    
    //a variable to hold the team ID passed from TeamsViewController
    var teamId: String?
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if the teamId is available, then fetch the team details
        if let teamId = teamId {
            fetchTeamDetails(teamId: teamId)
        }
    }
    
    func fetchTeamDetails(teamId: String) {
        db.collection("teams").document(teamId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching team details: \(error)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                
                //extract the additional information from Firestore
                let name = data?["name"] as? String ?? "Unknown"
                let university = data?["university"] as? String ?? "Unknown"
                //construct location from city and state fields
                let city = data?["city"] as? String ?? ""
                let state = data?["state"] as? String ?? ""
                let location = (city.isEmpty || state.isEmpty) ? "Location not available" : "\(city), \(state)"
                
                let instagram = data?["instagram"] as? String ?? "Instagram not available"
                let teamPictureURL = data?["teamPictureURL"] as? String ?? ""
                let eloRank = data?["eloRank"] as? Int ?? -1
                let eloScore = data?["eloScore"] as? Double ?? 0.0
                
                // Update the UI with the fetched data
                DispatchQueue.main.async {
                    self.teamName.text = name
                    self.university.text = university
                    self.location.text = location
                    self.instagram.text = "@ \(instagram)"
                    self.eloRank.text = "# \(eloRank)"
                    self.eloScore.text = String(format: "%.2f", eloScore)  //format eloScore as a string with two decimal places
                                    
                    
                    // Set the team picture (if available)
                    if let pictureURL = URL(string: teamPictureURL) {
                        self.loadImage(from: pictureURL, into: self.teamPicture)
                    }
                }
            }
        }
    }
    
    // Function to load an image from a URL asynchronously
    func loadImage(from url: URL, into imageView: UIImageView?) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    imageView?.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}
