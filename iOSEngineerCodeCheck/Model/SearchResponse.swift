//
//  SearchRepositories.swift
//  iOSEngineerCodeCheck
//
//  Created by 戸高新也 on 2021/02/01.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

struct SearchResponse: Decodable {
    let repositories: [Repository]
    
    private enum CodingKeys: String, CodingKey {
        case repositories = "items"
    }
}

extension SearchResponse {
    static let template: SearchResponse = .init(repositories: [.template])
}
