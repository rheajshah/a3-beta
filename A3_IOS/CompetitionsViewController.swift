//
//  CompetitionsViewController.swift
//  A3_IOS
//
//  Created by Akhilesh Bitla on 3/12/25.
//

import UIKit

class CompetitionsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var previousCompTableView: UITableView!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let list: [Comp] = [
            Comp(title: "Box 1", imageName: "box1"),
            Comp(title: "Box 2", imageName: "box2"),
            Comp(title: "Box 3", imageName: "box3"),
            Comp(title: "Box 4", imageName: "box4")
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
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
