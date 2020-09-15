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
            self.dayAvDataView.totalHoursToday = String(format: "%.2f", tabBar.dayAverages[self.day-1])
            self.dayAvDataView.averageHoursPerDay = self.getAvHoursPerDay(dayAverages: tabBar.dayAverages)
            
            self.dayBarChart.frame = CGRect(x: 20, y: 140, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 350)
            self.view.addSubview(self.dayBarChart)

            var entries = [BarChartDataEntry]()

            if !self.importedFileData.isEmpty {
                var oneDaysData = [[String:String]]()
                oneDaysData = self.getDataForDay()
                let date = oneDaysData[0]["Date Time"]?.components(separatedBy: " 00:")
                self.displayDate.text = date?[0]
                
                var dailyStateAverages = [Double]()
                dailyStateAverages = self.getStateAverages(dayData: oneDaysData)
                
                for j in 0..<dailyStateAverages.count {
                    entries.append(BarChartDataEntry(x: Double(j), y: dailyStateAverages[j]))
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
    
    private func getAvHoursPerDay(dayAverages: [Double])-> String {
        var dayAverage = 0.00
        for index in 0..<dayAverages.count {
            dayAverage += dayAverages[index]
        }
        return String(format: "%.2f", dayAverage/Double(dayAverages.count))
    }
    
    public func getDataForDay()-> [[String:String]] {
        var startDayFound = 0
        var i = 1
        var dayData = [[String:String]]()
        
        while startDayFound != day {
            var isSameDay = false
            
            let preDay = self.importedFileData[i]["Date Time"]!.components(separatedBy: " 00:")[0]
            let currentDay = self.importedFileData[i-1]["Date Time"]!.components(separatedBy: " 00:")[0]
            
            if preDay == currentDay {
                isSameDay = true
            }
             
            if (self.importedFileData[i]["Date Time"]!.contains(" 00:0") && !isSameDay) {
                startDayFound += 1
            }
            i += 1
        }
        for j in 0..<288 {
            dayData.append(self.importedFileData[i-1+j])
        }
        
        return dayData
    }
    
    public func getStateAverages(dayData: [[String:String]])-> [Double] {
        var hourlyStateAverages = [Double]()
        var average: Double = 0.00;
        
        for i in 0..<24 {
            average = 0
            for j in 0..<12 {
                if let state = dayData[(i*12)+j]["State"] {
                    average += Double(state) ?? 0
                }
            }
            hourlyStateAverages.append(average/12)
        }
        return hourlyStateAverages
    }
}
