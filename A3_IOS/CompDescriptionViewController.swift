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
    
    // Reference to the child view controller (embedded in the container)
    var embeddedVC: CompSubviewsViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Make sure the embedded view controller is set up
        if let embeddedVC = children.first(where: { $0 is CompSubviewsViewController }) as? CompSubviewsViewController {
            self.embeddedVC = embeddedVC
        }
        
        // Default selection to show the first subview
        showSubview(index: compDescSegCtrl.selectedSegmentIndex)
    }
    
    @IBAction func onSegCtrlChanged(_ sender: UISegmentedControl) {
        showSubview(index: sender.selectedSegmentIndex)
    }
    
    // Show or hide subviews based on the selected segment index
    func showSubview(index: Int) {
        // Hide all subviews first
        embeddedVC?.hideAllSubviews()
        
        // Show the corresponding subview based on the index
        switch index {
        case 0:
            embeddedVC?.showLineupView()
        case 1:
            embeddedVC?.showJudgingView()
        case 2:
            embeddedVC?.showMediaView()
        default:
            break
        }
    }
}
