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
    var error: AnyPublisher<SessionTaskError?, Never>
    var response: AnyPublisher<GitHubAPI.SearchRepositories.Response?, Never>
    var requestSubject = PassthroughSubject<GitHubAPI.SearchRepositories, Never>()
    var disposables: [AnyCancellable] = []
    
    init() {
        var _error = PassthroughSubject<SessionTaskError?, Never>()
        self.error = _error.eraseToAnyPublisher()
        
        var _response = PassthroughSubject<GitHubAPI.SearchRepositories.Response?, Never>()
        self.response = _response.eraseToAnyPublisher()
        
        requestSubject.sink { [weak self] _ in
            guard let self = self else { return }
            _response.send(SearchResponse.template)
        }.store(in: &disposables)
    }
}

class SearchViewModelTest: XCTestCase {

    var disposables: [AnyCancellable] = []
  
    func test_検索時にrepositoriesが流れてくることを確認() {
        let model = StubSearchModdel()
        let viewModel = SearchViewModel(model: model)
        
        // 1. Create a publisher
        let publisher = viewModel.repositories
          
          // 2. Start recording the publisher
        let recorder = publisher.record()
          
          // 3. Wait for a publisher expectation
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
}
