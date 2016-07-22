//
//  UserSession.swift
//  HumonSwift
//
//  Created by Diana Zmuda on 2/5/15.
//  Copyright (c) 2015 Diana Zmuda. All rights reserved.
//

import Foundation
import Locksmith

struct UserSession {

    private static var storedUserID: Int?
    private static var storedUserToken: String?

    static var userID: Int? {
        set {
            storedUserID = newValue
            saveUserData()
        }
        get {
            loadUserData()
            return storedUserID
        }
    }

    static var userToken: String? {
        set {
            storedUserToken = newValue
            saveUserData()
        }
        get {
            loadUserData()
            return storedUserToken
        }
    }

    static var userIsLoggedIn: Bool {
        return userID != nil && userToken != nil
    }

    private static func loadUserData() {
        guard storedUserID == nil || storedUserToken == nil else { return }
        if let dictionary = Locksmith.loadDataForUserAccount(userAccount: "CurrentHumonAccount") {
            storedUserID = dictionary["userID"] as? Int
            storedUserToken = dictionary ["authToken"] as? String
        }
    }

    private static func saveUserData() {
        guard let storedUserID = storedUserID,
                  storedUserToken = storedUserToken else { return }
        _ = try? Locksmith.updateData(data: ["userID": storedUserID,
                                             "authToken": storedUserToken],
                                      forUserAccount: "CurrentHumonAccount")
    }
}
