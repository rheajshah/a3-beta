//
//  MediaSubviewViewController.swift
//  A3_IOS
//
//  Created by Rhea Shah on 4/4/25.
//

import UIKit
import FirebaseFirestore

class MediaSubviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var editLinkButton: UIButton!
    @IBOutlet weak var officialCompPhotosButton: UIButton!
    @IBOutlet weak var officialCompVideosButton: UIButton!
    @IBOutlet weak var uploadPhotoVideoButton: UIButton!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    var competitionID: String!
    var uploadedMediaURLs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMediaLinks()
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
    }
    
    func loadMediaLinks() {
        let db = Firestore.firestore()
        db.collection("comps").document(competitionID).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Failed to fetch comp data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let photosLink = data["photosLink"] as? String ?? ""
            let videosLink = data["videosLink"] as? String ?? ""

            self.configureButton(self.officialCompPhotosButton, with: photosLink, title: "Official Comp Photos")
            self.configureButton(self.officialCompVideosButton, with: videosLink, title: "Official Comp Videos")
        }
    }
    
    private func configureButton(_ button: UIButton, with link: String?, title: String) {
        if let link = link, !link.isEmpty {
            button.setTitle("Open \(title)", for: .normal)
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
    
    func fetchUploadedMedia() {
        let db = Firestore.firestore()
        db.collection("comps").document(competitionID).collection("media").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            self.uploadedMediaURLs = docs.compactMap { $0["url"] as? String }
            self.mediaCollectionView.reloadData()
        }
    }
    
    @IBAction func uploadPhotoVideoButtonTapped(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uploadedMediaURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
            let url = uploadedMediaURLs[indexPath.row]
            cell.configure(with: url)
            return cell

    }
}
