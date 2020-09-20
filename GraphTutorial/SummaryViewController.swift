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
    private var avHoursPerHour = [Double]()
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
    private var startDatePicker: UIDatePicker?
    private var endDatePicker: UIDatePicker?
    private var dataReadFlag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDatePicker = UIDatePicker()
        endDatePicker = UIDatePicker()
        startDatePicker?.datePickerMode = .dateAndTime
        endDatePicker?.datePickerMode = .dateAndTime
        startDateInput.inputView = startDatePicker
        endDateInput.inputView = endDatePicker
        startDatePicker?.addTarget(self, action: #selector(SummaryViewController.startDateChanged(datePicker:)), for: .valueChanged)
        endDatePicker?.addTarget(self, action: #selector(SummaryViewController.endDateChanged(datePicker:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.viewTapped(gestureRecogniser:)))
        view.addGestureRecognizer(tapGesture)
        
        summaryLineChart.delegate = self
        summaryGraphView.layer.cornerRadius = 5
        summaryGraphView.layer.borderWidth = 0
        summaryGraphView.layer.masksToBounds = true
        summaryDayView.title = "Daily Average"
        summaryDayView.value = "0"
        summaryDayView.units = "hours"
        summaryDayView.layer.cornerRadius = 5
        summaryDayView.layer.borderWidth = 0
        summaryDayView.layer.masksToBounds = true
        summaryWeekView.title = "Weekly Average"
        summaryWeekView.value = "0"
        summaryWeekView.units = "hours"
        summaryWeekView.layer.cornerRadius = 5
        summaryWeekView.layer.borderWidth = 0
        summaryWeekView.layer.masksToBounds = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            let tabBar = self.tabBarController as! BaseTabBarController
            self.avHoursPerHour = tabBar.averageHoursPerHour
            self.csvFile = tabBar.csvFile
            
            self.summaryLineChart.frame = CGRect(x: self.summaryGraphView.frame.origin.x + 8, y: self.summaryGraphView.frame.origin.y + 8, width: self.summaryGraphView.bounds.width - 16, height: self.summaryGraphView.bounds.height - 16)
            self.view.addSubview(self.summaryLineChart)
            
            var entries = [ChartDataEntry]()

            if !self.avHoursPerHour.isEmpty {
                self.dataReadFlag += 1
                if self.dataReadFlag == 1 {
                    self.startDateInput.text = tabBar.dates.first! + " 00:00"
                    self.endDateInput.text = tabBar.dates.last! + " 00:00"
                    let limitsDateFormatter = DateFormatter()
                    limitsDateFormatter.dateFormat = "MMM dd, yyyy"
                    self.startDatePicker?.minimumDate = limitsDateFormatter.date(from: tabBar.dates.first ?? "")
                    self.startDatePicker?.maximumDate = limitsDateFormatter.date(from: tabBar.dates.last ?? "")
                    self.endDatePicker?.maximumDate = limitsDateFormatter.date(from: tabBar.dates.last ?? "")
                    self.endDatePicker?.minimumDate = limitsDateFormatter.date(from: tabBar.dates.first ?? "")
                }
                self.summaryDayView.valueLabel.text = String(self.getAvHours(averages: tabBar.dayAverages).cleanValue)
                self.summaryWeekView.valueLabel.text = String(self.getAvHours(averages: tabBar.weekAverages).cleanValue)
                for hour in 0..<self.avHoursPerHour.count {
                    entries.append(ChartDataEntry(x: Double(hour), y: self.avHoursPerHour[hour]))
                }
            } else {
                for i in 0..<24 {
                    entries.append(ChartDataEntry(x: Double(i), y: 0.00))
                }
            }

            let set = LineChartDataSet(entries: entries)
            set.setColors(.white)
            set.drawCirclesEnabled = false
            set.drawValuesEnabled = false
            self.summaryLineChart.xAxis.drawGridLinesEnabled = false
            self.summaryLineChart.xAxis.axisLineColor = .white
            self.summaryLineChart.xAxis.drawLabelsEnabled = true
            self.summaryLineChart.xAxis.labelPosition = .bottom
            self.summaryLineChart.xAxis.labelTextColor = .white
            self.summaryLineChart.xAxis.gridColor = .white
            self.summaryLineChart.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(index, _) in
                return self.xAxisLabels[Int(index)]
            })
            self.summaryLineChart.xAxis.labelCount = 8
            self.summaryLineChart.legend.enabled = false
            self.summaryLineChart.rightAxis.axisMaximum = 1
            self.summaryLineChart.rightAxis.drawGridLinesEnabled = false
            self.summaryLineChart.rightAxis.axisLineColor = .white
            self.summaryLineChart.rightAxis.labelTextColor = .white
            self.summaryLineChart.rightAxis.gridColor = .white
            self.summaryLineChart.leftAxis.drawGridLinesEnabled = false
            self.summaryLineChart.leftAxis.drawLabelsEnabled = false
            self.summaryLineChart.leftAxis.axisLineColor = .white

            let data = LineChartData(dataSet: set)
            self.summaryLineChart.data = data
        }
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
//        trimDataToWakingHours()
    }
    
    @objc func startDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        startDateInput.text = dateFormatter.string(from: datePicker.date)
//        view.endEditing(true)
    }
    @objc func endDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        endDateInput.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
//    private func trimDataToWakingHours()-> Void {
//        BaseTabBarController.
//    }
}
