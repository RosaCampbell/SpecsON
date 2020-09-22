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
    private var firstDataLoad = true
    private var entries = [BarChartDataEntry]()
    private var hourAverages = [Double]()
    private var dates = [String]()
    
    
    @IBOutlet public var dayTotalHoursView: SummaryView!
    @IBOutlet public var dayAverageHoursView: SummaryView!
    @IBOutlet public var dayGraphView: UIView!
    @IBOutlet weak var displayDate: UILabel!
    
    @IBAction func forwardOneDay() {
        if day < (importedFileData.count/288 - 1) {
            day += 1
            setCurrentDateAndEntries()
            setupBarChart()
        }
    }
    
    @IBAction func backOneDay() {
        if day > 1 {
            day -= 1
            setCurrentDateAndEntries()
            setupBarChart()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayTotalHoursView.layer.cornerRadius = 5
        dayTotalHoursView.layer.borderWidth = 0
        dayTotalHoursView.layer.masksToBounds = true
        dayTotalHoursView.title = "Today"
        dayTotalHoursView.units = "hours"
        dayAverageHoursView.layer.cornerRadius = 5
        dayAverageHoursView.layer.borderWidth = 0
        dayAverageHoursView.layer.masksToBounds = true
        dayAverageHoursView.title = "Average"
        dayAverageHoursView.units = "hours"
        
        dayBarChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            let tabBar = self.tabBarController as! BaseTabBarController
            self.importedFileData = tabBar.fileData
            if !tabBar.dayAverages.isEmpty && !tabBar.dates.isEmpty{
                self.hourAverages = tabBar.hourAverages
                self.dates = tabBar.dates
                self.dayTotalHoursView.value = String(tabBar.dayAverages[self.day-1].cleanValue)
                self.dayAverageHoursView.value = String(self.getAvHours(dayAverages: tabBar.dayAverages).cleanValue)
                self.dayTotalHoursView.outOfTotal = "\(0)% of \(0) waking hours"
                self.dayAverageHoursView.outOfTotal = "\(0)% of \(0) waking hours"
            }
            
            self.dayBarChart.frame = CGRect(x: self.dayGraphView.frame.origin.x, y: self.dayGraphView.frame.origin.y, width: self.dayGraphView.bounds.width, height: self.dayGraphView.bounds.height)
            self.view.addSubview(self.dayBarChart)

            if !self.importedFileData.isEmpty {
                if self.firstDataLoad == true {
                    self.firstDataLoad = false
                    self.setCurrentDateAndEntries()
                    self.setupBarChart()
                }
            } else {
                for i in 0..<24 {
                    self.entries.append(BarChartDataEntry(x: Double(i), y: 0))
                }
                self.setupBarChart()
            }
        }
    }
    
    private func getAvHours(dayAverages: [Double])-> Double {
        var dayAverage = 0.00
        for index in 0..<dayAverages.count {
            dayAverage += dayAverages[index]
        }
        return dayAverage/Double(dayAverages.count)
    }
    
    private func setCurrentDateAndEntries()->  Void {
        entries.removeAll()
        currentDate = dates[day-1]
        displayDate.text = currentDate
        for j in 0..<24 {
            entries.append(BarChartDataEntry(x: Double(j), y: hourAverages[(day-1)*24+j]))
        }
    }
    
    private func setupBarChart()->Void {
        let set = BarChartDataSet(entries: entries)
        set.setColors(UIColor(red: 60.0/255.0, green: 187.0/255.0, blue: 240.0/255.0, alpha: 1.0))
        //r: 50, g: 115, b:186
        set.drawValuesEnabled = false
        dayBarChart.xAxis.drawGridLinesEnabled = false
        dayBarChart.xAxis.drawAxisLineEnabled = false
        dayBarChart.xAxis.drawLabelsEnabled = true
        dayBarChart.xAxis.labelPosition = .bottom
        dayBarChart.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(index, _) in
            return self.xAxisLabels[Int(index)]
        })
        dayBarChart.xAxis.labelCount = 8
        dayBarChart.leftAxis.axisMaximum = 1.0
        dayBarChart.leftAxis.axisMinimum = 0.0
        dayBarChart.rightAxis.drawGridLinesEnabled = false
        dayBarChart.rightAxis.drawAxisLineEnabled = false
        dayBarChart.rightAxis.drawLabelsEnabled = false
        dayBarChart.legend.enabled = false
        let data = BarChartData(dataSet: set)
        dayBarChart.data = data
    }
}

extension Double
{
    var cleanValue: String
    {
        return self.truncatingRemainder(dividingBy: Double(1)) < 0.25 ? String(format: "%.0f", self) : String(format: "%.2f", self)
    }
}
