//
//  CoreDataMenaged.swift
//  My Friends
//
//  Created by user on 12.03.2020.
//  Copyright © 2020 user. All rights reserved.

import UIKit
import CoreData

class CoreDataManaged {
    
    let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    static let instance = CoreDataManaged()
    
    private init() {}
    
    func createAccount(login: String, password: String, side: UIConstants.Account) {
        guard let context = container?.viewContext else { return }
        
        let newAccount = AccountMO(context: context)
        
        if side == UIConstants.Account.client {
            let newClient = ClientMO(context: context)
            newClient.name = login
            newAccount.client = newClient
        } else {
            let newProvider = ProviderMO(context: context)
            newProvider.name = login
            newAccount.provider = newProvider
        }
        
        newAccount.login = login
        newAccount.password = password
        
        
        do{
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getAccountLogin(login: String, password: String) -> Account? {
        guard let context = container?.viewContext else { return Account(login: "", password: "")}
        
        var friends = [AccountMO]()
        let dataRequest: NSFetchRequest<AccountMO> = AccountMO.fetchRequest()
        let predicate = NSPredicate(format: "login  == %@ AND password == %@", login, password)
        dataRequest.predicate = predicate
        
        do{
            friends = try context.fetch(dataRequest)
        } catch let error {
            print(error.localizedDescription)
        }
        
        return convertToAccount(accountMO: friends.first)
    }
    
    func checkLogin(login: String) -> Account? {
        guard let context = container?.viewContext else { return Account(login: "", password: "")}
        
        var friends = [AccountMO]()
        let dataRequest: NSFetchRequest<AccountMO> = AccountMO.fetchRequest()
        let predicate = NSPredicate(format: "login  == %@ ", login)
        dataRequest.predicate = predicate
        
        do{
            friends = try context.fetch(dataRequest) 
        } catch let error {
            print(error.localizedDescription)
        }
        
        return convertToAccount(accountMO: friends.first)
    }
    
    func getAllService(completion: @escaping (Result<[Service], Error>) -> Void) {
       // guard let context = container?.viewContext else { return }
        
        var servicesMO = [ServiceMO]()
        let dataRequest: NSFetchRequest<ServiceMO> = ServiceMO.fetchRequest()
        
        container?.performBackgroundTask{ (context) in
            do{
                servicesMO = try context.fetch(dataRequest)
                
                var services = [Service]()
                       
                for serviceMO in servicesMO
                    {
                        if let service = self.convertService(serviceMO: serviceMO) {
                            services.append(service)
                        }
                    }
                completion(.success(services))
            } catch let error {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func getServices(account: Provider, completion: @escaping (Result<[Service], Error>) -> Void) {
        
        container?.performBackgroundTask{ (context) in
                       
            var services = [Service]()

            if let accountMO = self.getAccountMO(login: account.name),
                let servicesMO = accountMO.provider?.services?.allObjects as? [ServiceMO] {
                
                for serviceMO in servicesMO {
                    if let service = self.convertService(serviceMO: serviceMO) {
                        services.append( service )
                    }
                }
            }
            completion(.success(services))
        }
    }
    
    func setService(account: Provider, nameService: String) {
        guard let context = container?.viewContext else { return }
        
        let accountMO = getAccountMO(login: account.name)?.provider
        let newService = ServiceMO(context: context)
        
        newService.name = nameService
        
        accountMO?.addToServices(newService)
        
         do{
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func setOrder(account: Client, nameOrder: String, provider: Provider, date: String) {
        guard let context = container?.viewContext else { return }
        
        let accountMO = getAccountMO(login: account.name)
        let newOrder = OrderMO(context: context)
              
        newOrder.nameOrder = nameOrder
        newOrder.provider = getAccountMO(login: provider.name)?.provider
        newOrder.date = date
        newOrder.ready = false
        
        accountMO!.client?.addToOrder(newOrder)
        
        
        
        do{
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getAccountOrders(account: Client, completion: @escaping (Result<[Order], Error>) -> Void){
        container?.performBackgroundTask{ (context) in
            var orders = [Order]()
            
            if let accountMO = self.getAccountMO(login: account.name),
                let ordersMO = accountMO.client?.order?.allObjects as? [OrderMO] {
                
                for orderMO in ordersMO {
                    orders.append( self.convertToOrder(orderMO: orderMO)
                        ?? Order(nameOrder: "", provider: Provider(name: ""), date: "", ready: true) )
                }
            }
            completion(.success(orders))
        }
    }
    
    func getPrividerOrder(account: Provider, completion: @escaping (Result<[Order], Error>) -> Void) {
        //guard let context = container?.viewContext else { return }
        
        container?.performBackgroundTask{ (context) in
            var ordersMO = [OrderMO]()
                
            ordersMO = self.getAccountMO(login: account.name)?.provider?.order?.allObjects as! [OrderMO]
            
            var orders = [Order]()
            for orderMO in ordersMO {
                if let order = self.convertToOrder(orderMO: orderMO) {
                    orders.append(order)
                }
            }
            completion(.success(orders))
             
        }
    }
    
    func selectionOrder(orders: [Order], ready: Bool) -> [Order] {
        
        var selectionOrders = [Order]()
        
        for order in orders {
            if order.ready == ready {
                selectionOrders.append(order)
            }
        }
        return selectionOrders
    }
    
    func updateStatusOrder(order: Order) {
        guard let context = container?.viewContext else { return }
    
        var ordersMO = [OrderMO]()
        ordersMO = getAccountMO(login: order.provider.name)?.provider?.order?.allObjects as! [OrderMO]
        ordersMO.filter({$0.nameOrder == order.nameOrder && $0.ready == false}).first?.ready = true
        
        do{
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func sideAccount(account: Account) -> UIConstants.Account {
        let accountMO = getAccountMO(login: account.login)
        if let _ = accountMO?.provider {
            return UIConstants.Account.provider
        } else {
            return UIConstants.Account.client
        }
        
    }
    
    func deleteOblect(service: Service?, order: Order?, client: Client?, provider: Provider?){
        guard let context = container?.viewContext else { return }
        
        if let serviceMO = service, let providerMO = provider {
            context.delete(getServiceMO(service: serviceMO, account: providerMO)!)
        }
         if let order = order, let clientMO = client {
                context.delete(getOrderMO(order: order, account: clientMO)!)
        }
        
        do {
            try context.save()
        } catch {
            
        }
    }
    
    func deleteAll() {
        do {
            try container?.viewContext.execute(NSBatchDeleteRequest(fetchRequest: ServiceMO.fetchRequest()))
            try container?.viewContext.save()
        } catch {
        }
    }
    
    private func convertToAccount(accountMO: AccountMO?) -> Account? {
        var account: Account?
        if let login = accountMO?.login, let password = accountMO?.password {
            account = Account(login: login, password: password)
        }
        return account
    }
    
    private func convertToProvider(providerMO: ProviderMO?) -> Provider? {
        var provider: Provider?
        if let name = providerMO?.name {
            provider = Provider(name: name)
        }
        return provider
    }
    
    private func convertToClient(clientMO: ClientMO?) -> Client? {
        var client: Client?
        if let name = clientMO?.name {
            client = Client(name: name)
        }
        return client
    }
    
    private func convertService(serviceMO: ServiceMO?) -> Service? {
        var service: Service?
        if let name = serviceMO?.name, let provider = convertToProvider(providerMO: serviceMO?.provider) {
            service = Service(name: name, provider: provider)
        }
        return service
    }
    
    private func convertToOrder(orderMO: OrderMO?) -> Order? {
        var order: Order?
        if let nameOrder = orderMO?.nameOrder, let providerName = orderMO?.provider?.name, let date = orderMO?.date, let ready = orderMO?.ready {
            order = Order(nameOrder: nameOrder, provider: Provider(name: providerName), date: date, ready: ready)
        }
        return order
    }
    
    private func getAccountMO(login: String) -> AccountMO? {
        guard let context = container?.viewContext else { return AccountMO()}
        
        var friends = [AccountMO]()
        let dataRequest: NSFetchRequest<AccountMO> = AccountMO.fetchRequest()
        let predicate = NSPredicate(format: "login  == %@", login)
        dataRequest.predicate = predicate
        
        do{
            friends = try context.fetch(dataRequest) 
        } catch let error {
            print(error.localizedDescription)
        }
        return friends.first
    }
    
    private func getServiceMO(service: Service, account: Provider) -> ServiceMO? {
        let accountMO = getAccountMO(login: account.name)
        let servicesMO = accountMO?.provider?.services?.allObjects as! [ServiceMO]
        
        return servicesMO.filter({$0.name == service.name}).first
    }
    
    private func getOrderMO(order: Order, account: Client) -> OrderMO? {
        let accountMO = getAccountMO(login: account.name)
        let ordersMO = accountMO?.client?.order?.allObjects as! [OrderMO]
        
        return ordersMO.filter({$0.nameOrder == order.nameOrder && $0.provider?.name == order.provider.name}).first
    }
}

