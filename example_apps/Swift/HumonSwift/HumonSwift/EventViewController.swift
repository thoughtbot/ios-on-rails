//
//  EventViewController.swift
//  HumonSwift
//
//  Created by Diana Zmuda on 2/4/15.
//  Copyright (c) 2015 Diana Zmuda. All rights reserved.
//

import UIKit
import CoreLocation
// Book Notes:
// tell people to change nib to use static cells
// tell people to add VC as start/end delegate

class EventViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var startAtTextField: UITextField!
    @IBOutlet weak var endAtTextField: UITextField!

    var client = HumonClient()
    var coordinate: CLLocationCoordinate2D?

    private var fieldsAreValid: Bool {
        return nameTextField.text?.characters.count > 0 &&
            addressTextField.text?.characters.count > 0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func saveEvent(_ sender: UIBarButtonItem) {
        if fieldsAreValid == true {
            let event = Event(name: nameTextField.text ?? "",
                              address: addressTextField.text ?? "",
                              coordinate: coordinate ?? CLLocationCoordinate2D(),
                              startDate: (startAtTextField.inputView as? UIDatePicker)?.date ?? Date(),
                              endDate: (endAtTextField.inputView as? UIDatePicker)?.date)
            client.postEvent(event: event) { [weak self] in
                _ = self?.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            // show fields are invalid
        }
    }

    // BOOK NOTE: tell people how to connect this method to editing did begin

    @IBAction func datePickerEditingDidBegin(_ sender: UITextField) {
        let datePicker = UIDatePicker()
        sender.inputView = datePicker
        datePicker.addTarget(self,
                             action: #selector(EventViewController.datePickerValueChanged),
                             for: .valueChanged)
    }

    func datePickerValueChanged(sender: UIDatePicker) {
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
        let date = dateFormatter.string(from: sender.date)
        if sender == startAtTextField.inputView {
            startAtTextField.text = date
        } else if sender == endAtTextField.inputView {
            endAtTextField.text = date
        }
    }

}
