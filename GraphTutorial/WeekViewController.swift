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
    private var week: Int = 1
    
    @IBOutlet weak var displayWeeksDateRange: UILabel!
    
    @IBAction func forwardOneWeek() {
        if week < (importedFileData.count/(288*7)) {
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
            self.csvFile = tabBar.csvFile
            
            self.weekBarChart.frame = CGRect(x: 100, y: 20, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 300)
            self.weekBarChart.center = self.view.center
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
            self.weekBarChart.rightAxis.drawGridLinesEnabled = false
            self.weekBarChart.rightAxis.drawLabelsEnabled = false
            self.weekBarChart.xAxis.drawLabelsEnabled = false
            self.weekBarChart.legend.enabled = false
            let data = BarChartData(dataSet: set)
            self.weekBarChart.data = data
        }
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
        print("i = \(i)")
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
