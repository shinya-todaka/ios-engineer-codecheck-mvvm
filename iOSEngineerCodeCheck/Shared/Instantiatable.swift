//
//  Instantiatable.swift
//  iOSEngineerCodeCheck
//
//  Created by 戸高新也 on 2021/02/03.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

import UIKit

public protocol Instantiatable: NSObjectProtocol {
    static func instantiate() -> Self
}

public protocol StoryboardInstantiatable: UIViewController, Instantiatable {
    static var storyboard: UIStoryboard { get }
}

public extension StoryboardInstantiatable {
    static var storyboard: UIStoryboard {
        return UIStoryboard(name: className, bundle: Bundle(for: self))
    }

    static func instantiate() -> Self {
        return storyboard.instantiateInitialViewController() as! Self
    }
}

public extension StoryboardInstantiatable where Self: Injectable {
    static var storyboard: UIStoryboard {
        return UIStoryboard(name: className, bundle: Bundle(for: self))
    }

    static func instantiate(with dependency: Dependency) -> Self {
        let vc = storyboard.instantiateInitialViewController() as! Self
        vc.inject(dependency)
        return vc
    }
}
