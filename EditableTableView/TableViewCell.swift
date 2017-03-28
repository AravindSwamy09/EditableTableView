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
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    
    
    
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
        
        //Add a Pan Gesture recognizer
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        recognizer.delegate = self
        
        addGestureRecognizer(recognizer)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayet.frame = bounds
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Horizontal Pan Geasture methods
    func handlePan(recognizer:UIPanGestureRecognizer) {
        // 1
        if recognizer.state == .began {
            //When the gesture begins, record the current center location
            originalCenter = center
        }
        
        // 2
        if recognizer.state == .changed {
            
            let translation = recognizer.translation(in: self)
            center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            //Has the user dragged the item far to initiate a delete/complete?
            deleteOnDragRelease = frame.origin.x < -frame.size.width/2.0
        }
        //3
        if recognizer.state == .ended {
            //The frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            if !deleteOnDragRelease {
                //If the item is not being deleted, snap back to the original location
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
            }
            
        }
        
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    

}
