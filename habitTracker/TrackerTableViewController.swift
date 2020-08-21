//
//  TrackerTableViewController.swift
//  habit tracker
//
//  Created by Maks on 16.08.2020.
//  Copyright © 2020 Maxim. All rights reserved.
//

import UIKit

class TrackerTableViewController: UITableViewController {
    
    var habits =
        [
            Habit(tittle: "Swipe left to delete"),
            Habit(tittle: "Swipe right to mark done"),
            Habit(tittle: "3"),
            Habit(tittle: "4", isDone: true, dayCheck: [true])
    ]
    
    @IBAction func addHabit(_ sender: UIBarButtonItem) {
        let alertContoller = UIAlertController(title: "New habit", message: "Text new habit", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let textField = alertContoller.textFields?.first
            if let newHabit = textField?.text {
                self.habits.insert(Habit(tittle: newHabit), at: 0)
                self.tableView.reloadData()
                
            }
        }
        
        alertContoller.addTextField { _ in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        alertContoller.addAction(saveAction)
        alertContoller.addAction(cancelAction)
        
        present(alertContoller, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        tableView.tableFooterView = UIView() // убираем нижние ячейки
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "daysCheck" else { return }
        let indexPath = tableView.indexPathForSelectedRow!
        let habit = habits[indexPath.row]
        let navigationVC = segue.destination as! UINavigationController
        let newTaskVC = navigationVC.topViewController as! TrackerCollectionViewController
        newTaskVC.habit = habit
        newTaskVC.title = habit.tittle
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        //        guard segue.identifier == "doneSegue" else { return }
        tableView.reloadData()
        
        
        // Use data from the view controller which initiated the unwind segue
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return habits.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = habits[indexPath.row].tittle
        
        
        if habits[indexPath.row].isDone == true {
            cell.imageView?.image = .checkmark
            cell.textLabel?.alpha = 0.5
        }
        else {
            cell.textLabel?.alpha = 1
            cell.imageView?.image = UIImage(systemName: "circle")
        }
        
        cell.detailTextLabel?.text = String(habits[indexPath.row].dayCheck.filter{$0 == true}.count) + "/30"

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            habits.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedData = habits.remove(at: sourceIndexPath.row)
        habits.insert(movedData, at: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.habits.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = doneAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [done])
    }
    
    func doneAction(at indexPath: IndexPath) -> UIContextualAction{
        
        let action = UIContextualAction(style: .normal, title: "Done") { (action, view, completion) in
            self.habits[indexPath.row].isDone = !self.habits[indexPath.row].isDone
            
            if self.habits[indexPath.row].isDone {
                
                let movedData = self.habits.remove(at: indexPath.row)
                self.habits.append(movedData)
                
            }
            else {
                let movedData = self.habits.remove(at: indexPath.row)
                self.habits.insert(movedData, at: 0)
            }
            self.tableView.reloadData()
        }
        action.backgroundColor = UIColor.blue
        return action
    }
}
