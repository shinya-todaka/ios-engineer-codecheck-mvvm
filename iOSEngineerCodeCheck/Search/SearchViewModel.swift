//
//  SearchViewModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 戸高新也 on 2021/02/07.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

import Combine
import APIKit

class SearchViewModel {
    
    // input
    var textToSearch = PassthroughSubject<String, Never>()
    var reachedBottom = CurrentValueSubject<Bool, Never>(false)
   
    // output
    var repositoriesValue: [Repository] {
        _repositories.value
    }
    
    var error: AnyPublisher<SessionTaskError?, Never> {
        model.error
    }
    
    private let _repositories = CurrentValueSubject<[Repository], Never>([])
    private(set) var repositories: AnyPublisher<[Repository],Never>
    
    private let currentPage = CurrentValueSubject<Int,Never>(1)
    
    private var disposables: [AnyCancellable] = []
    private let model: SearchModelProtocol
    
    init(model: SearchModelProtocol = SearchModel(), scheduler: DispatchQueue = DispatchQueue(label: "SearchViewModel")) {
        self.model = model

        self.repositories = _repositories
            .dropFirst()
            .eraseToAnyPublisher()
        
        let searchTrigger = textToSearch
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self else { return }
                self._repositories.send([])
            })
            .share()
        
        let initialFetchTrigger = searchTrigger
            .map { GitHubAPI.SearchRepositories(query: $0, page: 1)}
        
        let additionalSearchParameters = Publishers
            .CombineLatest(searchTrigger,currentPage)
        
        let additionalFetchTrigger = reachedBottom
            .removeDuplicates()
            .filter { $0 }
            .withLatestFrom(additionalSearchParameters) { $1 }
            .map { GitHubAPI.SearchRepositories(query: $0, page: $1) }
        
        Publishers
            .Merge(initialFetchTrigger, additionalFetchTrigger)
            .sink { [weak self] request in
                guard let self = self else { return }
                self.model.requestSubject.send(request)
            }.store(in: &disposables)
        
        model.response
            .compactMap { $0 }
            .sink { [weak self] (response) in
                guard let self = self else { return }
                self.currentPage.value += 1
                self._repositories.send(self._repositories.value + response.repositories)
            }.store(in: &disposables)
    }
    
    deinit {
        print("deinit viewModel")
    }
}
