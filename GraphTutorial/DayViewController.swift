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
    
    private var dayBarChart = BarChartView()
    private var importedFileData = [[String:String]]()
    private var day: Int = 1
    private var currentDate = String()
    private var xAxisLabels: [String] = ["12 A", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12 P", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    public var totalAvHoursPerDay: Double = 0
    
    @IBOutlet public var dayAvDataView: AverageDataView!
    @IBOutlet weak var displayDate: UILabel!
    
    @IBAction func forwardOneDay() {
        if day < (importedFileData.count/288 - 1) {
            day += 1
        }
    }
    
    @IBAction func backOneDay() {
        if day > 1 {
            day -= 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayBarChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            let tabBar = self.tabBarController as! BaseTabBarController
            self.importedFileData = tabBar.fileData
            self.dayAvDataView.currentHours = String(format: "%.2f", tabBar.dayAverages[self.day-1])
            self.dayAvDataView.averageHours = self.getAvHours(dayAverages: tabBar.dayAverages)
            self.currentDate = tabBar.dates[self.day-1]
            
            self.dayBarChart.frame = CGRect(x: 10, y: 140, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 350)
            self.view.addSubview(self.dayBarChart)

            var entries = [BarChartDataEntry]()

            if !self.importedFileData.isEmpty {
                self.displayDate.text = self.currentDate
                for j in 0..<24 {
                    entries.append(BarChartDataEntry(x: Double(j), y: tabBar.hourAverages[(self.day-1)*24+j]))
                }
            } else {
                for i in 0..<24 {
                    entries.append(BarChartDataEntry(x: Double(i), y: 0))
                }
            }

            let set = BarChartDataSet(entries: entries)
            set.setColors(UIColor(red: 60.0/255.0, green: 187.0/255.0, blue: 240.0/255.0, alpha: 1.0))
            //r: 50, g: 115, b:186
            set.drawValuesEnabled = false
            self.dayBarChart.xAxis.drawGridLinesEnabled = false
            self.dayBarChart.xAxis.drawAxisLineEnabled = false
            self.dayBarChart.xAxis.drawLabelsEnabled = true
            self.dayBarChart.xAxis.labelPosition = .bottom
            self.dayBarChart.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(index, _) in
                return self.xAxisLabels[Int(index)]
            })
            self.dayBarChart.xAxis.labelCount = 8
            self.dayBarChart.leftAxis.axisMaximum = 1.0
            self.dayBarChart.leftAxis.axisMinimum = 0.0
            self.dayBarChart.rightAxis.drawGridLinesEnabled = false
            self.dayBarChart.rightAxis.drawAxisLineEnabled = false
            self.dayBarChart.rightAxis.drawLabelsEnabled = false
            self.dayBarChart.legend.enabled = false
            let data = BarChartData(dataSet: set)
            self.dayBarChart.data = data
        }
    }
    
    private func getAvHours(dayAverages: [Double])-> String {
        var dayAverage = 0.00
        for index in 0..<dayAverages.count {
            dayAverage += dayAverages[index]
        }
        return String(format: "%.2f", dayAverage/Double(dayAverages.count))
    }
}
