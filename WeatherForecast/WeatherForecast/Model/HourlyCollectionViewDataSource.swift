//
//  HourlyCollectionViewDataSource.swift
//  WeatherForecast
//
//  Created by BLU on 05/08/2019.
//  Copyright © 2019 BLU. All rights reserved.
//

import UIKit

class HourlyCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var currentArray = [WeatherCurrently]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherHourlyCell", for: indexPath) as! HourlyCell
        let item = currentArray[indexPath.item]
        cell.timeLabel.text = "\(item.time)"
        cell.weatherImage.image = UIImage(named: item.icon.rawValue)
        cell.temperatureLabel.text = "\(item.temperature)"
        return cell
    }
}