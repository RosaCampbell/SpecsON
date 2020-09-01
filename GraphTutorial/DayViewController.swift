//
//  DayViewController.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 28/08/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import UIKit
import Charts

class DayViewController: UIViewController, ChartViewDelegate {

    var fileData = [[String:String]]()
    var barChart = BarChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        barChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        barChart.center = view.center
        view.addSubview(barChart)
        
        var entries = [BarChartDataEntry]()
        for x in 0..<10 {
            entries.append(BarChartDataEntry(x: Double(x), y: Double(x)))
        }
        let set = BarChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.material()
        let data = BarChartData(dataSet: set)
        barChart.data = data
    }
}
