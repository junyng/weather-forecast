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
    let searchCompleter = MKLocalSearchCompleter()
    var completerResults: [MKLocalSearchCompletion]?
    
    private var searchController = UISearchController(searchResultsController: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureSearchController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        tableView.register(SuggestedCompletionTableViewCell.self, forCellReuseIdentifier: SuggestedCompletionTableViewCell.reuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: - Custom Methods
    private func configureSearchController() {
        searchCompleter.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
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
        return completerResults?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedCompletionTableViewCell.reuseIdentifier, for: indexPath)
        
        if let suggestion = completerResults?[indexPath.row] {
            cell.textLabel?.text = suggestion.title
            cell.detailTextLabel?.text = suggestion.subtitle
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let suggestion = completerResults?[indexPath.row] {
            searchController.isActive = false
            searchController.searchBar.text = suggestion.title
            LocationConverter.shared.getLocationInfo(from: suggestion.title) { coordinate, timezone, error in
                guard let coordinate = coordinate,
                    let timezone = timezone, error == nil else {
                        return
                }
                let location =
                    Location(latitude: coordinate.latitude, longitude: coordinate.longitude, address: suggestion.title, timezone: timezone)
                self.locationStore.addLocation(location)
            }
        }
        self.dismiss(animated: true)
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

extension SearchLocationTableViewController: MKLocalSearchCompleterDelegate {
    
    /// - MKLocalSearchCompleter 결과를 업데이트 완료시 동작한다
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription)")
        }
    }
}

extension SearchLocationTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // UISearchbar의 텍스트가 변경될 때, 완료된 suggestions를 MKLocalSearchCompleter 에게 물어본다
        if let text = searchController.searchBar.text, !text.isEmpty {
            searchCompleter.queryFragment = text
        }
    }
}

private class SuggestedCompletionTableViewCell: UITableViewCell, ReusableCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
