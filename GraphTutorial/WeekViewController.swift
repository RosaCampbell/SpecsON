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
    private var week: Int = 1
    private var xAxisLabels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @IBOutlet public var weekAvDataView: AverageDataView!
    @IBOutlet weak var displayWeeksDateRange: UILabel!
    @IBAction func forwardOneWeek() {
        if week < (importedFileData.count/(288*7) - 1) {
        week += 1
        }
    }
    
    @IBAction func backOneWeek() {
        if week > 1 {
            week -= 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekBarChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            let tabBar = self.tabBarController as! BaseTabBarController
            self.importedFileData = tabBar.fileData
            self.weekAvDataView.currentHours = String(format: "%.2f", tabBar.dayAverages[self.week-1])
            self.weekAvDataView.averageHours = self.getAvHours(weekAverages: tabBar.dayAverages)
            
            self.weekBarChart.frame = CGRect(x: 10, y: 140, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 350)
            self.view.addSubview(self.weekBarChart)

            var entries = [BarChartDataEntry]()

            if !self.importedFileData.isEmpty {
                var oneWeeksData = [[String:String]]()
                oneWeeksData = self.getDataForWeek()
                let date = oneWeeksData[0]["Date Time"]?.components(separatedBy: " 00:")
                let endDate = oneWeeksData[288*7 - 1]["Date Time"]?.components(separatedBy: " 23:")
                let displayDate = (date?[0])! + " - " + (endDate?[0])!
                self.displayWeeksDateRange.text = displayDate
                
                var weeklyStateAverages = [Double]()
                weeklyStateAverages = self.getDailyStateAverages(weekData: oneWeeksData)
                
                for index in 0..<weeklyStateAverages.count {
                    entries.append(BarChartDataEntry(x: Double(index), y: weeklyStateAverages[index]))
                }
            } else {
                for i in 0..<7 {
                    entries.append(BarChartDataEntry(x: Double(i), y: 0))
                }
            }

            let set = BarChartDataSet(entries: entries)
            set.setColors(UIColor(red: 60.0/255.0, green: 187.0/255.0, blue: 240.0/255.0, alpha: 1.0))
            set.drawValuesEnabled = false
            self.weekBarChart.xAxis.drawGridLinesEnabled = false
            self.weekBarChart.xAxis.drawAxisLineEnabled = false
            self.weekBarChart.xAxis.drawLabelsEnabled = true
            self.weekBarChart.xAxis.labelPosition = .bottom
            self.weekBarChart.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(index, _) in
                return self.xAxisLabels[Int(index)]
            })
            self.weekBarChart.xAxis.labelCount = 7
            self.weekBarChart.leftAxis.axisMaximum = 1.0
            self.weekBarChart.leftAxis.axisMinimum = 0.0
            self.weekBarChart.rightAxis.drawGridLinesEnabled = false
            self.weekBarChart.rightAxis.drawLabelsEnabled = false
            self.weekBarChart.legend.enabled = false
            let data = BarChartData(dataSet: set)
            self.weekBarChart.data = data
        }
    }
    
    private func getAvHours(weekAverages: [Double])-> String {
        var weekAverage = 0.00
        for index in 0..<weekAverages.count {
            weekAverage += weekAverages[index]
        }
        return String(format: "%.2f", weekAverage/Double(weekAverages.count))
    }
    
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    func getDataForWeek()-> [[String:String]] {
        var startWeekFound = 0
        var i = 1
        var weekData = [[String:String]]()
        
        while startWeekFound != week {
            var isSameDay = false
            let preDay = self.importedFileData[i]["Date Time"]!.components(separatedBy: " 00:")[0]
            let currentDay = self.importedFileData[i-1]["Date Time"]!.components(separatedBy: " 00:")[0]
            if preDay == currentDay {
                isSameDay = true
            }
            
            if let weekday = getDayOfWeek(self.importedFileData[i]["Date Time"]!) {
                // weekday is Int between 1 and 7 from Sun to Sat: Mon is 2
                if (self.importedFileData[i]["Date Time"]!.contains(" 00:0") && !isSameDay && weekday == 2){
                    startWeekFound += 1
                }
            }
            i += 1
        }
        for j in 0..<(288*7) {
            weekData.append(self.importedFileData[i-1+j])
            //print("oneDaysData: \(dayData[j])")
        }
        
        return weekData
    }
    
    func getDailyStateAverages(weekData: [[String:String]])-> [Double] {
        var dailyStateAverages = [Double]()
        var average: Double = 0.00;
        
        for j in 0..<7 {
            average = 0
            for k in 0..<288 {
                //print("j = \(j), k = \(k)")
                if let state = weekData[(j*288)+k]["State"] {
                    average += Double(state) ?? 0
                }
            }
            dailyStateAverages.append(average/288)
        }
        return dailyStateAverages
    }
}
