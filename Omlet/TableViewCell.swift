//
//  TableViewCell.swift
//  Omlet
//
//  Created by Sergey Libin on 25.07.17.
//  Copyright © 2017 Sergey Libin. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var ingredientsTextView: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
