//
//  DetailCollectionViewDataSource.swift
//  WeatherForecast
//
//  Created by BLU on 05/08/2019.
//  Copyright © 2019 BLU. All rights reserved.
//

import UIKit

class DetailCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var detailArray = [WeatherDetail]()
    var feature: Feature? {
        return detailArray.first?.feature
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return detailArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCell.reuseIdentifier, for: indexPath)
        if indexPath.item < detailArray.count {
            if let dailyCell = cell as? DailyCell {
                let weatherDetail = detailArray[indexPath.item]
                dailyCell.configure(weatherDetail)
                return dailyCell
            }
        } else if indexPath.item == detailArray.count {
            if let feature = feature,
                let summaryCell = collectionView.dequeueReusableCell(withReuseIdentifier: SummaryCell.reuseIdentifier, for: indexPath) as? SummaryCell {
                summaryCell.configure(feature)
                return summaryCell
            }
        }
        return cell
    }
}
