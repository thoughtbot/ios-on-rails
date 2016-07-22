//
//  User.swift
//  HumonSwift
//
//  Created by Diana Zmuda on 2/5/15.
//  Copyright (c) 2015 Diana Zmuda. All rights reserved.
//

import Foundation

struct User {
    
    let userID: Int

    init?(JSON: [String : AnyObject]) {
        guard let userID =  JSON["id"] as? Int else { return nil }
        self.userID = userID
    }
    
    func isCurrentUser() -> Bool {
        return userID == UserSession.userID
    }
    
}
