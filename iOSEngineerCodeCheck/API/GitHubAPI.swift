//
//  GitHubAPI.swift
//  iOSEngineerCodeCheck
//
//  Created by 戸高新也 on 2021/02/04.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

import APIKit
import Combine

struct DecodableDataParser<T: Decodable>: DataParser {
    let contentType: String? = "application/json"
    
    func parse(data: Data) throws -> Any {
        return try JSONDecoder().decode(T.self, from: data)
    }
}

protocol GitHubRequest: Request { }

extension GitHubRequest {
    var baseURL: URL {
        URL(string: "https://api.github.com")!
    }
}

extension GitHubRequest where Response: Decodable {
    var dataParser: DataParser {
        return DecodableDataParser<Response>()
    }
}

protocol GitHubAPIProtocol {
    func call<T: GitHubRequest>(request: T) -> AnyPublisher<T.Response, SessionTaskError>
}

struct GitHubAPI: GitHubAPIProtocol {
    
    struct SearchRepositories: GitHubRequest {
        typealias Response = SearchResponse

        let method: HTTPMethod = .get
        let path: String = "/search/repositories"
        
        var parameters: Any? {
            return [
                    "q": query,
                    "page": page,
                    "per_page": perPage
                    ]
        }

        let query: String
        let page: Int
        let perPage = 20
        
        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
            return try (object as? Response) ??
                { throw ResponseError.unexpectedObject(object) }()
        }
    }
    
    func call<T: GitHubRequest>(request: T) -> AnyPublisher<T.Response, SessionTaskError> {
        return Session.shared.publisher(request: request).eraseToAnyPublisher()
    }
}

