//
//  TrackerTableViewController.swift
//  habit tracker
//
//  Created by Maks on 16.08.2020.
//  Copyright © 2020 Maxim. All rights reserved.
//

import UIKit
import CoreData

class TrackerTableViewController: UITableViewController {
    
    var habits: [Habit] = []
    
    
    @IBAction func addHabit(_ sender: UIBarButtonItem) {
        let alertContoller = UIAlertController(title: "New habit", message: "Text new habit", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let textField = alertContoller.textFields?.first
            if let newHabit = textField?.text {
                self.saveHabit(withTitle: newHabit)
                self.tableView.reloadData()
            }
        }
        
        alertContoller.addTextField { _ in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        alertContoller.addAction(saveAction)
        alertContoller.addAction(cancelAction)
        present(alertContoller, animated: true, completion: nil)
    }
    
    //    private func getDataFromFile() {
    //        guard let filePath = Bundle.main.path(forResource: "initalData", ofType: "plist"),
    //            let dataArray = NSArray(contentsOfFile: filePath) else { return }
    //
    //        for dict in dataArray {
    //
    //        }
    //    }
    
    private func saveHabit(withTitle title: String) {
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Habit", in: context) else { return }
        
        let habitObject = Habit(entity: entity, insertInto: context)
        habitObject.title = title
        habitObject.isDone = false
        habitObject.daysCheck = Array(repeating: false, count: 30)
        habitObject.order = Int16(habits.count)
        
        do {
            try context.save()
            habits.insert(habitObject, at: 0)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: UIBarButtonItem) {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
        if let objects = try? context.fetch(fetchRequest) {
            for object in objects {
                context.delete(object)
            }
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        habits = []
        tableView.reloadData()
        
    }
    
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
        let orderSort = NSSortDescriptor(key: "order", ascending: false)
        fetchRequest.sortDescriptors = [orderSort]
        
        do {
            habits = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
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
        newTaskVC.title = habit.title
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        guard segue.identifier == "Done action" else { return }
        let context = getContext()
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
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
        
        cell.textLabel?.text = habits[indexPath.row].title
        
        
        if habits[indexPath.row].isDone == true {
            cell.imageView?.image = .checkmark
            cell.textLabel?.alpha = 0.5
        }
        else {
            cell.textLabel?.alpha = 1
            cell.imageView?.image = UIImage(systemName: "circle")
        }
        
        if let currentDaysCheck = habits[indexPath.row].daysCheck {
            cell.detailTextLabel?.text = String(currentDaysCheck.filter{$0 == true}.count) + "/30"
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedData = habits.remove(at: sourceIndexPath.row)
        habits.insert(movedData, at: destinationIndexPath.row)
        
        //пробегаем по всему массиву, каждому объекту в order проставляем тот индекс, который они имеют после перемещения нужного объекта
        for (index, object) in habits.enumerated() {
            object.order = Int16(index)
        }
        
        let context = getContext()
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            
            let context = self.getContext()
            context.delete(self.habits[indexPath.row])
            self.habits.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
            for (index, object) in self.habits.enumerated() {
                object.order = Int16(index)
            }
            
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
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
            
            let context = self.getContext()
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            self.tableView.reloadData()
        }
        action.backgroundColor = UIColor.blue
        return action
    }
}
