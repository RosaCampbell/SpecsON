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
    private var csvFile: MSGraphDriveItem?
    private var day: Int = 1
    
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
            self.csvFile = tabBar.csvFile
            
            self.dayBarChart.frame = CGRect(x: 100, y: 20, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 300)
            self.dayBarChart.center = self.view.center
            self.view.addSubview(self.dayBarChart)

            var entries = [BarChartDataEntry]()

            if !self.importedFileData.isEmpty {
                var oneDaysData = [[String:String]]()
                oneDaysData = self.getDataForDay()
                let date = oneDaysData[0]["Date Time"]?.components(separatedBy: " 00:")
                self.displayDate.text = date?[0]
                
                var dailyStateAverages = [Double]()
                dailyStateAverages = self.getStateAverages(dayData: oneDaysData)
                
                for index in 1..<dailyStateAverages.count {
                    entries.append(BarChartDataEntry(x: Double(index), y: dailyStateAverages[index]))
                }
            } else {
                for i in 1..<24 {
                    entries.append(BarChartDataEntry(x: Double(i), y: 0))
                }
            }

            let set = BarChartDataSet(entries: entries)
            set.setColors(UIColor(red: 60.0/255.0, green: 187.0/255.0, blue: 240.0/255.0, alpha: 1.0))
            //r: 50, g: 115, b:186
            set.drawValuesEnabled = false
            self.dayBarChart.xAxis.drawGridLinesEnabled = false
            self.dayBarChart.xAxis.drawAxisLineEnabled = false
            self.dayBarChart.xAxis.drawLabelsEnabled = false
            self.dayBarChart.rightAxis.drawGridLinesEnabled = false
            self.dayBarChart.rightAxis.drawAxisLineEnabled = false
            self.dayBarChart.rightAxis.drawLabelsEnabled = false
            self.dayBarChart.legend.enabled = false
            let data = BarChartData(dataSet: set)
            self.dayBarChart.data = data
        }
    }
    
    private func getDataForDay()-> [[String:String]] {
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
        print("i = \(i)")
        for j in 0..<288 {
            dayData.append(self.importedFileData[i-1+j])
            //print("oneDaysData: \(dayData[j])")
        }
        
        return dayData
    }
    
    private func getStateAverages(dayData: [[String:String]])-> [Double] {
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
