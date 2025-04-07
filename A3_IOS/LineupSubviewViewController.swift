//
//  LineupSubviewViewController.swift
//  A3_IOS
//
//  Created by Rhea Shah on 4/4/25.
//

import UIKit

class LineupSubviewViewController: UIViewController {

    var competitionID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
