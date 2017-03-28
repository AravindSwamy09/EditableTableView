//
//  TableViewCell.swift
//  EditableTableView
//
//  Created by ESS Mac Pro on 3/28/17.
//  Copyright © 2017 NGA Group Inc. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    let gradientLayet = CAGradientLayer()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Gradient layer for cell
        gradientLayet.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).cgColor as CGColor
        let color2 = UIColor(white: 1.0, alpha: 0.1).cgColor as CGColor
        let color3 = UIColor.clear.cgColor as CGColor
        let color4 = UIColor(white: 0.0, alpha: 0.1).cgColor as CGColor
        
        gradientLayet.colors = [color1,color2,color3,color4]
        
        gradientLayet.locations = [0.0,0.01,0.95,1.0]
        
        layer.insertSublayer(gradientLayet, at: 0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        gradientLayet.frame = bounds
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
