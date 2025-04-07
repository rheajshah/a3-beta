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

class CompetitionsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousComps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrevCompCell", for: indexPath) as? PrevCompCell else {
                return UITableViewCell()
            }
        
        let comp = previousComps[indexPath.row]
        
        cell.prevCompName.text = comp.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        cell.prevCompDate.text = dateFormatter.string(from: comp.date)
        cell.prevCompImageView.image = nil
        
        if let logoURL = URL(string: comp.logoRef) {
            loadImage(from: logoURL, into: cell.prevCompImageView)
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
        let selectedComp = previousComps[indexPath.row]
        performSegue(withIdentifier: "CompDescSegue", sender: selectedComp.id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CompDescSegue",
           let dest = segue.destination as? CompDescriptionViewController,
           let compId = sender as? String {
            dest.competitionID = compId
        }
    }
    

    @IBOutlet var previousCompTableView: UITableView!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let list: [Comp] = [
            Comp(title: "Box 1", imageName: "box1"),
            Comp(title: "Box 2", imageName: "box2"),
            Comp(title: "Box 3", imageName: "box3"),
            Comp(title: "Box 4", imageName: "box4")
        ]
    
    var previousComps: [PreviousComp] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        previousCompTableView.dataSource = self
        previousCompTableView.delegate = self
        
        populatePreviousComps()
    }
    
    func populatePreviousComps() {
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
            
            var tempComps: [PreviousComp] = []
            for document in documents {
                let data = document.data()
                guard
                    let name = data["name"] as? String,
                    let logoRef = data["logoURL"] as? String,
                    let dateString = data["date"] as? String,
                    let date = dateFormatter.date(from: dateString)
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
                    tempComps.append(comp)
                }
            }
            self.previousComps = tempComps.sorted(by: { $0.date > $1.date})
            print(tempComps)
            DispatchQueue.main.async {
                self.previousCompTableView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxCell", for: indexPath) as! BoxCell
        let box = list[indexPath.item]
        cell.compName.text = box.title
       // cell.compImage.image = UIImage(named: box.imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 120, height: 160)
        }
}

class BoxCell: UICollectionViewCell {
    
    @IBOutlet weak var compImage: UIImageView!
    
    @IBOutlet weak var compName: UILabel!
    
    
}

struct Comp {
    let title: String
    let imageName: String
}
