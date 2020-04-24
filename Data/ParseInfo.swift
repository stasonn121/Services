//
//  ParseInfo.swift
//  My Friends
//
//  Created by user on 12.03.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ParsingInfo {
    
    init() {
    }

    func receiveArrayPost(completion: @escaping (Result<[FriendLocal], Error>) -> Void) {
        let request = AF.request("https://randomapi.com/api/9hupbi4a?key=52LF-6UVI-AH21-8RJT")
            request.responseJSON { responseJSON in
            DispatchQueue.main.async {
                switch responseJSON.result {
                case .success(let value):
                    guard let jsonFriend = value  as? [String: Any],
                    let server = jsonFriend["results"] as? Array<Any>,
                    let value  = server[0] as? [String:Any] else { return }
                    
                    let friends = self.parsing(array: value)
                    
                    completion(.success(friends))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func parsing(array: [String:Any]) -> [FriendLocal] {
        var friends: [FriendLocal] = []
        
        for index in 0..<array.count {
            guard
                let human = array["\(index)"] as? [String: Any],
                let name = human["name"] as? String,
                let text = human["text"] as? String,
                let url = human["image"] as? String
                else { continue }
            
            let friend = FriendLocal(name: name, aboutFriend: text, imageURL: url, friendship: true)
                
            friends.append(friend)
        }
    return friends
    }
}

