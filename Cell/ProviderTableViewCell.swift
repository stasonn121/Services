//
//  TableViewCell.swift
//  My Friends
//
//  Created by user on 07.03.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
    func clickOn(_ cell: ProviderTableViewCell)
}

class ProviderTableViewCell: UITableViewCell {

    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var dateCreateTask: UILabel!
    var delegate: TableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
        // Initialization code
    }
    
    @IBAction func click(_ sender: UIButton) {
        delegate?.clickOn(self)
    }
}


