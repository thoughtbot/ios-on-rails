//
//  UserSession.swift
//  HumonSwift
//
//  Created by Diana Zmuda on 2/5/15.
//  Copyright (c) 2015 Diana Zmuda. All rights reserved.
//

import Foundation

struct UserSession {
    static var userID: Int? {
        return 6
    }

    static var userToken: String? {
        set {
            // save to the keychain
        }
        get {
            return "bbf03df2-0666-4c83-ae2e-36f8bf959925"
        }
    }

    static var userIsLoggedIn: Bool {
        return userID != nil && userToken != nil
    }
}
