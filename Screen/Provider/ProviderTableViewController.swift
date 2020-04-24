//
//  TableViewController.swift
//  Services
//
//  Created by user on 26.03.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class ProviderTableViewController: UITableViewController {

    var accountProvider: Provider?
    var listOrder: [Order] = []
    let dataBase = CoreDataManaged.instance
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: UIConstants.Image.background)
        self.view.layer.contents = image?.cgImage
        tableView.register(UINib(nibName: String(describing: ProviderTableViewCell.self), bundle: nil), forCellReuseIdentifier: UIConstants.Cell.cell)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        dataBase.getPrividerOrder(account: accountProvider!, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let orders):
                self.listOrder = self.dataBase.selectionOrder(orders: orders, ready: false)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                Alert.instance.showAlert(message: error.localizedDescription, viewController: self)
            }
        })
        
        let backToLoginButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(backToLogin(sender:)))
        navigationItem.leftBarButtonItem = backToLoginButton
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    @objc private func backToLogin(sender: UITabBarItem) {
        performSegue(withIdentifier: UIConstants.sequeIndificator.comeBackProvider, sender: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return listOrder.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIConstants.Cell.cell, for: indexPath) as! ProviderTableViewCell

        cell.taskName.text = listOrder[indexPath.section].nameOrder
        cell.dateCreateTask.text = listOrder[indexPath.section].date
        cell.readyButton.setImage(UIImage(systemName: "checkmark.seal"), for: .normal)
        cell.delegate = self

        return cell 
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == UIConstants.sequeIndificator.listServices,
        let taskVC = segue.destination as? TaskTableViewController {
            taskVC.accountProvider = accountProvider
        }
    }

}

extension ProviderTableViewController: TableViewCellDelegate {
    func clickOn(_ cell: ProviderTableViewCell) {
        if let index = tableView.indexPath(for: cell) {
            
            dataBase.updateStatusOrder(order: listOrder[index.section])
           // listOrder[index.section].ready = true
            listOrder.remove(at: index.section)
            let indexSet = IndexSet(arrayLiteral: index.section)
            tableView.deleteSections(indexSet, with: .automatic)
        }
    }


}
