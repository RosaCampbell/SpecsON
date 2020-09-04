//
//  WeekViewController.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 28/08/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import UIKit
import MSGraphClientModels
import Charts

class WeekViewController: UIViewController, ChartViewDelegate {
    
    private var weekBarChart = BarChartView()
    private var importedFileData = [[String:String]]()
    private var csvFile: MSGraphDriveItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekBarChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            let tabBar = self.tabBarController as! BaseTabBarController
            self.importedFileData = tabBar.fileData
            self.csvFile = tabBar.csvFile
            
            // Convert all data to days
            
            
            self.weekBarChart.frame = CGRect(x: 100, y: 20, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 300)
            self.weekBarChart.center = self.view.center
            self.view.addSubview(self.weekBarChart)

            var entries = [BarChartDataEntry]()

            if !self.importedFileData.isEmpty {
                for index in 1..<8 {
                    let datapoint = self.importedFileData[index]
                    if let objTemp = Double(datapoint["Object"]!) {
                        entries.append(BarChartDataEntry(x: Double(index), y: objTemp))
                    }
                    //print("Time as float: \(datapoint["Time"] ?? "nil")")
                    
                }
            } else {
                for i in 1..<10 {
                    entries.append(BarChartDataEntry(x: Double(i), y: 25.00))
                }
            }

            let set = BarChartDataSet(entries: entries)
            set.colors = ChartColorTemplates.pastel()
            let data = BarChartData(dataSet: set)
            self.weekBarChart.data = data
        }
    }
    
//    func chartDataPoints(from xYValues: [Date: Double]) -> [ChartDataEntry] {
//      assert(!xYValues.isEmpty)
//      var dataPoints: [ChartDataEntry] = []
//      var startDate = xYValues.keys.sorted(by: <).first!
//      let endDate = xYValues.keys.sorted(by: >).first!
//
//      repeat {
//        guard let yValue = xYValues[startDate] else {
//          startDate = startDate.advanced(by: TimeInterval(24 * 60 * 60))
//          continue
//        }
//        dataPoints.append(ChartDataEntry(x: Double(startDate.timeIntervalSince1970), y: yValue))
//        startDate = startDate.advanced(by: TimeInterval(24 * 60 * 60))
//      } while startDate <= endDate
//      return dataPoints
//    }
}
