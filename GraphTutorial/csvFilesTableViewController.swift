//
//  csvFilesTableViewController.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 27/08/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import UIKit
import MSGraphClientModels

class csvFilesTableViewController: UITableViewController {
    
    private let tableCellIdentifier = "csvFileCell"
    private let spinner = SpinnerViewController()
    var csvFiles: [MSGraphDriveItem]?
    
    @IBOutlet weak var tblCsvFiles: UITableView!
    
    @IBAction func signOut() {
        AuthenticationManager.instance.signOut()
        self.performSegue(withIdentifier: "userSignedOut", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        // Do any additional setup after loading the view.
        self.spinner.start(container: self)

        GraphManager.instance.getCsvFiles { (csvFilesArray: [MSGraphDriveItem]?, error: Error?) in
            DispatchQueue.main.async {
                self.spinner.stop()
                
                guard let unwrappedCsvFiles = csvFilesArray, error == nil else {
                    // Show the error
                    let alert = UIAlertController(title: "Error getting files",
                                                  message: error.debugDescription,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                self.csvFiles = unwrappedCsvFiles
                self.tableView.reloadData()
            }
        }
    }

    // Number of sections, always 1
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Return the number of events in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return events?.count ?? 0
        return csvFiles?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as! csvFilesTableViewCell

        // Get the csv file that corresponds to the row
        let csvFile = csvFiles?[indexPath.row]
        
        // Configure the cell
        let csvFileNameComponents = csvFile?.name?.components(separatedBy: ["_", "."])
        cell.device = csvFileNameComponents?[0].replacingOccurrences(of: "-", with: " ")
        
        // Build date and time string
        cell.dateTime = formatFileDateTime(csvNameDate: csvFileNameComponents?[1])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showData", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showData" {
            let tabCtrl = segue.destination as! BaseTabBarController
            if let indexPath = self.tblCsvFiles.indexPathForSelectedRow {
                let selectedRow = csvFiles?[indexPath.row]
                tabCtrl.csvFile = selectedRow
            }
        }
    }
    
    private func formatFileDateTime(csvNameDate: String?) -> String {
        guard let startDateTime = csvNameDate else {
            return ""
        }

        // Create a formatter to parse files date format
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyyMMddHHmm"

        let dateFormatterDisplay = DateFormatter()
        dateFormatterDisplay.dateFormat = "MMM dd, yyyy   HH:mm"

        let date = dateFormatterGet.date(from: startDateTime)
        if let newDate = date {
            return dateFormatterDisplay.string(from: newDate)
        }
        return "Date not in format yyyMMddHHmm"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
