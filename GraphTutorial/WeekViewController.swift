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
    
    
    private var entries = [BarChartDataEntry]()
    private var firstDataLoad = true
    
    public var paddedDayAverages = [Double]()
    public var paddedDates = [String]()
    public var waking = Double()
    public var averageHoursPerWeek = Double()
    
    @IBOutlet public var weekTotalHoursView: SummaryView!
    @IBOutlet public var weekAverageHoursView: SummaryView!
    @IBOutlet weak var displayWeeksDateRange: UILabel!
    @IBOutlet public var weekGraphView: UIView!
    
    @IBAction func forwardOneWeek() {
        if week < (paddedDayAverages.count/7 - 1) {
            week += 1
            updateDataInWeekView()
            setCurrentDateAndEntries()
            setupBarChart()
        }
    }
    
    @IBAction func backOneWeek() {
        if week >= 1 {
            week -= 1
            updateDataInWeekView()
            setCurrentDateAndEntries()
            setupBarChart()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSummaryView()
        weekBarChart.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        week = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.weekBarChart.frame = CGRect(x: self.weekGraphView.frame.origin.x, y: self.weekGraphView.frame.origin.y, width: self.weekGraphView.bounds.width, height: self.weekGraphView.bounds.height)
            self.view.addSubview(self.weekBarChart)
        
            if !self.paddedDayAverages.isEmpty {
                self.updateDataInWeekView()
                self.setCurrentDateAndEntries()
                self.setupBarChart()
            } else {
                for i in 0..<7 {
                    self.entries.append(BarChartDataEntry(x: Double(i), y: 0))
                }
                self.setupBarChart()
            }
        }
    }
    
    private func setCurrentDateAndEntries()-> Void {
        entries.removeAll()
        currentWeekStart = paddedDates[week*7]
        currentWeekEnd = paddedDates[week*7 + 6]
        displayWeeksDateRange.text = currentWeekStart + " - " + currentWeekEnd
        for day in 0..<7 {
            entries.append(BarChartDataEntry(x: Double(day), y: paddedDayAverages[week*7 + day]))
        }
    }
    
    private func updateDataInWeekView()-> Void {
        weekTotalHoursView.value = getHoursThisWeek().cleanValue
        weekAverageHoursView.value = averageHoursPerWeek.cleanValue
        
        let total = 100.0*getHoursThisWeek()/waking
        let average = 100*averageHoursPerWeek/waking
        weekTotalHoursView.outOfTotal = "\(total.cleanValue)% of \(waking.cleanValue) waking hours"
        weekAverageHoursView.outOfTotal = "\(average.cleanValue)% of \(waking.cleanValue) waking hours"
    }
    
    private func getHoursThisWeek()-> Double {
        var hoursThisWeek = 0.00
        for day in week*7..<(week+1)*7 {
            hoursThisWeek += paddedDayAverages[day]
        }
        return hoursThisWeek
    }
    
    private func setupDataSummaryView()-> Void {
        weekTotalHoursView.layer.cornerRadius = 5
        weekTotalHoursView.layer.borderWidth = 0
        weekTotalHoursView.layer.masksToBounds = true
        weekTotalHoursView.title = "This Week"
        weekTotalHoursView.value = "0"
        weekTotalHoursView.units = "hours"
        weekTotalHoursView.outOfTotal = "0% of \(24*7) waking hours"

        weekAverageHoursView.layer.cornerRadius = 5
        weekAverageHoursView.layer.borderWidth = 0
        weekAverageHoursView.layer.masksToBounds = true
        weekAverageHoursView.title = "Average"
        weekAverageHoursView.value = "0"
        weekAverageHoursView.units = "hours"
        weekAverageHoursView.outOfTotal = "0% of \(24*7) waking hours"
    }
    
    private func setupBarChart()-> Void {
        let set = BarChartDataSet(entries: entries)
        set.setColors(UIColor(red: 60.0/255.0, green: 187.0/255.0, blue: 240.0/255.0, alpha: 1.0))
        set.drawValuesEnabled = false
        weekBarChart.xAxis.drawGridLinesEnabled = false
        weekBarChart.xAxis.drawAxisLineEnabled = false
        weekBarChart.xAxis.drawLabelsEnabled = true
        weekBarChart.xAxis.labelPosition = .bottom
        weekBarChart.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(index, _) in
            return self.xAxisLabels[Int(index)]
        })
        weekBarChart.xAxis.labelCount = 7
        weekBarChart.leftAxis.axisMaximum = 24.0
        weekBarChart.leftAxis.axisMinimum = 0.0
        weekBarChart.rightAxis.drawGridLinesEnabled = false
        weekBarChart.rightAxis.drawLabelsEnabled = false
        weekBarChart.legend.enabled = false
        let data = BarChartData(dataSet: set)
        weekBarChart.data = data
    }
}
