//
//  LocationStore.swift
//  WeatherForecast
//
//  Created by BLU on 04/08/2019.
//  Copyright © 2019 BLU. All rights reserved.
//

import Foundation

/// 노티피케이션 정의
extension Notification.Name {
    /// 위치 정보 데이터 추가시 POST
    static let locationsAdded = Notification.Name("locationsAdded")
}

/// 위치 정보 데이터 저장소
final class LocationStore {
    private(set) var locations = [Location]()
    private let lockQueue = DispatchQueue(label: "locationStore")
    
    private var archiveURL: URL? = {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let documentDirectory = documentsDirectories.first {
            return documentDirectory.appendingPathComponent("locations")
        }
        return nil
    }()
    
    init() {
        guard let url = archiveURL else {
            return
        }
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        do {
            let data = try Data(contentsOf: url)
            guard let archivedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Data else {
                return
            }
            let locations = try JSONDecoder().decode([Location].self, from: archivedData)
            self.locations = locations
        } catch {
            print("파일을 읽지 못하였습니다.")
        }
    }
    
    func addLocation(_ location: Location) {
        /// 위도/경도가 같을시 리턴
        lockQueue.sync {
            guard !self.locations.contains(location) else {
                return
            }
            self.locations.append(location)
            self.locationsAdded()
        }
    }
    
    func removeLocation(_ location: Location) {
        lockQueue.sync {
            if let index = self.locations.firstIndex(of: location) {
                self.locations.remove(at: index)
            }
        }
    }
    
    /// 파일 URL에 데이터를 아카이빙해 저장
    func saveChanges() {
        guard let url = archiveURL else {
            return
        }
        do {
            let data = try JSONEncoder().encode(locations)
            let archivedData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            try archivedData.write(to: url)
        } catch {
            print("파일을 저장하지 못하였습니다.")
        }
    }
    
    /// 위치 목록이 추가됨을 알림
    private func locationsAdded() {
        NotificationCenter.default.post(name: .locationsAdded, object: nil)
    }
}
