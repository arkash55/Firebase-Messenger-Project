//
//  Extensions.swift
//  newMessageApp
//
//  Created by Arkash Vijayakumar on 06/05/2021.
//

import Foundation

extension String {
    public func safeDatabaseKey() -> String {
        return self.replacingOccurrences(of: "@", with: "-").replacingOccurrences(of: ".", with: "-")
    }
}
