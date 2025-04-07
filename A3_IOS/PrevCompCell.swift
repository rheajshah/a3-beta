//
//  PrevCompCell.swift
//  A3_IOS
//
//  Created by Rhea Shah on 3/12/25.
//

import Foundation
import UIKit

class PrevCompCell: UITableViewCell {
    @IBOutlet var prevCompImageView: UIImageView!
    @IBOutlet var prevCompDate: UILabel!
    @IBOutlet var prevCompName: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        prevCompImageView.image = nil
    }
}
