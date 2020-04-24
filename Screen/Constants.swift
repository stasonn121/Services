//
//  Constants.swift
//  Social App
//
//  Created by user on 20.03.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Foundation

enum UIConstants {
    enum sequeIndificator {
        static let logging = "logging"
        static let provider = "provider"
        static let client = "client"
        static let comeBackClient = "comeBackClient"
        static let comeBackProvider = "comeBackProvider"
        static let tasks = "tasks"
        static let saveOrder = "saveOrder"
        static let listServices = "listServices"
        static let listOrder = "listOrder"
        
    }
    
    enum Image {
        static let appIcon = "AppIcon"
        static let back = "back"
        static let background = "background"
        static let line = "line"
        static let mail = "mail"
        static let next = "next"
        static let okey = "okey"
        static let profileImage = "profileImage"
        
    }
    
    enum Cell {
        static let cell = "Cell"
    }
    
    enum Account {
        case provider
        case client
    }
    
    enum Database {
        static let providerMO = "ProviderMO"
        static let clientMO = "ClientMO"
        static let orderMO = "OrderMO"
        static let accountMO = "AccountMO"
        static let serviceMO = "ServiceMO"
    }
}
