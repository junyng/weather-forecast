//
//  SearchLocationTableViewController.swift
//  WeatherForecast
//
//  Created by BLU on 02/08/2019.
//  Copyright © 2019 BLU. All rights reserved.
//

import UIKit
import MapKit

/// 검색 결과에 따라 위치 정보를 나열하는 테이블 뷰 컨트롤러
class SearchLocationTableViewController: UITableViewController {

    var locationStore: LocationStore!

    private var places: [MKMapItem]? {
        didSet {
            tableView.reloadData()
        }
    }

    private var suggestionController: SuggestedLocationTableViewController!
    private var searchController: UISearchController!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureSearchController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }

    // MARK: - Custom Methods
    private func configureSearchController() {
        suggestionController = SuggestedLocationTableViewController()
        suggestionController.tableView.delegate = self
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
    }

    private func configureSearchBar() {
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.delegate = self
        self.definesPresentationContext = true
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let mapItem = places?[indexPath.row] {
            cell.textLabel?.text = mapItem.name
        }

        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView == suggestionController.tableView,
            let suggestion = suggestionController.completerResults?[indexPath.row] {
            searchController.isActive = false
            searchController.searchBar.text = suggestion.title
            /// 직렬 큐를 생성하여 비동기 작업이 처리
            let dispatchGroup = DispatchGroup()
            DispatchQueue(label: "serial").async(group: dispatchGroup) {
                LocationConverter.shared.getCoordinate(from: suggestion.title) { coordinate, error in
                    guard let coordinate = coordinate, error == nil else {
                        return
                    }
                    let location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude, address: suggestion.title)
                    self.locationStore.addLocation(location)
                }
            }
            /// 작업이 처리 된 후, 현재 뷰 컨트롤러를 메인 스레드에서 dismiss 한다
            dispatchGroup.notify(queue: .global()) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }
}

extension SearchLocationTableViewController: UISearchControllerDelegate { }

extension SearchLocationTableViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        searchBar.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
}
