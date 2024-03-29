//
//  SummaryCell.swift
//  WeatherForecast
//
//  Created by BLU on 03/08/2019.
//  Copyright © 2019 BLU. All rights reserved.
//

import UIKit

class SummaryCell: UICollectionViewCell, ConfigurableCell, ReusableCell {
    @IBOutlet weak var summaryTextView: UITextView!
    
    func configure(_ item: Feature) {
        summaryTextView.text = item.summary
    }
}
