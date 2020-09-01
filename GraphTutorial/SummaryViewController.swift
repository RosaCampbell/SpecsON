//
//  SummaryViewController.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 27/08/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import UIKit
import MSGraphClientModels
import Charts

class SummaryViewController: UIViewController, ChartViewDelegate {
    
    
    private let spinner = SpinnerViewController()
    private var summaryLineChart = LineChartView()
    private var fileData = [[String:String]]()
    var csvFile: MSGraphDriveItem?
    private var fileContents: Data?
    private var url: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        summaryLineChart.delegate = self
        self.spinner.start(container: self)
        
        GraphManager.instance.getFileURL(fileId: csvFile?.entityId ?? "") { (fileContentsData: Data?, fileURL: String?, error: Error?) in
            DispatchQueue.main.async {
                self.spinner.stop()
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
                //self.specsData.text = csv.printData()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        summaryLineChart.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 40)
        summaryLineChart.center = view.center
        view.addSubview(summaryLineChart)

        var entries = [ChartDataEntry]()

        if !self.fileData.isEmpty {
            for index in 1..<self.fileData.count {
                let datapoint = self.fileData[index]
                print("Time: \(datapoint["Time"] ?? "nil"), Obj: \(datapoint["Obj"] ?? "nil")")
                if let objTemp = Double(datapoint["Obj"]!) {
                    entries.append(ChartDataEntry(x: Double(index), y: objTemp))
                } else {
                    entries.append(ChartDataEntry(x: Double(index), y: Double(index)))
                }
            }
        } else {
            for index in 1..<10 {
                entries.append(ChartDataEntry(x: Double(index), y: Double(index)))
            }
        }

        let set = LineChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.pastel()
        let data = LineChartData(dataSet: set)
        summaryLineChart.data = data
    }
}
