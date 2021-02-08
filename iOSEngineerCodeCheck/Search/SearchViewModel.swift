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
    var reachedBottom = PassthroughSubject<Bool, Never>()
   
    // output
    @Published private(set) var items: [Item] = []
    @Published private(set) var error: SessionTaskError?
    
    private var disposables: [AnyCancellable] = []
    private var currentPage = CurrentValueSubject<Int, Never>(1)
    
    private let model = SearchModel()
    
    init(scheduler: DispatchQueue = DispatchQueue(label: "SearchViewModel")) {
        let searchTrigger = textToSearch
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self else { return }
                self.items = []
            })
            .share()
        
        let initialFetchTrigger = searchTrigger
            .map { GitHubAPI.SearchRepositories(query: $0, page: 1)}
        
        let additionalSearchParameters = Publishers
            .CombineLatest(searchTrigger,currentPage)
        
        let additionalFetchTrigger = reachedBottom
            .removeDuplicates()
            .filter { $0 }
            .debounce(for: .seconds(0.5), scheduler: scheduler)
            .withLatestFrom(additionalSearchParameters) { $1 }
            .map { GitHubAPI.SearchRepositories(query: $0, page: $1) }
        
        Publishers
            .Merge(initialFetchTrigger, additionalFetchTrigger)
            .sink { [weak self] request in
                guard let self = self else { return }
                self.model.fetch(request: request)
            }.store(in: &disposables)
        
        model.$error
            .assign(to: &$error)
        
        model.$response
            .sink { [weak self] (response) in
                guard let self = self else { return }
                self.currentPage.value += 1
                self.items = self.items + (response?.items ?? [])
            }.store(in: &disposables)
            
    }
}
