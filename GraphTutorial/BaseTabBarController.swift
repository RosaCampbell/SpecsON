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
    var numDays: Int = 0
    var hourAverages = [Double]()
    var dayAverages = [Double]()

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
            self.groupFileDataIntoDays()
            print("Array sectioned into hourly and daily averages")
        }
    }
    
    public func groupFileDataIntoDays()-> Void {
        print("groupFileDataIntoDays")
        var isStartDay = false
        var i = 0
        
        print("Finding start day")
        while !isStartDay {
            if fileData[i]["Date Time"]!.contains(" 00:0") {
                isStartDay = true
            }
            i += 1
        }
        print("Start day found at: \(String(describing: fileData[i-1]["Date Time"]))")
        
        numDays = Int((Double(fileData.count - (i-1)))/288.00) // Truncates Double
        
        for day in 0..<numDays {
            var dayAverageState = 0.00
            for hour in 0..<24 {
                var hourAverageState = 0.00
                for fiveMin in 0..<12 {
                    if let state = fileData[(i-1)+(day*24*12)+(hour*12)+fiveMin]["State"] {
                        hourAverageState += Double(state) ?? 0
                    }
                }
                hourAverages.append(hourAverageState/12.00)
                dayAverageState += hourAverages[day*24 + hour]
            }
            dayAverages.append(dayAverageState/24.00)
        }
    }
}
