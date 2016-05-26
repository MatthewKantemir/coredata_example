/**
 * @file   PurchaseTVC.swift
 * @author Matthew Kantemir <matthew.kantemir@gmail.com
 * @date   2016-04-11
 *
 * This file is part of coredata_example.
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */

import UIKit

class PurchaseTVC: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productQuantityLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productModelLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        productImageView.layer.cornerRadius = productImageView.frame.width / 2
        productImageView.clipsToBounds = true
        productImageView.contentMode = UIViewContentMode.ScaleAspectFit
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
