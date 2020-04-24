//
//  TaskTableViewController.swift
//  Services
//
//  Created by user on 26.03.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class TaskTableViewController: UITableViewController {
    
    var accountProvider: Provider?
    var services: [Service] = []
    let dataBase = CoreDataManaged.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newServiceButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewService(sender:)))
        navigationItem.rightBarButtonItem = newServiceButton
        
        dataBase.getServices(account: accountProvider!, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let services):
                self.services = services
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                Alert.instance.showAlert(message: error.localizedDescription, viewController: self)
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return services.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    @objc func addNewService(sender: UITabBarItem) {
        let alertController = UIAlertController(title: "Create service", message: nil, preferredStyle: .alert)
       
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Type name your service"
            textField.borderStyle = .none
        })
        
        let cancelButtonAlert = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let okButtonAlert = UIAlertAction.init(title: "Ok", style: .default, handler: {
            (action) -> Void in
            self.dataBase.setService(account: self.accountProvider!, nameService: alertController.textFields?.first?.text ?? "" )
            self.dataBase.getServices(account: self.accountProvider!, completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let services):
                    self.services = services
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    Alert.instance.showAlert(message: error.localizedDescription, viewController: self)
                }
            })
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(okButtonAlert)
        alertController.addAction(cancelButtonAlert)
        present(alertController, animated: true, completion: nil)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIConstants.Cell.cell, for: indexPath)

        cell.textLabel?.text = services[indexPath.section].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            dataBase.deleteOblect(service: services[indexPath.section], order: nil, client: nil, provider: accountProvider)
            services.remove(at: indexPath.section)
            tableView.deleteSections(indexSet, with: .automatic)
         
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}
