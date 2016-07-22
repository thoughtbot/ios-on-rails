//
//  Event.swift
//  HumonSwift
//
//  Created by Diana Zmuda on 2/5/15.
//  Copyright (c) 2015 Diana Zmuda. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

let dateFormatter = DateFormatter()

class Event: NSObject, MKAnnotation {
    
    let name: String
    let address: String
    let startDate: Date
    var endDate: Date?
    var user: User?
    var eventID: Int?

    // MKAnnotation
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D

    init(name: String, address: String, coordinate: CLLocationCoordinate2D, startDate: Date?, endDate: Date?) {
        self.name = name
        self.address = address
        self.startDate = startDate ?? Date()
        self.endDate = endDate
        self.title = self.name
        self.subtitle = self.address
        self.coordinate = coordinate
    }

    private init(name: String, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, startDate: Date, endDate: Date?, user: User, eventID: Int) {
        self.name = name
        self.address = address
        self.startDate = startDate
        self.endDate = endDate
        self.user = user
        self.eventID = eventID
        self.title = self.name
        self.subtitle = self.address
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    }

    init?(JSON: [String : AnyObject]) {
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        guard let address = JSON["address"] as? String,
            id = JSON["id"] as? Int,
            lat = JSON["lat"] as? CLLocationDegrees,
            lon = JSON["lon"] as? CLLocationDegrees,
            name = JSON["name"] as? String,
            startString = JSON["started_at"] as? String,
            startDate = dateFormatter.date(from: startString),
            userJSON = JSON["owner"] as? [String : AnyObject],
            user = User(JSON: userJSON)
            else { return nil }

        var endDate: Date?
        if let endDateString = JSON["end_at"] as? String {
            endDate = dateFormatter.date(from: endDateString)
        }

        self.name = name
        self.address = address
        self.startDate = startDate
        self.endDate = endDate
        self.user = user
        self.eventID = id
        self.title = self.name
        self.subtitle = self.address
        self.coordinate = CLLocationCoordinate2DMake(lat, lon)
    }

    func JSONDictionary() -> [String : AnyObject] {
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"

        var dictionary: [String : AnyObject] = [
            "name" : self.name,
            "address" : self.address,
            "lat" : self.coordinate.latitude,
            "lon" : self.coordinate.longitude,
            "started_at" : dateFormatter.string(from: self.startDate)]
        if let endDate = self.endDate {
            dictionary["end_at"] = dateFormatter.string(from: endDate)
        }

        return dictionary
    }

}
