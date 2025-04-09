//
//  CompetitionsViewController.swift
//  A3_IOS
//
//  Created by Akhilesh Bitla on 3/12/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

struct PreviousComp {
    let id: String
    let name: String
    let date: Date
    let logoRef: String
}

struct UpcomingComp {
    let id: String
    let name: String
    let date: Date
    let city: String
    let state: String
    let imageURL: String
}

class CompetitionsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var previousCompTableView: UITableView!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var upcomingComps: [UpcomingComp] = []
    var previousComps: [PreviousComp] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        previousCompTableView.dataSource = self
        previousCompTableView.delegate = self
        
        populateComps()
        previousCompTableView.reloadData()
        collectionView.reloadData()
    }
    
    func populateComps() {
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMMM dd yyyy"
        let todayDate = Date()
        
        db.collection("comps").getDocuments() {
            snapshot, error in
            if let error = error {
                print("Error while fetching comps: \(error)")
            }
            
            
            // Return if error while retrieving documents
            guard let documents = snapshot?.documents else { return }
            
            var tempPrevComps: [PreviousComp] = []
            var tempUpcomingComps: [UpcomingComp] = []
            for document in documents {
                let data = document.data()
                guard
                    let name = data["name"] as? String,
                    let logoRef = data["logoURL"] as? String,
                    let dateString = data["date"] as? String,
                    let bannerRef = data["bannerURL"] as? String,
                    let date = dateFormatter.date(from: dateString),
                    let city = data["city"] as? String,
                    let state = data["state"] as? String
                else {
                    continue
                }
                
                print("Date String: \(dateString)")
                print("Date: \(date)")
                
                if date < todayDate {
                    let comp = PreviousComp (
                        id: document.documentID,
                        name: name,
                        date: date,
                        logoRef: logoRef
                    )
                    tempPrevComps.append(comp)
                } else {
                    let comp = UpcomingComp (
                        id: document.documentID,
                        name: name,
                        date: date,
                        city: city,
                        state: state,
                        imageURL: bannerRef
                    )
                    tempUpcomingComps.append(comp)
                }
            }
            self.previousComps = tempPrevComps.sorted(by: { $0.date > $1.date})
            self.upcomingComps = tempUpcomingComps.sorted(by: { $0.date < $1.date})
            print(self.upcomingComps)
            DispatchQueue.main.async {
                self.previousCompTableView.reloadData()
                self.collectionView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 3 // whatever you want space between two cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear // Transparent gap
        return spacer
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return previousComps.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrevCompCell", for: indexPath) as? PrevCompCell else {
                return UITableViewCell()
            }
        
        let comp = previousComps[indexPath.section]
        
        cell.prevCompName.text = comp.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        cell.prevCompDate.text = dateFormatter.string(from: comp.date)
        cell.prevCompImageView.image = nil
        
        if let logoURL = URL(string: comp.logoRef) {
            loadImage(from: logoURL, into: cell.prevCompImageView)
        }
        
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        
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
        let selectedComp = previousComps[indexPath.section]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let compInfoVC = storyboard.instantiateViewController(withIdentifier: "CompDescriptionViewController") as? CompDescriptionViewController {
            compInfoVC.competitionID = selectedComp.id  //pass the comp ID to CompDescriptionViewController
            self.navigationController?.pushViewController(compInfoVC, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingComps.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpcomingCompCell", for: indexPath) as! UpcomingCompCell
        let comp = upcomingComps[indexPath.item]
        cell.compName.text = comp.name
        let location = (comp.city.isEmpty && comp.state.isEmpty) ? "Location not available" : "\(comp.city), \(comp.state)"
        cell.location.text = location
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        cell.date.text = dateFormatter.string(from: comp.date)
        cell.imageView.image = nil
        
        if let logoURL = URL(string: comp.imageURL) {
            loadImage(from: logoURL, into: cell.imageView)
        }
        
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 185, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedComp = upcomingComps[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let compInfoVC = storyboard.instantiateViewController(withIdentifier: "CompDescriptionViewController") as? CompDescriptionViewController {
            compInfoVC.competitionID = selectedComp.id  //pass the comp ID to CompDescriptionViewController
            self.navigationController?.pushViewController(compInfoVC, animated: true)
        }
        
    }
}

//class BoxCell: UICollectionViewCell {
//    
//    @IBOutlet weak var compImage: UIImageView!
//    
//    @IBOutlet weak var compName: UILabel!
//    
//    
//}
//
//struct Comp {
//    let title: String
//    let imageName: String
//}
