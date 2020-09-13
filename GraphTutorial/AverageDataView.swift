//
//  AverageDataView.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 7/09/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import UIKit

class AverageDataView: UIView {
    
    let newLayer = CAGradientLayer()
    let specsONLightBlue: UIColor = UIColor(red: 60.0/255.0, green: 187.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    let specsONDarkBlue: UIColor = UIColor(red: 50.0/255.0, green: 115.0/255.0, blue: 186.0/255.0, alpha: 1.0)

    override init (frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        newLayer.colors = [specsONLightBlue.cgColor, specsONDarkBlue.cgColor]
        newLayer.frame = bounds
        layer.insertSublayer(newLayer, at: 0)
//        backgroundColor = .red
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        newLayer.frame = bounds
    }
    
    @IBOutlet var totalHoursTodayLabel: UILabel!
    @IBOutlet var averageHoursPerDayLabel: UILabel!

    var totalHoursToday: String? {
        didSet {
            totalHoursTodayLabel.text = totalHoursToday
        }
    }

    var averageHoursPerDay: String? {
        didSet {
            averageHoursPerDayLabel.text = averageHoursPerDay
        }
    }
}
