//
//  ClassName.swift
//  iOSEngineerCodeCheck
//
//  Created by 戸高新也 on 2021/02/03.
//  Copyright © 2021 YUMEMI Inc. All rights reserved.
//

import Foundation

extension NSObjectProtocol {
    static var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
