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
    private var week: Int = 0
    private var currentWeekStart = String()
    private var currentWeekEnd = String()
    private var xAxisLabels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private var avHoursPerDay = [Double]()
    private var paddedDates = [String]()
    
    @IBOutlet public var weekTotalHoursView: SummaryView!
    @IBOutlet public var weekAverageHoursView: SummaryView!
    @IBOutlet weak var displayWeeksDateRange: UILabel!
    @IBOutlet public var weekGraphView: UIView!
    
    @IBAction func forwardOneWeek() {
        if week < (avHoursPerDay.count/7 - 1) {
        week += 1
        }
    }
    
    @IBAction func backOneWeek() {
        if week >= 1 {
            week -= 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekTotalHoursView.layer.cornerRadius = 5
        weekTotalHoursView.layer.borderWidth = 0
        weekTotalHoursView.layer.masksToBounds = true
        weekTotalHoursView.title = "This Week"
        weekTotalHoursView.units = "hours"
        weekAverageHoursView.layer.cornerRadius = 5
        weekAverageHoursView.layer.borderWidth = 0
        weekAverageHoursView.layer.masksToBounds = true
        weekAverageHoursView.title = "Average"
        weekAverageHoursView.units = "hours"
        
        weekBarChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            let tabBar = self.tabBarController as! BaseTabBarController
            self.importedFileData = tabBar.fileData
            self.paddedDates = tabBar.dates
            self.weekBarChart.frame = CGRect(x: self.weekGraphView.frame.origin.x, y: self.weekGraphView.frame.origin.y, width: self.weekGraphView.bounds.width, height: self.weekGraphView.bounds.height)
            self.view.addSubview(self.weekBarChart)

            var entries = [BarChartDataEntry]()

            if !self.importedFileData.isEmpty {
                self.getAvHoursPerDay(dayAverages: tabBar.dayAverages, dates: tabBar.dates)
                self.weekTotalHoursView.value = self.getHoursThisWeek(dayAverages: self.avHoursPerDay).cleanValue
                self.weekAverageHoursView.value = self.getAvHoursPerWeek(dayAverages: tabBar.dayAverages).cleanValue
                self.weekTotalHoursView.outOfTotal = "\(0)% of \(0) waking hours"
                self.weekAverageHoursView.outOfTotal = "\(0)% of \(0) waking hours"
                self.currentWeekStart = self.paddedDates[(self.week)*7]
                self.currentWeekEnd = self.paddedDates[(self.week)*7 + 6]
                self.displayWeeksDateRange.text = self.currentWeekStart+" - "+self.currentWeekEnd
                for day in 0..<7 {
                    entries.append(BarChartDataEntry(x: Double(day), y: self.avHoursPerDay[self.week*7 + day]))
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
            self.weekBarChart.leftAxis.axisMaximum = 24.0
            self.weekBarChart.leftAxis.axisMinimum = 0.0
            self.weekBarChart.rightAxis.drawGridLinesEnabled = false
            self.weekBarChart.rightAxis.drawLabelsEnabled = false
            self.weekBarChart.legend.enabled = false
            let data = BarChartData(dataSet: set)
            self.weekBarChart.data = data
        }
    }
    
    func getDayOfWeek(_ today:String) -> Int? {
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    private func getAvHoursPerDay(dayAverages: [Double], dates: [String])-> Void {
        avHoursPerDay.removeAll()
        let numDays = (Int((Double(dates.count)/7.00)) + 1)*7

        if let weekday = getDayOfWeek(dates.first!) {
            if weekday == 2 {
            } else if weekday == 1 {
                for _ in 0..<6 {                        // Sunday = 1: Pad first week with 6 zeros
                    avHoursPerDay.append(0.00)
                    paddedDates.insert(missingDate(at: "start"), at: 0)
                }
            } else {
                for _ in 0..<(weekday - 2) {            // Tue = 3, W = 4... : Pad first week with X zeros
                    avHoursPerDay.append(0.00)
                    paddedDates.insert(missingDate(at: "start"), at: 0)
                }
            }
            for day in dayAverages {                    // Fill in data
                avHoursPerDay.append(day)
            }
            
            for _ in avHoursPerDay.count..<numDays {    // Pad last week with required zeros
                avHoursPerDay.append(0.00)
                paddedDates.append(missingDate(at: "end"))
            }
        }
    }
    
    private func missingDate(at: String)-> String {
        var paddedDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        if at == "start" {
            let date = dateFormatter.date(from: paddedDates.first!)
            paddedDate = Calendar.current.date(byAdding: .day, value: (-1), to: date!)!
        } else if at == "end" {
            let date = dateFormatter.date(from: paddedDates.last!)
            paddedDate = Calendar.current.date(byAdding: .day, value: (1), to: date!)!
        }
        return dateFormatter.string(from: paddedDate)
    }
    
    private func getHoursThisWeek(dayAverages: [Double])-> Double {
        var hoursThisWeek = 0.00
        for day in week*7..<(week+1)*7 {
            hoursThisWeek += dayAverages[day]
        }
        return hoursThisWeek
    }
    
    private func getAvHoursPerWeek(dayAverages: [Double])->Double {
        var weekAverage = 0.00
        for day in dayAverages {
            weekAverage += day
        }
        return (weekAverage*7)/Double(dayAverages.count)
    }
}
