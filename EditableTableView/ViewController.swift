//
//  ViewController.swift
//  EditableTableView
//
//  Created by ESS Mac Pro on 3/28/17.
//  Copyright © 2017 NGA Group Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController,TableViewCellDelegate,UIScrollViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    let pinchGesutre = UIPinchGestureRecognizer()
    
    var toDoItems = [ToDoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if toDoItems.count > 0 {
            return
        }
        
        toDoItems.append(ToDoItem(text: "Feed the cat"))
        toDoItems.append(ToDoItem(text: "Buy Eggs"))
        toDoItems.append(ToDoItem(text: "Watch WWDC Videos"))
        toDoItems.append(ToDoItem(text: "Rule the web"))
        toDoItems.append(ToDoItem(text: "Buy a new iPhone"))
        toDoItems.append(ToDoItem(text: "Darn holes in socks"))
        toDoItems.append(ToDoItem(text: "Write this tutorial"))
        toDoItems.append(ToDoItem(text: "Master swift"))
        toDoItems.append(ToDoItem(text: "Learn to draw"))
        toDoItems.append(ToDoItem(text: "Get more exercise"))
        toDoItems.append(ToDoItem(text: "Catch up with mom"))
        toDoItems.append(ToDoItem(text: "Get a hair cut"))
    
        tableView.backgroundColor = .black
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
        
        pinchGesutre.addTarget(self, action: #selector(handlePinch(recognizer:)))
        tableView.addGestureRecognizer(pinchGesutre)
        
    }
    
    //MARK: - TableViewCellDelegate Methods
    
    func toDoItemDeleted(toDoItem: ToDoItem) {
        
        let index = (toDoItems as Array).index(of: toDoItem)
        if index == NSNotFound {
            return
        }
        
        //Could removeAtIndex in the loop but keep it here for when indexOfObject works.
        toDoItems.remove(at: index!)
        
//        //Use the UITableVIew to animate the removal of this row
//        tableView.beginUpdates()
//        let indexPathForRow = IndexPath(row: index!, section: 0)
//        tableView.deleteRows(at: [indexPathForRow], with: .fade)
//        tableView.endUpdates()

        //Loop over the visible cells to animate delete
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        let lastView = visibleCells[visibleCells.count - 1] as TableViewCell
        var delay = 0.0
        var startAnimating = false
        for i in 0..<visibleCells.count{
        
            let cell = visibleCells[i]
            if startAnimating {
                UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseInOut, animations: { () in
                    
                    cell.frame = cell.frame.offsetBy(dx: 0.0,
                                                     dy: -cell.frame.size.height)
                    
                }, completion: { (finished:Bool) in
                    
                    if cell == lastView{
                        self.tableView.reloadData()
                    }
                    
                })
                delay += 0.03
            }
            if cell.todoItem === toDoItem {
                startAnimating = true
                cell.isHidden = true
            }
            
        }
        
        //Use the UITableVIew to animate the removal of this row
        tableView.beginUpdates()
        let indexPathForRow = IndexPath(row: index!, section: 0)
        tableView.deleteRows(at: [indexPathForRow], with: .fade)
        tableView.endUpdates()
        
    }

    func cellDidBeginEditing(editingCell: TableViewCell) {
        
        let editingOffSet = tableView.contentOffset.y - editingCell.frame.origin.y as CGFloat
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell in visibleCells{
            UIView.animate(withDuration: 0.3, animations: { () in
                cell.transform = CGAffineTransform(translationX: 0, y: editingOffSet)
            })
            if cell != editingCell {
                cell.alpha = 0.3
            }
        }
        
    }
    
    func cellDidEndEditing(editingCell: TableViewCell) {
        
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell:TableViewCell in visibleCells {
            UIView.animate(withDuration: 0.3, animations: { () in
                cell.transform = CGAffineTransform.identity
                if cell != editingCell{
                    cell.alpha = 1.0
                }
            })
        }
        if editingCell.todoItem?.text == "" {
            toDoItemDeleted(toDoItem: editingCell.todoItem!)
        }
    }
    
    //MARK: - UIScrollViewDelegate Methods
    let placeHolderCell = TableViewCell(style: .default, reuseIdentifier: "Cell")
    
    //Indocates the state of the behavior
    var pullDownInProgress = false
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        //This behavior starts when a user pulls down while at the top of the table
        pullDownInProgress = scrollView.contentOffset.y <= 0.0
        placeHolderCell.backgroundColor = .red
        if pullDownInProgress {
            //Add the placeholder
            tableView.insertSubview(placeHolderCell, at: 0)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollViewContentOffSetY = scrollView.contentOffset.y
        
        if pullDownInProgress && scrollView.contentOffset.y <= 0.0 {
            placeHolderCell.frame = CGRect(x: 0, y: -tableView.rowHeight, width: tableView.frame.size.width, height: tableView.rowHeight)
            placeHolderCell.label.text = -scrollViewContentOffSetY > tableView.rowHeight ? "Release to add item" : "Pull to add item"
            placeHolderCell.alpha = min(1.0, -scrollViewContentOffSetY/tableView.rowHeight)
        }else{
            pullDownInProgress = false
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //Check whether the user pulled down far enough
        if pullDownInProgress && -scrollView.contentOffset.y > tableView.rowHeight {
            //TODO - Add a new item
            toDoItemAdded()
        }
        pullDownInProgress = false
        placeHolderCell.removeFromSuperview()
    }
    
    //MARK: - Add,Delete,Edit methods
    func toDoItemAdded() {
        
        toDoItemAddedAtIndex(index: 0)
        
    }
    
    func toDoItemAddedAtIndex(index:Int) {
        
        let toDoItem = ToDoItem(text: "")
        toDoItems.insert(toDoItem, at: index)
        tableView.reloadData()
        
        //Enter edit mode
        var editCell:TableViewCell
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell in visibleCells {
            if cell.todoItem === toDoItem {
                editCell = cell
                editCell.label.becomeFirstResponder()
                break
            }
        }
        
    }
    
    //MARK: - Pinch Gesture
    
    //Indicates that the pinch is in progress
    var pinchInProgress = false
    
    func handlePinch(recognizer:UIPinchGestureRecognizer) {
        
        if recognizer.state == .began {
            pinchStarted(recognizer: recognizer)
        }
        if recognizer.state == .changed && pinchInProgress && recognizer.numberOfTouches == 2 {
            pinchChanged(recognizer: recognizer)
        }
        if recognizer.state == .ended {
            pinchEnded(recognizer: recognizer)
        }
    }
    
    func pinchStarted(recognizer:UIPinchGestureRecognizer) {
        
        //Find the touch points
        initialTouchPoints = getNormalizedTouchPoints(recognizer: recognizer)
        
        //Locate the cells that these points touch
        upperCellIndex = -100
        lowerCellIndex = -100
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            
            if viewContainsPoint(view: cell, point: initialTouchPoints.upper) {
                upperCellIndex = i
                //Hightlight the cell just for debugging
//                cell.backgroundColor = .purple
            }
            if viewContainsPoint(view: cell, point: initialTouchPoints.lower) {
                lowerCellIndex = i
                //Hightlight the cell just for debugging
//                cell.backgroundColor = .purple
            }
        }
        
        //Check whether they are neighbors
        if abs(upperCellIndex - lowerCellIndex) == 1 {
            //Initiate pinch
            pinchInProgress = true
            //Show placeholder cell
            let precedingCell = visibleCells[upperCellIndex]
            placeHolderCell.frame = precedingCell.frame.offsetBy(dx: 0.0, dy: tableView.rowHeight / 2.0)
            placeHolderCell.backgroundColor = precedingCell.backgroundColor
            tableView.insertSubview(placeHolderCell, at: 0)
        }
        
    }
    
    func pinchChanged(recognizer:UIPinchGestureRecognizer) {
        
       //Find the touch points
        let currentTouchPoints = getNormalizedTouchPoints(recognizer: recognizer)
        
        //Determine by how much each touch point has changed, and take the minimum delta
        let upperDelta = currentTouchPoints.upper.y - initialTouchPoints.upper.y
        let lowerDelta = initialTouchPoints.lower.y - currentTouchPoints.lower.y
        let delta = -min(0, min(upperDelta, lowerDelta))
        
        //OffSet the cells, negative for the cells above, positive for those below
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if i <= upperCellIndex {
                cell.transform = CGAffineTransform(translationX: 0, y: -delta)
            }
            if i >= lowerCellIndex {
                cell.transform = CGAffineTransform(translationX: 0, y: delta)
            }
        }
        
        //Scale the placeholder cell
        let gapSize = delta * 2
        let cappedGapSize = min(gapSize, tableView.rowHeight)
        placeHolderCell.transform = CGAffineTransform(scaleX: 1.0, y: cappedGapSize/tableView.rowHeight)
        placeHolderCell.label.text = gapSize > tableView.rowHeight ? "Release to add item" : "Pull apart to add item"
        placeHolderCell.alpha = min(1.0, gapSize/tableView.rowHeight)
        
        //Has the user pinched far enough?
        pinchExceededRequiredDistance = gapSize > tableView.rowHeight
        
    }
    
    func pinchEnded(recognizer:UIPinchGestureRecognizer) {
        
        pinchInProgress = false
        
        //Remove the placeholder cell
        placeHolderCell.transform = CGAffineTransform.identity
        placeHolderCell.removeFromSuperview()
        
        if pinchExceededRequiredDistance {
            
            pinchExceededRequiredDistance = false
            
            //Set all the cells back to the transform identity
            let visibleCells = self.tableView.visibleCells as! [TableViewCell]
            for cell in visibleCells {
                cell.transform = CGAffineTransform.identity
            }
            
            //Add a new item
            let indexOffSet = Int(floor(tableView.contentOffset.y / tableView.rowHeight))
            toDoItemAddedAtIndex(index: lowerCellIndex + indexOffSet)
            
        }else{
            
            //Otherwise, animate back to position
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: { () in
                
                let visibleCells = self.tableView.visibleCells as! [TableViewCell]
                for cell in visibleCells{
                    cell.transform = CGAffineTransform.identity
                }
                
            }, completion: nil)
            
        }
        
    }
    
    //MARK: - Pinch To Add Methods
    struct TouchPoints {
        var upper : CGPoint
        var lower : CGPoint
    }
    
    //The indices of the upper and lower cells that are being pinched
    var upperCellIndex = -100
    var lowerCellIndex = -100
    
    //The location of the touch points when the pinch began
    var initialTouchPoints:TouchPoints!
    //Indicate that the pinch was big enough to cause a new item to be added
    var pinchExceededRequiredDistance = false
    
    //Returns the two touch points, ordering them to ensure that
    //Upper and  lower are correctly identified
    func getNormalizedTouchPoints(recognizer:UIGestureRecognizer) -> TouchPoints {
        
        var pointOne = recognizer.location(ofTouch: 0, in: tableView)
        var pointTwo = recognizer.location(ofTouch: 1, in: tableView)
        
        //Ensure point One is the top most
        if pointOne.y > pointTwo.y {
            let temp = pointOne
            pointOne = pointTwo
            pointTwo = temp
        }
        return TouchPoints(upper: pointOne, lower: pointTwo)
    }
    
    func viewContainsPoint(view:UIView,point:CGPoint) -> Bool {
        
        let frame = view.frame
        return (frame.origin.y < point.y) && (frame.origin.y + (frame.size.height) > point.y)
        
    }
    
    
    
}

//MARK: - DataSource

extension ViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        let item = toDoItems[indexPath.row]
        
        cell.selectionStyle =  .none
//        cell.textLabel?.text = item.text
//        cell.textLabel?.backgroundColor = .clear
        cell.delegate = self
        cell.todoItem = item
        
        return cell
        
    }
    
}

//MARK: - Delegates

extension ViewController : UITableViewDelegate{
    
    func colorForIndex(index:Int) -> UIColor {
        
        let itemCount = toDoItems.count - 1
        
        let value = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        
        return UIColor(red: 1.0, green: value, blue: 0.0, alpha: 1.0)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = colorForIndex(index: indexPath.row)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Alert", message: "Some message", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: false, completion: nil)
    }
    
}


