//
//  TeamsViewController.swift
//  A3_IOS
//
//  Created by Eshitha B on 3/10/25.
//

import UIKit

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
        
    
    @IBOutlet weak var tableView: UITableView!
    
    let teams = [
        ("A3LOGO1", "Anokha", "University of Maryland"),
        ("A3LOGO2", "Arabhi", "Virginia Commonwealth University"),
        ("A3LOGO3", "Asli Baat", "University of Southern California"),
        ("A3LOGO4", "Astha A Cappella", "Saint Louis University")
    ]
    
    // Handle row selection
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self	
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = teams[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath)
        cell.imageView?.image = UIImage(named: team.0)
        cell.textLabel?.text = team.1
        cell.detailTextLabel?.text = team.2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let teamInfoViewController = storyboard.instantiateViewController(withIdentifier: "teamInfoViewController")
        self.navigationController?.pushViewController(teamInfoViewController, animated: true)
    }
}
    

    
    

