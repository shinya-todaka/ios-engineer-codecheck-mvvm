//
//  SearchModelTest.swift
//  iOSEngineerCodeCheckTests
//
//  Created by 戸高新也 on 2021/02/09.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

@testable import iOSEngineerCodeCheck
import XCTest
import APIKit
import Combine

class SearchModelTest: XCTestCase {

    func test_responseが帰ってきたときにpublisherで値を流すか確認() throws {
        let model = SearchModel(gitHubAPI: StubGitHubAPI(result: .success(SearchResponse.template)))
        
        let publisher = model.response
        let recorder = publisher.record()

        model.requestSubject.send(.init(query: "swift", page: 1))
        try XCTAssertEqual(recorder.next().get(), SearchResponse.template)
    }
    
    func test_errorが帰ってきたときにpublisherで値を流すか確認() throws {
        let model = SearchModel(gitHubAPI: StubGitHubAPI(result: .failure(SessionTaskError.connectionError(MyError.unknown))))
        
        let publisher = model.error
        let recorder = publisher.record()
        
        model.requestSubject.send(.init(query: "swift", page: 1))
        try XCTAssertEqual(recorder.next().get(), SessionTaskError.connectionError(MyError.unknown))
    }
}
