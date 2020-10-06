//
//  SummaryViewController.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 27/08/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import UIKit
import MSGraphClientModels
import Charts

class SummaryViewController: UIViewController, ChartViewDelegate {
    
    private var summaryLineChart = LineChartView()
    private var hourAverages = [Double]()
    private var dayAverages = [Double]()
    private var weekAverages = [Double]()
    private var dates = [String]()
    private var averageHoursPerHour = [Double]()
    private var csvFile: MSGraphDriveItem?
    private let gradientLayer = CAGradientLayer()
    private var xAxisLabels: [String] = ["12A", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12P", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    private let specsONLightBlue: UIColor = UIColor(red: 60.0/255.0, green: 187.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    private let specsONDarkBlue: UIColor = UIColor(red: 50.0/255.0, green: 115.0/255.0, blue: 186.0/255.0, alpha: 1.0)
    
    @IBOutlet public var summaryDayView: SummaryView!
    @IBOutlet public var summaryWeekView: SummaryView!
    @IBOutlet public var summaryGraphView: SummaryGraphView!
    @IBOutlet public var startDateInput: UITextField!
    @IBOutlet public var endDateInput: UITextField!
    @IBOutlet public var startHourInput: UITextField!
    @IBOutlet public var endHourInput: UITextField!

    private var startDatePicker: UIDatePicker?
    private var endDatePicker: UIDatePicker?
    private var startHourPicker: UIDatePicker?
    private var endHourPicker: UIDatePicker?
    
    private var dataReadFlag: Int = 0
    private var startDate = String()
    private var endDate = String()
    private var startHour: Int = 0
    private var endHour: Int = 0
    private var startDay: Int = 0
    private var endDay: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDatePicker = UIDatePicker()
        endDatePicker = UIDatePicker()
        startHourPicker = UIDatePicker()
        endHourPicker = UIDatePicker()
        startDatePicker?.datePickerMode = .date
        endDatePicker?.datePickerMode = .date
        startHourPicker?.datePickerMode = .time
        endHourPicker?.datePickerMode = .time
        startDateInput.inputView = startDatePicker
        endDateInput.inputView = endDatePicker
        startHourInput.inputView = startHourPicker
        endHourInput.inputView = endHourPicker
        
        startDatePicker?.addTarget(self, action: #selector(SummaryViewController.startDateChanged(datePicker:)), for: .valueChanged)
        endDatePicker?.addTarget(self, action: #selector(SummaryViewController.endDateChanged(datePicker:)), for: .valueChanged)
        startHourPicker?.addTarget(self, action: #selector(SummaryViewController.startHoursChanged(datePicker:)), for: .valueChanged)
        endHourPicker?.addTarget(self, action: #selector(SummaryViewController.endHoursChanged(datePicker:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.viewTapped(gestureRecogniser:)))
        view.addGestureRecognizer(tapGesture)
        
        summaryLineChart.delegate = self
        setupSummaryViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            let tabBar = self.tabBarController as! BaseTabBarController
            self.hourAverages = tabBar.hourAverages
            self.dayAverages = tabBar.dayAverages
            self.weekAverages = tabBar.weekAverages
            self.dates = tabBar.dates
            self.averageHoursPerHour = tabBar.averageHoursPerHour
            self.csvFile = tabBar.csvFile
            
            self.summaryLineChart.frame = CGRect(x: self.summaryGraphView.frame.origin.x + 8, y: self.summaryGraphView.frame.origin.y + 8, width: self.summaryGraphView.bounds.width - 16, height: self.summaryGraphView.bounds.height - 16)
            self.view.addSubview(self.summaryLineChart)
            
            var entries = [ChartDataEntry](repeating: ChartDataEntry(x:0, y:0), count: 24)

            if !self.averageHoursPerHour.isEmpty {
                
                self.sendDataToTabs()
                self.dataReadFlag += 1
                if self.dataReadFlag == 1 {
                    self.setDatePickerLimits()
                    self.displayInitialDatePickerValues()
                }
                self.setStartAndEndTimes()
                self.displayStartAndEndTimes()
                for hour in 0..<self.averageHoursPerHour.count {
                    entries.append(ChartDataEntry(x: Double(hour), y: self.averageHoursPerHour[hour]))
                }
            } else {
                for i in 0..<24 {
                    entries.append(ChartDataEntry(x: Double(i), y: 0.00))
                }
            }

            self.setupSummaryLineChart(entries: entries)
        }
    }
    
    private func sendDataToTabs()-> Void {
        let dayTab = (self.tabBarController?.viewControllers?[1])! as! DayViewController
        dayTab.waking = Double(endHour - startHour)
        let weekTab = (self.tabBarController?.viewControllers?[2])! as! WeekViewController
        weekTab.waking = 7.00*Double(endHour - startHour)
    }
    
    private func setDatePickerLimits()-> Void {
        let limitsDateFormatter = DateFormatter()
        limitsDateFormatter.dateFormat = "MMM dd, yyyy"
        startDatePicker?.minimumDate = limitsDateFormatter.date(from: dates.first ?? "")
        startDatePicker?.maximumDate = limitsDateFormatter.date(from: dates.last ?? "")
        endDatePicker?.maximumDate = limitsDateFormatter.date(from: dates.last ?? "")
        endDatePicker?.minimumDate = limitsDateFormatter.date(from: dates.first ?? "")
        startHourPicker?.minuteInterval = 30
        endHourPicker?.minuteInterval = 30
    }
    
    private func displayInitialDatePickerValues()-> Void {
        startDateInput.text = dates.first!
        startDate = dates.first! + " 00:00"
        endDateInput.text = dates.last!
        endDate = dates.last! + " 00:00"
    }
    
    private func setStartAndEndTimes()-> Void {
        let startString = startDate.components(separatedBy: ":")[0]
        startHour = Int(startString.components(separatedBy: " ")[3]) ?? 0
        startDay = Int(startString.components(separatedBy: " ")[1].dropLast()) ?? 0
        let endString = endDate.components(separatedBy: ":")[0]
        endHour = Int(endString.components(separatedBy: " ")[3]) ?? 24
        endDay = Int(endString.components(separatedBy: " ")[1].dropLast()) ?? 0
        if endHour == 0 { endHour = 24 }
    }
    
    private func displayStartAndEndTimes()-> Void {
        let day = getAvHours(averages: dayAverages)
        let week = day*7.0
        let dayWake = Double(endHour - startHour)
        let weekWake = 7.0*dayWake
        let dayPercentage = 100*day/dayWake
        let weekPercentage = 100*week/weekWake
        summaryDayView.valueLabel.text = day.cleanValue
        summaryWeekView.valueLabel.text = week.cleanValue
        summaryDayView.outOfTotal = "\(dayPercentage.cleanValue)% of \(dayWake.cleanValue) waking hours"
        summaryWeekView.outOfTotal = "\(weekPercentage.cleanValue)% of \(weekWake.cleanValue) waking hours"
    }
    
    private func setupSummaryViews()-> Void {
        summaryGraphView.layer.cornerRadius = 5
        summaryGraphView.layer.borderWidth = 0
        summaryGraphView.layer.masksToBounds = true
        summaryDayView.title = "Daily Average"
        summaryDayView.value = "0"
        summaryDayView.units = "hours"
        summaryDayView.outOfTotal = "0% of 24 waking hours"
        summaryDayView.layer.cornerRadius = 5
        summaryDayView.layer.borderWidth = 0
        summaryDayView.layer.masksToBounds = true
        summaryWeekView.title = "Weekly Average"
        summaryWeekView.value = "0"
        summaryWeekView.units = "hours"
        summaryWeekView.outOfTotal = "0% of 168 waking hours"
        summaryWeekView.layer.cornerRadius = 5
        summaryWeekView.layer.borderWidth = 0
        summaryWeekView.layer.masksToBounds = true
    }
    
    private func setupSummaryLineChart(entries: [ChartDataEntry])-> Void {
        let set = LineChartDataSet(entries: entries)
        set.setColors(.white)
        set.drawCirclesEnabled = false
        set.drawValuesEnabled = false
        summaryLineChart.xAxis.drawGridLinesEnabled = false
        summaryLineChart.xAxis.axisLineColor = .white
        summaryLineChart.xAxis.drawLabelsEnabled = true
        summaryLineChart.xAxis.labelPosition = .bottom
        summaryLineChart.xAxis.labelTextColor = .white
        summaryLineChart.xAxis.gridColor = .white
        summaryLineChart.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(index, _) in
            return self.xAxisLabels[Int(index)]
        })
        summaryLineChart.xAxis.labelCount = 8
        summaryLineChart.legend.enabled = false
        summaryLineChart.rightAxis.drawGridLinesEnabled = false
        summaryLineChart.rightAxis.axisLineColor = .white
        summaryLineChart.rightAxis.labelTextColor = .white
        summaryLineChart.rightAxis.gridColor = .white
        summaryLineChart.leftAxis.drawGridLinesEnabled = false
        summaryLineChart.leftAxis.drawLabelsEnabled = false
        summaryLineChart.leftAxis.axisLineColor = .white

        let data = LineChartData(dataSet: set)
        summaryLineChart.data = data
    }
    
    private func getAvHours(averages: [Double])-> Double {
        var average = 0.00
        for index in 0..<averages.count {
            average += averages[index]
        }
        return average/Double(averages.count)
    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer ) {
        view.endEditing(true)
    }
    
    @objc func startDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        startDateInput.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func endDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        endDateInput.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func startHoursChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        startHourInput.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func endHoursChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        endHourInput.text = dateFormatter.string(from: datePicker.date)
    }
}
