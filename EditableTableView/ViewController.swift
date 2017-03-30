//
//  ViewController.swift
//  EditableTableView
//
//  Created by ESS Mac Pro on 3/28/17.
//  Copyright © 2017 NGA Group Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController,TableViewCellDelegate {

    @IBOutlet var tableView: UITableView!
    
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
        
    }
    
    //MARK: - TableViewCellDelegate
    
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

}

//MARK: DataSource

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

//MARK: Delegates

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


