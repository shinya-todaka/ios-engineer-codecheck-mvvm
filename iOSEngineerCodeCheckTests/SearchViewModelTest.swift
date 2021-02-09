//
//  SearchViewModelTest.swift
//  iOSEngineerCodeCheckTests
//
//  Created by 戸高新也 on 2021/02/09.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

@testable import iOSEngineerCodeCheck
import XCTest
import APIKit
import Combine
import EntwineTest
import CombineExpectations

enum MyError: Error {
    case unknown
}

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

class SearchViewModelTest: XCTestCase {

    var disposables: [AnyCancellable] = []
  
    func test_検索時にrepositoriesが流れてくることを確認() {
        let model = StubSearchModdel()
        let viewModel = SearchViewModel(model: model)
        
        let publisher = viewModel.repositories
          
        let recorder = publisher.record()
          
        viewModel.textToSearch.send("swift")
        try XCTAssertEqual(recorder.next().get(), [])
        try XCTAssertEqual(recorder.next().get(), SearchResponse.template.repositories)
    }
    
    func test_ページング処理の確認() {
        let model = StubSearchModdel()
        let viewModel = SearchViewModel(model: model)
        
        let publisher = viewModel.repositories
          
        let recorder = publisher.record()
          
        // expect initial response to be not appended array
        viewModel.textToSearch.send("swift")
        try XCTAssertEqual(recorder.next().get(), [])
        try XCTAssertEqual(recorder.next().get(), SearchResponse.template.repositories)
        
        // expect additional response to be appended array
        viewModel.reachedBottom.send(true)
        try XCTAssertEqual(recorder.next().get(), SearchResponse.template.repositories + SearchResponse.template.repositories)
        
        // expect additional response immiediately after paging to be not appended array
        viewModel.textToSearch.send("c")
        try XCTAssertEqual(recorder.next().get(), [])
        try XCTAssertEqual(recorder.next().get(), SearchResponse.template.repositories)
    }
    
    func test_ネットワーク処理をするときにisLoadingが更新されるか確認() {
        let model = StubSearchModdel()
        let viewModel = SearchViewModel(model: model)
        
        let publisher = viewModel.isLoading
        
        let recorder = publisher.record()
        
        try XCTAssertEqual(recorder.next().get(), false)
        
        viewModel.textToSearch.send("swift")
        try XCTAssertEqual(recorder.next().get(), true)
        try XCTAssertEqual(recorder.next().get(), false)
    }
}
