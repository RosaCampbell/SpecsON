//
//  DayViewController.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 28/08/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import UIKit
import MSGraphClientModels
import Charts

class DayViewController: UIViewController, ChartViewDelegate {
    
    private var dayLineChart = LineChartView()
    private var importedFileData = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayLineChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            let tabBar = self.tabBarController as! BaseTabBarController
            self.importedFileData = tabBar.fileData
            
            // Convert all data to days
            
            
            self.dayLineChart.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 40)
            self.dayLineChart.center = self.view.center
            self.view.addSubview(self.dayLineChart)

            var entries = [ChartDataEntry]()

            if !self.importedFileData.isEmpty {
                for index in 1..<self.importedFileData.count {
                    let datapoint = self.importedFileData[index]
                    if let objTemp = Double(datapoint["Obj"]!) {
                        entries.append(ChartDataEntry(x: Double(index), y: objTemp))
                    }
                }
            } else {
                for i in 1..<10 {
                    entries.append(ChartDataEntry(x: Double(i), y: 25.00))
                }
            }

            let set = LineChartDataSet(entries: entries)
            set.colors = ChartColorTemplates.pastel()
            set.drawCirclesEnabled = false
            let data = LineChartData(dataSet: set)
            self.dayLineChart.data = data
        }
    }
}
