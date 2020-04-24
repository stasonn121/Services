//
//  OrderClientTableViewController.swift
//  Services
//
//  Created by user on 27.03.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class OrderClientTableViewController: UITableViewController {

    var account: Client?
    let dataBase = CoreDataManaged.instance
    private var readyOrder: [Order] = []
    private var notReadyOrder: [Order] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBurButtonItem()
        let image = UIImage(named: UIConstants.Image.background)
        self.view.layer.contents = image?.cgImage
        tableView.register(UINib(nibName: String(describing: ProviderTableViewCell.self), bundle: nil),
        forCellReuseIdentifier: UIConstants.Cell.cell)
        dataBase.getAccountOrders(account: account!, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let orders):
                self.readyOrder = (self.dataBase.selectionOrder(orders: orders, ready: true))
                self.notReadyOrder = (self.dataBase.selectionOrder(orders: orders, ready: false))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                Alert.instance.showAlert(message: error.localizedDescription, viewController: self)
            }
        })
    }

    // MARK: - Table view data source
    private func createBurButtonItem() {
        let refreshTableButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTableView(sender:)))
        let backToLoginButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(backToLogin(sender:)))
        navigationItem.setLeftBarButtonItems([backToLoginButton,refreshTableButton], animated: true)
    }
    
    @objc private func backToLogin(sender: UITabBarItem) {
        performSegue(withIdentifier: UIConstants.sequeIndificator.comeBackClient, sender: self)
    }
    
    @objc private func refreshTableView(sender: UITabBarItem) {
        dataBase.getAccountOrders(account: account!, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let orders):
                self.readyOrder = (self.dataBase.selectionOrder(orders: orders, ready: true))
                self.notReadyOrder = (self.dataBase.selectionOrder(orders: orders, ready: false))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                Alert.instance.showAlert(message: error.localizedDescription, viewController: self)
            }
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 1 ? readyOrder.count : notReadyOrder.count
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == UIConstants.sequeIndificator.tasks ,
            let vc = segue.destination as? AvailableTasksTableView {
            vc.account = account
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIConstants.Cell.cell, for: indexPath) as! ProviderTableViewCell
        
        if indexPath.section == 1 {
            cell.taskName.text = readyOrder[indexPath.row].nameOrder
            cell.dateCreateTask.text = readyOrder[indexPath.row].date
            cell.readyButton.setImage(UIImage(systemName: "checkmark.seal"), for: .normal)
        } else {
            cell.taskName.text = notReadyOrder[indexPath.row].nameOrder
            cell.dateCreateTask.text = notReadyOrder[indexPath.row].date
            cell.readyButton.setImage(UIImage(systemName: "xmark.seal"), for: .normal)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Ready order"
        } else {
            return "Not ready order"
        }
    }
    
     @IBAction func saveDataFromAddMessageController(_ segue: UIStoryboardSegue){
        guard segue.identifier == UIConstants.sequeIndificator.listOrder else { return }
        dataBase.getAccountOrders(account: account!, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let orders):
                self.readyOrder = (self.dataBase.selectionOrder(orders: orders, ready: true))
                self.notReadyOrder = (self.dataBase.selectionOrder(orders: orders, ready: false))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                Alert.instance.showAlert(message: error.localizedDescription, viewController: self)
            }
        })
    }
}
