//
//  GigsTableViewController.swift
//  Gigs
//
//  Created by Akmal Nurmatov on 5/5/20.
//  Copyright © 2020 Akmal Nurmatov. All rights reserved.
//

import UIKit

class GigsTableViewController: UITableViewController {

    let reuseIdentifier = "GigCell"
    let gigController = GigController()
    private var gigs: [String] = []
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if gigController.bearer == nil {
            performSegue(withIdentifier: "LoginViewModalSegue", sender: self)
        } else {
            gigController.getAllGigs { (result) in
                    self.gigController.getAllGigs { (result) in
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                    }
                }
            }
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GigCell", for: indexPath)
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: gigController.gigs[indexPath.row].dueDate)
        cell.textLabel?.text = gigController.gigs[indexPath.row].title
        cell.detailTextLabel?.text = date
        
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gigController.gigs.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginViewModalSegue" {
            if let loginVC = segue.destination as? LoginViewController {
                loginVC.gigController = gigController 
            }
        } else if segue.identifier == "ShowGig" {
            if let detailVC = segue.destination as? GigDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                detailVC.gigController = gigController
                detailVC.gig = gigController.gigs[indexPath.row]
            }
        } else if segue.identifier == "AddGig" {
            if let newGigVC = segue.destination as? GigDetailViewController {
                newGigVC.gigController = gigController
            }
        }
    }

}
