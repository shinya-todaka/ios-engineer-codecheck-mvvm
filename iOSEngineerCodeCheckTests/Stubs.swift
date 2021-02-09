//
//  Stubs.swift
//  iOSEngineerCodeCheckTests
//
//  Created by 戸高新也 on 2021/02/09.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

@testable import iOSEngineerCodeCheck
import Combine
import APIKit

class StubSearchModdel: SearchModelProtocol {
    var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    var isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    
    var error: AnyPublisher<SessionTaskError?, Never>
    var response: AnyPublisher<GitHubAPI.SearchRepositories.Response?, Never>
    var requestSubject = PassthroughSubject<GitHubAPI.SearchRepositories, Never>()
    var disposables: [AnyCancellable] = []
    
    init() {
        let _error = PassthroughSubject<SessionTaskError?, Never>()
        self.error = _error.eraseToAnyPublisher()
        
        let _response = PassthroughSubject<GitHubAPI.SearchRepositories.Response?, Never>()
        self.response = _response.eraseToAnyPublisher()
        
        requestSubject
            .handleEvents(receiveOutput: { _ in
                self.isLoadingSubject.send(true)
            })
            .flatMap { request -> AnyPublisher<GitHubAPI.SearchRepositories.Response, SessionTaskError> in
                return self.doSomeNetwork(request: request)
            }.handleEvents(receiveOutput: { _ in
                self.isLoadingSubject.send(false)
            })
            .sink { _ in } receiveValue: { (response) in
                _response.send(response)
            }.store(in: &disposables)
    }
    
    private func doSomeNetwork(request: GitHubAPI.SearchRepositories) -> AnyPublisher<GitHubAPI.SearchRepositories.Response, SessionTaskError> {
        return Future { promise in
            promise(.success(.template))
        }.eraseToAnyPublisher()
    }
}


struct StubGitHubAPI: GitHubAPIProtocol {
    
    let result: Result<SearchResponse,SessionTaskError>
    
    func call<T: GitHubRequest>(request: T) -> AnyPublisher<T.Response, SessionTaskError>  {
        Future { promise in
            switch result {
            case let .failure(error):
                promise(.failure(error))
            case let .success(response):
                promise(.success(response as! T.Response))
            }
        }.eraseToAnyPublisher()
    }
}

