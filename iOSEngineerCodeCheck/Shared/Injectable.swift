//
//  Injectable.swift
//  iOSEngineerCodeCheck
//
//  Created by 戸高新也 on 2021/02/03.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

import Foundation

public protocol Injectable {
    associatedtype Dependency = Void
    func inject(_ dependency: Dependency)
}

public extension Injectable where Dependency == Void {
    func inject(_ dependency: Dependency) {
    }
}
