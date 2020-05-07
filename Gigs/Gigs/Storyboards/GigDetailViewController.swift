//
//  GigDetailViewController.swift
//  Gigs
//
//  Created by Akmal Nurmatov on 5/6/20.
//  Copyright © 2020 Akmal Nurmatov. All rights reserved.
//

import UIKit

class GigDetailViewController: UIViewController {

    @IBOutlet weak var jobTitleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var gigController: GigController!
    var gig: Gig?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateViews(with: gig)
    }
    
    func updateViews(with gig: Gig?) {
        if let gig = gig {
            jobTitleTextField.text = gig.title
            descriptionTextView.text = gig.description
            datePicker.setDate(gig.dueDate, animated: true)
        } else {
            title = "New Gig"
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let date = datePicker.date
        if let title = jobTitleTextField.text,
            !title.isEmpty, let description = descriptionTextView.text,
            !description.isEmpty {
            let newGig = Gig(title: title, dueDate: date, description: description)
            gigController.createGig(with: newGig) { (result) in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
    
    
    


