//
//  Owner.swift
//  iOSEngineerCodeCheck
//
//  Created by 戸高新也 on 2021/02/09.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//


struct Owner: Decodable {
    let avatarUrl: String
    let login: String
    
    private enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
        case login
    }
}

extension Owner {
    static let template: Owner = .init(avatarUrl: "https://avatars.githubusercontent.com/u/10639145?v=4", login: "apple")
}
