//
//  TableViewCell.swift
//  EditableTableView
//
//  Created by ESS Mac Pro on 3/28/17.
//  Copyright © 2017 NGA Group Inc. All rights reserved.
//

import UIKit

//A protocol that the TableViewCell uses to inform its delegate of state change
protocol TableViewCellDelegate{
    
    //Indicates that the given item is deleted.
    func toDoItemDeleted(toDoItem:ToDoItem)
    
}

class TableViewCell: UITableViewCell {

    //The object that acts as delete for this cell.
    var delegate : TableViewCellDelegate?
    
    //The item that this cell renders.
    var todoItem : ToDoItem?{
        didSet{
            label.text = todoItem?.text
            label.strikeThrough = (todoItem?.completed)!
            itemCompleteLayer.isHidden = !label.strikeThrough
        }
    }
    
    
    let gradientLayet = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false,completeOnDragRelease = false
    
    var tickLabel:UILabel!, crossLabel:UILabel!
    
    let label : StrikeThroughText
    var itemCompleteLayer = CALayer()
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        label = StrikeThroughText(frame:CGRect.null)
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = .clear
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
        
        //Gradient layer for cell
        gradientLayet.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).cgColor as CGColor
        let color2 = UIColor(white: 1.0, alpha: 0.1).cgColor as CGColor
        let color3 = UIColor.clear.cgColor as CGColor
        let color4 = UIColor(white: 0.0, alpha: 0.1).cgColor as CGColor
        
        gradientLayet.colors = [color1,color2,color3,color4]
        
        gradientLayet.locations = [0.0,0.01,0.95,1.0]
        
        layer.insertSublayer(gradientLayet, at: 0)
        
        //Tick and Cross labels for context cues
        tickLabel = createCueLabel()
        tickLabel.text = "\u{2713}"
        tickLabel.textAlignment = .right
        addSubview(tickLabel)
        crossLabel = createCueLabel()
        crossLabel.text = "\u{2717}"
        crossLabel.textAlignment = .left
        addSubview(crossLabel)
        
        //Add a layer that renders a green background when an item is complete
        itemCompleteLayer = CALayer(layer: layer)
        itemCompleteLayer.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0).cgColor
        itemCompleteLayer.isHidden = true
        layer.insertSublayer(itemCompleteLayer, at: 0)
        
        //Add a Pan Gesture recognizer
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        recognizer.delegate = self
        
        addGestureRecognizer(recognizer)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    let kLabelLeftMargin:CGFloat = 15.0
    let kUICuesMargin:CGFloat = 10.0,kUICueswidth:CGFloat = 50.0
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Ensure the gradient layer occupies the full bounds
        gradientLayet.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0, width: bounds.size.width - kLabelLeftMargin, height: bounds.size.height)
        
        tickLabel.frame = CGRect(x: -kUICueswidth - kUICuesMargin, y: 0, width: kUICueswidth, height: bounds.size.height)
        crossLabel.frame = CGRect(x: bounds.size.width + kUICuesMargin, y: 0, width: kUICueswidth, height: bounds.size.height)
        
        
    }

    //Utility method for creating the contextual cues.
    func createCueLabel() -> UILabel {
        let label = UILabel(frame: CGRect.null)
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 32.0)
        label.backgroundColor = .clear
        return label
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
            completeOnDragRelease = frame.origin.x > frame.size.width/2.0
            
            //Fade contextual cues
            let cueAlpha = fabs(frame.origin.x)/(frame.size.width/2.0)
            tickLabel.alpha = cueAlpha
            crossLabel.alpha = cueAlpha
            //Indicate when the user has pulled the item far enough to invoke the given action
            tickLabel.textColor = completeOnDragRelease ? .green : .white
            crossLabel.textColor = deleteOnDragRelease ? .red : .white
            
        }
        //3
        if recognizer.state == .ended {
            //The frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
//            if !deleteOnDragRelease {
//                //If the item is not being deleted, snap back to the original location
//                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
//            }
            
            if deleteOnDragRelease {
                if delegate != nil && todoItem != nil {
                    //Notify the delegate that this item should be deleted.
                    delegate!.toDoItemDeleted(toDoItem: todoItem!)
                }
            }else if completeOnDragRelease{
                if todoItem != nil {
                    todoItem!.completed = true
                }
                label.strikeThrough = true
                itemCompleteLayer.isHidden = false
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
            }else{
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
