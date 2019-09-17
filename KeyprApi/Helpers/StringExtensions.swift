//
//  String+Bae64.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/28/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

extension String {
    internal func addBas64Padding() -> String {
        return self.padding(toLength: ((self.count+3)/4)*4,
                          withPad: "=",
                          startingAt: 0)
    }
}
