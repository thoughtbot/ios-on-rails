//
//  HumonClient.swift
//  HumonSwift
//
//  Created by Diana Zmuda on 2/5/15.
//  Copyright (c) 2015 Diana Zmuda. All rights reserved.
//

import Foundation
import MapKit

class HumonClient {

    var session: URLSession
    let baseURL = URL(string: "https://humon-staging.herokuapp.com/v1/")!
    let appSecret = "yourOwnUniqueAppSecretThatYouShouldRandomlyGenerateAndKeepSecret"

    init() {
        let configuration = URLSessionConfiguration.ephemeral()
        if let token = UserSession.userToken {
            configuration.httpAdditionalHeaders = [
                "tb-auth-token": token,
                "Content-Type": "application/json",
                "Accept" : "application/json"
            ]
        } else {
            configuration.httpAdditionalHeaders = [
                "tb-app-secret": appSecret,
                "Content-Type": "application/json",
                "Accept" : "application/json"
            ]
        }
        session = URLSession(configuration: configuration)
    }

    func postUser(completion: () -> Void) {
        let url = URL(string: "users", relativeTo: baseURL)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"

        let task = session.dataTask(with: request as URLRequest) {
            [weak self] (data, response, error) in
            if let data = data,
                json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : AnyObject],
                token = json["auth_token"] as? String {
                let configuration = URLSessionConfiguration.ephemeral()
                configuration.httpAdditionalHeaders = [
                    "tb-auth-token": token,
                    "Content-Type": "application/json",
                    "Accept" : "application/json"
                ]

                self?.session.finishTasksAndInvalidate()
                self?.session = URLSession(configuration: configuration)
            }
            DispatchQueue.main.async { completion() }
        }

        task.resume()
    }

    func postEvent(event: Event, completion: () -> Void) {
        let url = URL(string: "events", relativeTo: baseURL)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        let dictionary = event.JSONDictionary()
        let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [])

        let task = session.uploadTask(with: request as URLRequest, from: data) {
            (data, response, error) in
            DispatchQueue.main.async { completion() }
        }

        task.resume()
    }

    func fetchEvents(region: MKCoordinateRegion, completion: ([Event]) -> Void) {
        // region.span.latitudeDelta/2*111 is how we find the aproximate radius
        // that the screen is displaying in km.
        let path = "events/nearests?lat=\(region.center.latitude)&lon=\(region.center.longitude)&radius=\(region.span.latitudeDelta/2*111)"
        let url = URL(string: path, relativeTo: baseURL)
        let request = NSMutableURLRequest(url: url!)

        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in
            if (error != nil) {
                DispatchQueue.main.async { completion([]) }
            } else if let data = data,
                json = (try? JSONSerialization.jsonObject(with: data,
                    options: [])) as? [[String : AnyObject]] {
                let events = json.map { Event(JSON: $0) }.flatMap { $0 }
                DispatchQueue.main.async { completion(events) }
            }
        }
        
        task.resume()
    }
}
