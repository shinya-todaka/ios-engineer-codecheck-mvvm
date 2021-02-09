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
    var isLoading: AnyPublisher<Bool, Never> { get }
    var isLoadingSubject: CurrentValueSubject<Bool,Never> { get }
    var response: AnyPublisher<GitHubAPI.SearchRepositories.Response?, Never> { get }
    var requestSubject: PassthroughSubject<GitHubAPI.SearchRepositories, Never> { get set }
}

class SearchModel: SearchModelProtocol {
    
    // input
    var requestSubject = PassthroughSubject<GitHubAPI.SearchRepositories,Never>()
    
    // output
    let response: AnyPublisher<GitHubAPI.SearchRepositories.Response?, Never>
    let error: AnyPublisher<SessionTaskError?,Never>
    var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    let isLoadingSubject = CurrentValueSubject<Bool,Never>(false)
    private var disposables: [AnyCancellable] = []
    private let gitHubAPI: GitHubAPIProtocol
    
    init(gitHubAPI: GitHubAPIProtocol = GitHubAPI()) {
        self.gitHubAPI = gitHubAPI
        
        let _response = PassthroughSubject<GitHubAPI.SearchRepositories.Response?, Never>()
        self.response = _response.eraseToAnyPublisher()
        
        let _error = PassthroughSubject<SessionTaskError?, Never>()
        self.error = _error.eraseToAnyPublisher()
        
        requestSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self else { return }
                self.isLoadingSubject.send(true)
            })
            .flatMap { request -> AnyPublisher<GitHubAPI.SearchRepositories.Response, SessionTaskError> in
                gitHubAPI.call(request: request)
                    .prefix(1)
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self else { return }
                self.isLoadingSubject.send(false)
            })
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
