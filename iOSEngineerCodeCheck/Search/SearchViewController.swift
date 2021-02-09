//
//  ViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit
import APIKit
import SwiftUI
import Combine

class SearchViewController: UITableViewController, StoryboardInstantiatable {

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.placeholder = "GitHubのリポジトリを検索できるよー"
            searchBar.delegate = self
        }
    }
    
    private var viewModel = SearchViewModel()
    private var disposables: [AnyCancellable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.repositories
            // I don't know why but sink is not called without receive(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
            self.tableView.reloadData()
        }.store(in: &disposables)
    }
    
    private func fetchRepositories(text: String) {
        viewModel.textToSearch.send(text)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repositoriesValue.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Repository", for: indexPath)
        let repo = viewModel.repositoriesValue[indexPath.row]
        cell.textLabel?.text = repo.fullName
        cell.detailTextLabel?.text = repo.language
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController.instantiate(with: viewModel.repositoriesValue[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxScrollDistance = max(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        let isReachedBottom = maxScrollDistance <= scrollView.contentOffset.y
        viewModel.reachedBottom.send(isReachedBottom)
    }
    
    deinit {
        print("deinit viewController")
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.text = ""
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, text.count != 0 else { return }
        fetchRepositories(text: text)
    }
}
