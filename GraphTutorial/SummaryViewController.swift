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
    
    private var summaryLineChart = LineChartView()
    private var importedFileData = [[String:String]]()
    private var csvFile: MSGraphDriveItem?
    
    @IBOutlet public var averageDataView: AverageDataView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        summaryLineChart.delegate = self
        averageDataView.currentHours = "1"
        averageDataView.averageHours = "3"
        averageDataView.layer.cornerRadius = 5
        averageDataView.layer.borderWidth = 0
        averageDataView.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            let tabBar = self.tabBarController as! BaseTabBarController
            self.importedFileData = tabBar.fileData
            self.csvFile = tabBar.csvFile
            
            self.summaryLineChart.frame = CGRect(x: 100, y: 20, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 300)
            self.summaryLineChart.center = self.view.center
            self.view.addSubview(self.summaryLineChart)

            var entries = [ChartDataEntry]()

            if !self.importedFileData.isEmpty {
                for index in 1..<(self.importedFileData.count-1) {
                    let datapoint = self.importedFileData[index]
                    if let objTemp = Double(datapoint["Object"]!) {
                        entries.append(ChartDataEntry(x: Double(index), y: objTemp))
                    }
                }
            } else {
                for i in 1..<10 {
                    entries.append(ChartDataEntry(x: Double(i), y: 25.00))
                }
            }

            let set = LineChartDataSet(entries: entries)
            set.setColors(UIColor(red: 60.0/255.0, green: 187.0/255.0, blue: 240.0/255.0, alpha: 1.0))
            set.drawCirclesEnabled = false
            self.summaryLineChart.xAxis.drawGridLinesEnabled = false
            self.summaryLineChart.rightAxis.drawGridLinesEnabled = false
            let data = LineChartData(dataSet: set)
            self.summaryLineChart.data = data
        }
    }
}
