//
//  SearchModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 戸高新也 on 2021/02/09.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

import Combine
import APIKit

class SearchModel {
    
    // input
    private var requestSubject = PassthroughSubject<GitHubAPI.SearchRepositories,Never>()
    
    // output
    @Published private(set) var error: SessionTaskError?
    @Published private(set) var response: GitHubAPI.SearchRepositories.Response?
    
    private var disposables: [AnyCancellable] = []
    
    init() {
        requestSubject
            .flatMap { request -> AnyPublisher<GitHubAPI.SearchRepositories.Response, SessionTaskError> in
                Session.shared.publisher(request: request)
                    .prefix(1)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion) in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (response) in
                guard let self = self else { return }
                self.response = response
            }.store(in: &disposables)
    }
    
    func fetch(request: GitHubAPI.SearchRepositories) {
        self.requestSubject.send(request)
    }
}
