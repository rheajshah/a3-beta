//
//  CompDescriptionViewController.swift
//  A3_IOS
//
//  Created by Akhilesh Bitla on 3/12/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class CompDescriptionViewController: UIViewController {

    @IBOutlet weak var compBannerImage: UIImageView!
    @IBOutlet weak var compName: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var compLocation: UILabel!
    @IBOutlet weak var dataIcon: UIImageView!
    @IBOutlet weak var compDate: UILabel!
    
    @IBOutlet weak var compDescSegCtrl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    var competitionID: String!
    
    //var competitionID = "02910788-5748-43D0-A9E6-68E45CC310EA"
    
    // Keep track of current child VC (embedded in the container)
    var currentChildVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCompDetails()
        showSubview(index: compDescSegCtrl.selectedSegmentIndex)
    }
    
    @IBAction func onSegCtrlChanged(_ sender: UISegmentedControl) {
        showSubview(index: sender.selectedSegmentIndex)
    }
    
    func loadCompDetails() {
        let db = Firestore.firestore()
        db.collection("comps").document(competitionID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching comp: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            let name = data["name"] as? String ?? "N/A"
            let date = data["date"] as? String ?? "TBD"
            let city = data["city"] as? String ?? ""
            let state = data["state"] as? String ?? ""
            let location = (city.isEmpty && state.isEmpty) ? "Location not available" : "\(city), \(state)"
            let bannerPath = data["bannerURL"] as? String ?? ""
            
            // Only load banner image if the path exists
            if !bannerPath.isEmpty {
                let storageRef = Storage.storage().reference(withPath: bannerPath)
                storageRef.downloadURL { url, error in
                    if let url = url {
                        self.loadImage(from: url, into: self.compBannerImage)
                    } else {
                        print("Error fetching download URL: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                print("No banner path found.")
            }

            // Update labels with fetched data
            DispatchQueue.main.async {
                self.compName.text = name
                self.compDate.text = date
                self.compLocation.text = location
            }
        }
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

    // Show or hide subviews based on the selected segment index
    func showSubview(index: Int) {
        if let child = currentChildVC {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        var newVC: UIViewController

        switch index {
        case 0:
            let vc = storyboard?.instantiateViewController(withIdentifier: "LineupSubviewViewController") as! LineupSubviewViewController
            vc.competitionID = self.competitionID
            newVC = vc
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "JudgingSubviewViewController") as! JudgingSubviewViewController
            vc.competitionID = self.competitionID
            newVC = vc
        case 2:
            let vc = storyboard?.instantiateViewController(withIdentifier: "MediaSubviewViewController") as! MediaSubviewViewController
            vc.competitionID = self.competitionID
            newVC = vc
        default:
            return
        }

        addChild(newVC)
        newVC.view.frame = containerView.bounds
        containerView.addSubview(newVC.view)
        newVC.didMove(toParent: self)

        currentChildVC = newVC
    }
}
