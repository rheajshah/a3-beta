//
//  JudgingSubviewViewController.swift
//  A3_IOS
//
//  Created by Rhea Shah on 4/4/25.
//

import UIKit
import FirebaseFirestore

class JudgingSubviewViewController: UIViewController {

    @IBOutlet weak var judge1Label: UILabel!
    @IBOutlet weak var judge2Label: UILabel!
    @IBOutlet weak var judge3Label: UILabel!
    @IBOutlet weak var judge4Label: UILabel!
    
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var scoringButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    var isAdmin: Bool!
    var competitionID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        //show button only if user is admin
        editButton.isHidden = !(isAdmin ?? false)
        loadJudgingData()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadJudgingData), name: Notification.Name("JudgingInfoUpdated"), object: nil)
    }
    
    private func loadJudgingData() {
        let db = Firestore.firestore()
        db.collection("comps").document(competitionID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching judging data: \(error)")
                self.populatePlaceholders()
                return
            }
            
            guard let data = snapshot?.data() else {
                self.populatePlaceholders()
                return
            }
            
            let judges = data["judges"] as? [String] ?? []
            self.judge1Label.text = judges.count > 0 && !judges[0].isEmpty ? judges[0] : "Judge 1"
            self.judge2Label.text = judges.count > 1 && !judges[1].isEmpty ? judges[1] : "Judge 2"
            self.judge3Label.text = judges.count > 2 && !judges[2].isEmpty ? judges[2] : "Judge 3"
            self.judge4Label.text = judges.count > 3 && !judges[3].isEmpty ? judges[3] : "Judge 4"
            
            let feedbackLink = data["feedbackSheetRef"] as? String ?? ""
            let scoringLink = data["scoreSheetRef"] as? String ?? ""
            
            self.configureButton(self.feedbackButton, with: feedbackLink, title: "Feedback")
            self.configureButton(self.scoringButton, with: scoringLink, title: "Scoring")
        }
    }
    
    @objc private func reloadJudgingData() {
        loadJudgingData()
    }
    
    private func populatePlaceholders() {
        judge1Label.text = "Judge 1"
        judge2Label.text = "Judge 2"
        judge3Label.text = "Judge 3"
        judge4Label.text = "Judge 4"
        
        configureButton(feedbackButton, with: nil, title: "Feedback")
        configureButton(scoringButton, with: nil, title: "Scoring")
    }

    private func configureButton(_ button: UIButton, with link: String?, title: String) {
        if let link = link, !link.isEmpty {
            button.setTitle("\(title)", for: .normal)
            button.isEnabled = true
            button.addAction(UIAction { _ in
                if let url = URL(string: link) {
                    UIApplication.shared.open(url)
                }
            }, for: .touchUpInside)
        } else {
            button.setTitle(title, for: .normal)
            button.isEnabled = false
        }
    }
    
    @IBAction func onEditButtonPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditJudgingViewController") as! EditJudgingViewController
        vc.competitionID = self.competitionID
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
}
