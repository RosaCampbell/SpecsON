//
//  SummaryView.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 17/09/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import UIKit

class SummaryView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let specsONLightBlue: UIColor = UIColor(red: 60.0/255.0, green: 187.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    private let specsONDarkBlue: UIColor = UIColor(red: 50.0/255.0, green: 115.0/255.0, blue: 186.0/255.0, alpha: 1.0)
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var unitsLabel: UILabel!

    override init (frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        gradientLayer.colors = [specsONLightBlue.cgColor, specsONDarkBlue.cgColor]
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var value: String? {
        didSet {
            valueLabel.text = value
        }
    }
    
    var units: String? {
        didSet {
            unitsLabel.text = units
        }
    }
}
