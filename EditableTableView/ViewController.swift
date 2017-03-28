//
//  ViewController.swift
//  EditableTableView
//
//  Created by ESS Mac Pro on 3/28/17.
//  Copyright © 2017 NGA Group Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var toDoItem = [ToDoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if toDoItem.count > 0 {
            return
        }
        
        toDoItem.append(ToDoItem(text: "Feed the cat"))
        toDoItem.append(ToDoItem(text: "Buy Eggs"))
        toDoItem.append(ToDoItem(text: "Watch WWDC Videos"))
        toDoItem.append(ToDoItem(text: "Rule the web"))
        toDoItem.append(ToDoItem(text: "Buy a new iPhone"))
        toDoItem.append(ToDoItem(text: "Darn holes in socks"))
        toDoItem.append(ToDoItem(text: "Write this tutorial"))
        toDoItem.append(ToDoItem(text: "Master swift"))
        toDoItem.append(ToDoItem(text: "Learn to draw"))
        toDoItem.append(ToDoItem(text: "Get more exercise"))
        toDoItem.append(ToDoItem(text: "Catch up with mom"))
        toDoItem.append(ToDoItem(text: "Get a hair cut"))
    
        tableView.backgroundColor = .black
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    

}

//MARK: DataSource

extension ViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        let item = toDoItem[indexPath.row]
        
        cell.selectionStyle =  .none
        cell.textLabel?.text = item.text
        cell.textLabel?.backgroundColor = .clear
        
        return cell
        
    }
    
}

//MARK: Delegates

extension ViewController : UITableViewDelegate{
    
    func colorForIndex(index:Int) -> UIColor {
        
        let itemCount = toDoItem.count - 1
        
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


