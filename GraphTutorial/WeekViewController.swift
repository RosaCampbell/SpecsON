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
    private var currentWeekStart = String()
    private var currentWeekEnd = String()
    private var xAxisLabels: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @IBOutlet public var weekAvDataView: AverageDataView!
    @IBOutlet weak var displayWeeksDateRange: UILabel!
    @IBOutlet public var weekGraphView: UIView!
    
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
        weekAvDataView.layer.cornerRadius = 5
        weekAvDataView.layer.borderWidth = 0
        weekAvDataView.layer.masksToBounds = true
        weekBarChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            let tabBar = self.tabBarController as! BaseTabBarController
            self.importedFileData = tabBar.fileData
            self.currentWeekStart = tabBar.weekDates[(self.week-1)*7].components(separatedBy: " 00:")[0]
            self.currentWeekEnd = tabBar.weekDates[(self.week-1)*7 + 6].components(separatedBy: " 00:")[0]
            self.weekAvDataView.currentHours = tabBar.weekAverages[self.week - 1].cleanValue
            self.weekAvDataView.averageHours = self.getAvHoursPerWeek(weekAverages: tabBar.weekAverages).cleanValue
            self.weekAvDataView.averageUnits = "Hours/Week"
            self.weekBarChart.frame = CGRect(x: self.weekGraphView.frame.origin.x, y: self.weekGraphView.frame.origin.y, width: self.weekGraphView.bounds.width, height: self.weekGraphView.bounds.height)
            self.view.addSubview(self.weekBarChart)

            var entries = [BarChartDataEntry]()

            if !self.importedFileData.isEmpty {
                self.displayWeeksDateRange.text = self.currentWeekStart+" - "+self.currentWeekEnd
                for day in 0..<7 {
                    entries.append(BarChartDataEntry(x: Double(day), y: tabBar.dayAverages[tabBar.startOfFirstFullWeek + (self.week-1)*7 + day]))
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
    
    private func getAvHoursPerWeek(weekAverages: [Double])->Double {
        var weekAverage = 0.00
        for week in 0..<weekAverages.count {
            weekAverage += weekAverages[week]
        }
        return weekAverage/Double(weekAverages.count)
    }
}
