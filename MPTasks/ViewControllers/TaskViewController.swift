//
//  TaskViewController.swift
//  MPTasks
//
//  Created by Santi Gracia on 4/6/20.
//  Copyright © 2020 Mixpanel. All rights reserved.
//

import Foundation
import UIKit
import SwipeCellKit

class TaskViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var emailAccount: UIButton!
    private var pullControl = UIRefreshControl()

    
    @IBAction func backToLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        allTasks = []
    }
    
    // Actions
    @objc private func refreshListData(_ sender: Any) {
        
        Data.getTasks { (status,message) in
            print("getting tasks")
            self.tableView.reloadData()
            self.pullControl.endRefreshing() // You can stop after API Call
            // Call API
        }
            
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self

        pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
                if #available(iOS 10.0, *) {
                    tableView.refreshControl = pullControl
                } else {
                    tableView.addSubview(pullControl)
        }

        
        self.setupHideKeyboardOnTap()
        
        emailAccount.setTitle(MPUSEREMAIL, for: .normal)

        
        Data.getTasks { (status,message) in
            print("getting tasks")
            self.tableView.reloadData()
        }

    }
    
        
    @IBAction func newTask(_ sender: Any) {
        Data.createTask(text: taskName.text ?? "") { (status, theMessage, theID) in
            Helper.showToast(controller: self, message: theMessage, seconds: 1.0, completion: { (result) in
                // refresh
                
                let tempTask = Task(id: theID, taskName: self.taskName.text ?? "", completed: false)
                allTasks.append(tempTask)
                self.tableView.reloadData()
                self.taskName.text = ""
                
            })
        }
    }
    

}

extension TaskViewController : UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! taskCell
        cell.delegate = self
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.contentView.layer.borderWidth = 10.0
        cell.contentView.layer.cornerRadius = 20
        cell.contentView.layer.masksToBounds = true
        
        if indexPath.section == 0 {
            cell.taskName.text = allTasks.filter { $0.completed == false }[indexPath.row].taskName
            cell.pending.setTitle("pending", for: .normal)
            cell.pending.backgroundColor = UIColor(cgColor: CGColor(srgbRed: 250/255, green: 195/255, blue: 17/255, alpha: 1))
            cell.pending.setTitleColor(UIColor(cgColor: CGColor(srgbRed: 67/255, green: 67/255, blue: 67/255, alpha: 1)), for: .normal)
        }
        else if indexPath.section == 1 {
            cell.taskName.text = allTasks.filter { $0.completed == true }[indexPath.row].taskName
            cell.pending.setTitle("completed", for: .normal)
            cell.pending.backgroundColor = UIColor(cgColor: CGColor(srgbRed: 36/255, green: 166/255, blue: 79/255, alpha: 1))
            cell.pending.setTitleColor(.white, for: .normal)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        //guard orientation == .right else { return nil }
        
        var updateID = 0
        if indexPath.section == 0 {
            updateID = allTasks.filter { $0.completed == false }[indexPath.row].id
        }
        else if indexPath.section == 1 {
            updateID = allTasks.filter { $0.completed == true }[indexPath.row].id
        }
        
        if orientation == .right {
           //Do Something with right swipe
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // handle action by updating model with deletion
                
                Data.deleteTask(taskid: updateID) { (result, theMessage) in
                    Helper.showToast(controller: self, message: theMessage, seconds: 1.0, completion: { (result) in
                        allTasks = allTasks.filter { $0.id != updateID }
                        self.tableView.reloadData()
                    })
                }
                
            }

            // customize the action appearance
            deleteAction.image = UIImage(named: "delete")

            return [deleteAction]
        }
        else {
          //Do Something with left swipe
            
            if indexPath.section == 0 {
                let completeAction = SwipeAction(style: .default, title: "Complete") { action, indexPath in
                    // handle action by updating model with completion
                    
                    Data.updateTask(taskid: updateID, newStatus: true) { (result, theMessage) in
                        Helper.showToast(controller: self, message: theMessage, seconds: 1.0, completion: { (result) in
                            let tempTask = allTasks.filter { $0.id == updateID }[0]
                                allTasks = allTasks.filter { $0.id != updateID }
                            tempTask.completed = true
                            allTasks.append(tempTask)
                                self.tableView.reloadData()
                            })
                    }
                    
                }
                completeAction.backgroundColor = UIColor(cgColor: CGColor(srgbRed: 36/255, green: 166/255, blue: 79/255, alpha: 1))
                return [completeAction]
            }
            else {
                let uncompleteAction = SwipeAction(style: .default, title: "Uncomplete") { action, indexPath in
                    // handle action by updating model with uncompletion
                    
                    Data.updateTask(taskid: updateID, newStatus: false) { (result, theMessage) in
                        Helper.showToast(controller: self, message: theMessage, seconds: 1.0, completion: { (result) in
                            let tempTask = allTasks.filter { $0.id == updateID }[0]
                                allTasks = allTasks.filter { $0.id != updateID }
                            tempTask.completed = false
                            allTasks.append(tempTask)
                                self.tableView.reloadData()
                            })
                    }
                    
                    
                }
                uncompleteAction.backgroundColor = UIColor(cgColor: CGColor(srgbRed: 250/255, green: 195/255, blue: 17/255, alpha: 1))
                return [uncompleteAction]
            }
            
            
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Pending Tasks" }
        else { return "Completed Tasks" }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return allTasks.filter { $0.completed == false }.count }
        else { return allTasks.filter { $0.completed == true }.count }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.tintColor = .white //use any color you want here .red, .black etc
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

}
