//
//  ELOViewController.swift
//  A3_IOS
//
//  Created by Akhilesh Bitla on 3/11/25.
//

import UIKit

class ELOViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var profileButton: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!
    
    struct Team {
        let teamRank: String
        let teamName: String
        let eloScore: Double
        let teamImageName: String
    }
    
    let data: [Team] = [
        Team(teamRank: "1", teamName: "Rutgers Raaz", eloScore: 1000, teamImageName: "A3LOGO1"),
        Team(teamRank: "2", teamName: "CMU M&M", eloScore: 1010, teamImageName: "A3LOGO1"),
        Team(teamRank: "3", teamName: "Rice Eats", eloScore: 1030, teamImageName: "A3LOGO1"),
        Team(teamRank: "4", teamName: "UT Hum", eloScore: 1050, teamImageName: "A3LOGO1"),
        Team(teamRank: "5", teamName: "TAMU Swaram", eloScore: 1070, teamImageName: "A3LOGO1"),
        Team(teamRank: "6", teamName: "MSU Mansa", eloScore: 1090, teamImageName: "A3LOGO1"),
        Team(teamRank: "7", teamName: "UCSD Eagles", eloScore: 1100, teamImageName: "A3LOGO1"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        self.tableView.rowHeight = 100

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath) as! RankingCell
        cell.teamRankLabel.text = team.teamRank
        cell.teamNameLabel.text = team.teamName
        cell.teamEloLabel.text = String(team.eloScore)
        cell.teamImageView.image = UIImage(named: team.teamImageName)
        return cell
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
