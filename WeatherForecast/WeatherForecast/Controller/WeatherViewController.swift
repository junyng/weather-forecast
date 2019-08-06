//
//  WeatherViewController.swift
//  WeatherForecast
//
//  Created by BLU on 01/08/2019.
//  Copyright © 2019 BLU. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let hourlyCollectionViewDataSource = HourlyCollectionViewDataSource()
    private let detailCollectionViewDataSource = DetailCollectionViewDataSource()
    var location: Location!
    var address: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cityLabel.text = address ?? "-"
        displayActivityIndicator(shouldDisplay: true)
        WeatherClient.shared.getFeed(from: location.coordinate()) { (result) in
            switch result {
            case .success(let response):
                if let response = response {
                    self.hourlyCollectionViewDataSource.currentArray = response.weatherHourly.currentArray
                    self.hourlyCollectionView.dataSource = self.hourlyCollectionViewDataSource
                    self.detailCollectionViewDataSource.detailArray = response.weatherDaily.detailArray
                    self.collectionView.dataSource = self.detailCollectionViewDataSource
                    self.displayActivityIndicator(shouldDisplay: false)
                }
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
