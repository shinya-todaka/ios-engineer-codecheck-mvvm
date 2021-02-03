//
//  ViewController2.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit
import Nuke

class DetailViewController: UIViewController, StoryboardInstantiatable, Injectable {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var starsCountLabel: UILabel!
    @IBOutlet weak var watchersCountLabel: UILabel!
    @IBOutlet weak var forksCountLabel: UILabel!
    @IBOutlet weak var issuesCountLabel: UILabel!
    
    private var item: Item!
    
    func inject(_ dependency: Item) {
        self.item = dependency
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(item: item)
    }
    
    private func configure(item: Item) {
        languageLabel.text = item.language.map { "Written in \($0)" }
        starsCountLabel.text = "\(item.stargazersCount) stars"
        watchersCountLabel.text = "\(item.watchersCount) watchers"
        forksCountLabel.text = "\(item.forksCount) forks"
        issuesCountLabel.text = "\(item.openIssuesCount) open issues"
        titleLabel.text = item.fullName
        
        guard let url = URL(string: item.owner.avatarUrl) else { return }
        Nuke.loadImage(with: url, into: profileImageView)
    }
}
