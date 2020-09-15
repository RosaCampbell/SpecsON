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
    @IBOutlet var totalHoursTodayLabel: UILabel!
    @IBOutlet var averageHoursPerDayLabel: UILabel!
    @IBOutlet var totalTitleLabel: UILabel!
    @IBOutlet var averageTitleLabel: UILabel!
    @IBOutlet var averageUnitsLabel: UILabel!
    @IBOutlet var totalUnitsLabel: UILabel!

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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        newLayer.frame = bounds
    }
    
    var totalHoursToday: String? {
        didSet {
            totalTitleLabel.text = "TOTAL"
            totalUnitsLabel.text = "Hours"
            totalHoursTodayLabel.text = totalHoursToday
        }
    }

    var averageHoursPerDay: String? {
        didSet {
            averageTitleLabel.text = "AVERAGE"
            averageUnitsLabel.text = "Hours/Day"
            averageHoursPerDayLabel.text = averageHoursPerDay
        }
    }
}

//class AverageSummaryView: UIView {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//        setupConstraints()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setupViews() {
//        self.addSubview(contentView)
//
//    }
//
//    func setupConstraints() {
//        self.translatesAutoresizingMaskIntoConstraints = false
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
//        contentView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -110).isActive = true
//        contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
//        contentView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
//    }
//
//    let contentView: UIView = {
//        let view = UIView(frame: CGRect(x: 0, y: 300, width: 100, height: 50))
//        view.layer.borderWidth = 1.0
//        view.layer.borderColor = UIColor.lightGray.cgColor
//        return view
//    }()
//
//}
