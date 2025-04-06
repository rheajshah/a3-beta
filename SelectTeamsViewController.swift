//
//  SelectTeamsViewController.swift
//  A3_IOS
//
//  Created by Eshitha B on 4/4/25.
//

import UIKit

class SelectTeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    var teams: [OptionItem] = [
        OptionItem(title: "Anokha", isSelected: false),
        OptionItem(title: "Arabhi", isSelected: false),
        OptionItem(title: "Asli Baat", isSelected: false),
        OptionItem(title: "Astha A Cappella", isSelected: false),
        OptionItem(title: "Barsaat", isSelected: false),
        OptionItem(title: "Basmati Beats", isSelected: false),
        OptionItem(title: "Brown Sugar", isSelected: false),
        OptionItem(title: "Chai Town", isSelected: false),
        OptionItem(title: "Chicago Aag", isSelected: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
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
            
            // use below to upload teams to firebase
            //let selectedTeamNames = teams.filter { $0.isSelected}.map { $0.title }
        
            //print(selectedTeamNames)
            return cell
    }
    
    @objc func checkboxTapped(_ sender: UIButton) {
        let index = sender.tag
        teams[index].isSelected.toggle()
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }


}


class CheckboxTableViewCell: UITableViewCell {
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
}

struct OptionItem {
    let title: String
    var isSelected: Bool
}
