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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        summaryLineChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            let tabBar = self.tabBarController as! BaseTabBarController
            self.importedFileData = tabBar.fileData
            
            self.summaryLineChart.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 40)
            self.summaryLineChart.center = self.view.center
            self.view.addSubview(self.summaryLineChart)

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
            self.summaryLineChart.data = data
        }
    }
}
