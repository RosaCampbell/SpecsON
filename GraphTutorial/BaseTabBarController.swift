//
//  BaseTabBarController.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 2/09/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import UIKit
import MSGraphClientModels

class BaseTabBarController: UITabBarController {
    
    private let spinner = SpinnerViewController()
    private var fileContents: Data?
    private var url: String?
    var fileData = [[String:String]]()
    var csvFile: MSGraphDriveItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        GraphManager.instance.getFileURL(fileId: csvFile?.entityId ?? "") { (fileContentsData: Data?, fileURL: String?, error: Error?) in
            print("BaseTabBarController: GraphManager.instance.getFileURL")
            guard let fileContents = fileContentsData, error == nil else {
                // Show the error
                let alert = UIAlertController(title: "Error getting file contents",
                                          message: error.debugDescription,
                                          preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            self.fileContents = fileContents

            guard let UnwrappedUrl = fileURL, error == nil else {
                // Show the error
                let alert = UIAlertController(title: "Error getting file URL", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            self.url = UnwrappedUrl
            
            let csv = csvManager()
            self.fileData = csv.convertCSV(stringData: csv.readStringFromURL(stringURL: UnwrappedUrl), stringFileName: self.csvFile?.name ?? "nil")
            print("csv in array format")
        }
    }
}
