//
//  CompDescriptionViewController.swift
//  A3_IOS
//
//  Created by Akhilesh Bitla on 3/12/25.
//

import UIKit

class CompDescriptionViewController: UIViewController {

    @IBOutlet weak var compDescSegCtrl: UISegmentedControl!
    
    @IBOutlet weak var containerView: UIView!
    
    // Keep track of current child VC (embedded in the container)
    var currentChildVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        showSubview(index: compDescSegCtrl.selectedSegmentIndex)
    }
    
    @IBAction func onSegCtrlChanged(_ sender: UISegmentedControl) {
        showSubview(index: sender.selectedSegmentIndex)
    }
    
    // Show or hide subviews based on the selected segment index
    func showSubview(index: Int) {
        // Remove current child VC if exists
        if let child = currentChildVC {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        var newVC: UIViewController

        switch index {
        case 0:
            // Instantiate LineupSubviewViewController
            newVC = storyboard?.instantiateViewController(withIdentifier: "LineupSubviewViewController") as! UIViewController
        case 1:
            // Instantiate JudgingSubviewViewController
            newVC = storyboard?.instantiateViewController(withIdentifier: "JudgingSubviewViewController") as! UIViewController
        case 2:
            // Instantiate MediaSubviewViewController
            newVC = storyboard?.instantiateViewController(withIdentifier: "MediaSubviewViewController") as! UIViewController
        default:
            return
        }

        // Embed new VC
        addChild(newVC)
        newVC.view.frame = containerView.bounds
        containerView.addSubview(newVC.view)
        newVC.didMove(toParent: self)

        currentChildVC = newVC
    }
}
