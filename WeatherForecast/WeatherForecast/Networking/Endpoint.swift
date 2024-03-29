//
//  Endpoint.swift
//  WeatherForecast
//
//  Created by BLU on 06/08/2019.
//  Copyright © 2019 BLU. All rights reserved.
//

import Foundation

/// 서비스를 위해 접근할 요청
protocol Endpoint {
    var base: String { get }
    var path: String { get }
}

struct QueryParam: Codable {
    let long: String
    let value: String
}

extension Endpoint {
    /// URL을 구성하는 도메인, path, query
    var urlComponents: URLComponents? {
        var components = URLComponents(string: base)
        components?.path = path
        if let queryItems = try? QueryParam(long: "lang", value: "ko").tryQueryItem() {
            components?.queryItems = queryItems
        }
        return components
    }
    
    var request: URLRequest? {
        if let url = urlComponents?.url {
            return URLRequest(url: url)
        }
        return nil
    }
}
