//
//  CompSubviewsViewController.swift
//  A3_IOS
//
//  Created by Akhilesh Bitla on 3/12/25.
//

import UIKit

class CompSubviewsViewController: UIViewController {

    @IBOutlet weak var lineupView: UIView!
    @IBOutlet weak var judgingView: UIView!
    @IBOutlet weak var mediaView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide all views initially
        hideAllSubviews()
    }
    
    // Function to hide all subviews
    func hideAllSubviews() {
        lineupView.isHidden = true
        judgingView.isHidden = true
        mediaView.isHidden = true
    }

    // Functions to show individual subviews
    func showLineupView() {
        lineupView.isHidden = false
    }
    
    func showJudgingView() {
        judgingView.isHidden = false
    }
    
    func showMediaView() {
        mediaView.isHidden = false
    }

}
