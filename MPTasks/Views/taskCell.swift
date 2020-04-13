//
//  taskCell.swift
//  MPTasks
//
//  Created by Santi Gracia on 4/10/20.
//  Copyright © 2020 Mixpanel. All rights reserved.
//

import Foundation
import UIKit
import SwipeCellKit

class taskCell : SwipeTableViewCell {
    
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var pending: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
