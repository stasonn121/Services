//
//  AvailableTasksTableView.swift
//  Services
//
//  Created by user on 27.03.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class AvailableTasksTableView: UITableViewController {

    let dataBase = CoreDataManaged.instance
    var tasks: [Service] = []
    var orders: [Order] = []
    var account: Client?
    let picker = UIDatePicker()
    var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataBase.getAllService(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let tasks):
                self.tasks = tasks
            case .failure(let error):
                Alert.instance.showAlert(message: error.localizedDescription, viewController: self)
            }
        })
        
        dataBase.getAccountOrders(account: account!, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let orders):
                self.orders = self.dataBase.selectionOrder(orders: orders, ready: false)
                DispatchQueue.main.async {
                    self.taskReady()
                    self.tableView.reloadData()
                }
            case .failure(let error):
                Alert.instance.showAlert(message: error.localizedDescription, viewController: self)
            }
        })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIConstants.Cell.cell, for: indexPath)

        cell.textLabel?.text = tasks[indexPath.section].name
        cell.detailTextLabel?.text = tasks[indexPath.section].provider.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tasks[indexPath.section].ready == true else {
            Alert.instance.showAlert(message: "Order performed", viewController: self)
            return
        }
        
        dateForOrder(cell: tableView.cellForRow(at: indexPath)!, indexPath: indexPath)
    }
    
    func dateForOrder(cell: UITableViewCell, indexPath: IndexPath) {
        alertController = UIAlertController(title: "Create new order", message: "Enter date", preferredStyle: .alert)
        alertController?.addTextField(configurationHandler: nil)
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm"
        alertController?.textFields?.first!.text = dateFormater.string(from: Date())
        
        let cancelButtonAction = UIAlertAction(title: "Cancel", style: .cancel)
        let createButtonAction = UIAlertAction(title: "Create", style: .default) {
            (action) -> Void in
            if let nameOrder = cell.textLabel?.text,
                let date = self.alertController?.textFields?.first?.text
            {
                let provider = self.tasks[indexPath.section].provider
                self.dataBase.setOrder(account: self.account!, nameOrder: nameOrder, provider: provider, date: date)
                self.performSegue(withIdentifier: UIConstants.sequeIndificator.listOrder, sender: self)
                
            }
        }
        picker.datePickerMode = .dateAndTime
        picker.minimumDate = Date()
        picker.center = view.center
        picker.addTarget( self,
                        action: #selector(timeInTextField(picker:textField:)),
                        for: .valueChanged)
        alertController?.textFields?.first?.inputView = picker
        if let alert = alertController {
            alert.addAction(createButtonAction)
            alert.addAction(cancelButtonAction)
        }
        present(alertController!, animated: true, completion: nil)
    }
    
    @objc func timeInTextField(picker: UIDatePicker, textField: UITextField) {
        let date = picker.date
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm"
        alertController?.textFields?.first!.text = dateFormater.string(from: date)
        
    }
   
    private func taskReady() {
        for index in 0 ..< tasks.count {
            if let _ = orders.filter({$0.nameOrder == tasks[index].name}).first {
                tasks[index].ready = false
            } else { tasks[index].ready = true }
        }
    }
}
