//
//  MapViewController.swift
//  HumonSwift
//
//  Created by Diana Zmuda on 2/4/15.
//  Copyright (c) 2015 Diana Zmuda. All rights reserved.
//

import UIKit
import MapKit
// Book Notes:
// tell people to add mapkit in link binary with libraries
// tell people to make VC delegate of mapview

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var client = HumonClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserSession.userIsLoggedIn {
            fetchEvents()
        } else {
            client.postUser { [weak self] in
                self?.fetchEvents()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let eventViewController = segue.destinationViewController as? EventViewController
            where segue.identifier == "AddEvent" else { return }

        eventViewController.coordinate = mapView.centerCoordinate
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        fetchEvents()
    }

    private func fetchEvents() {
        client.fetchEvents(region: mapView.region) { [weak self] (events: [Event]) in
            self?.mapView.addAnnotations(events)
        }
    }

}
