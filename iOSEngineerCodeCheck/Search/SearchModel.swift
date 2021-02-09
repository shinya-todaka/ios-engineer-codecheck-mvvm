//
//  SearchModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 戸高新也 on 2021/02/09.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

import Combine
import APIKit

protocol SearchModelProtocol {
    var error: AnyPublisher<SessionTaskError?, Never> { get }
    var response: AnyPublisher<GitHubAPI.SearchRepositories.Response?, Never> { get }
    var requestSubject: PassthroughSubject<GitHubAPI.SearchRepositories, Never> { get set }
}

class SearchModel: SearchModelProtocol {
    
    // input
    var requestSubject = PassthroughSubject<GitHubAPI.SearchRepositories,Never>()
    
    // output
    var response: AnyPublisher<GitHubAPI.SearchRepositories.Response?, Never>
    var error: AnyPublisher<SessionTaskError?,Never>
    private var disposables: [AnyCancellable] = []
    
    init() {
        
        let _response = PassthroughSubject<GitHubAPI.SearchRepositories.Response?, Never>()
        self.response = _response.eraseToAnyPublisher()
        
        let _error = PassthroughSubject<SessionTaskError?, Never>()
        self.error = _error.eraseToAnyPublisher()
        
        requestSubject
            .flatMap { request -> AnyPublisher<GitHubAPI.SearchRepositories.Response, SessionTaskError> in
                Session.shared.publisher(request: request)
                    .prefix(1)
                    .eraseToAnyPublisher()
            }
            .sink { (completion) in
                switch completion {
                case let .failure(error):
                    _error.send(error)
                case .finished:
                    break
                }
            } receiveValue: { (res) in
                _response.send(res)
            }.store(in: &disposables)
    }
}
