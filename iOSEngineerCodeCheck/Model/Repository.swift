//
//  Repository.swift
//  iOSEngineerCodeCheck
//
//  Created by 戸高新也 on 2021/02/09.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

import Foundation

struct Repository: Decodable, Equatable {
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    let name: String
    let fullName: String
    let language: String?
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let description: String?
    let homepage: String?
    let htmlUrl: String?
    
    let owner: Owner
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case language
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case description
        case homepage
        case htmlUrl = "html_url"
        case owner
    }
}

extension Repository {
    static let template: Repository = .init(id: 0, name: "swift", fullName: "apple/swift", language: "C++", stargazersCount: 54964, watchersCount: 54964, forksCount: 8836, openIssuesCount: 309, description: "The Swift Programming Language", homepage: "https://opendev.org/openstack/swift", htmlUrl: "https://github.com/apple/swift", owner: .template)
}
