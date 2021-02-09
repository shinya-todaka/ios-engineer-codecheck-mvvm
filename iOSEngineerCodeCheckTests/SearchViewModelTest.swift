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

extension SessionTaskError: Equatable {
    public static func == (lhs: SessionTaskError, rhs: SessionTaskError) -> Bool {
        switch (lhs,rhs) {
        case (.connectionError, .connectionError):
            return true
        case (.requestError, .requestError):
            return true
        case (.responseError, .responseError):
            return true
        default:
            return false
        }
    }
}

enum MyError: Error, Equatable {
    case unknown
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
