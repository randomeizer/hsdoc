//
//  Bool+isOrIsNot.swift
//
//
//  Created by David Peterson on 25/6/21.
//

import Foundation

extension Bool {
    /**
     Returns "is" if `true` or "is not" if `false`
     */
    var isOrIsNot: String {
        self ? "is" : "is not"
    }
    
    var doesOrDoesNot: String {
        self ? "does" : "does not"
    }
    
    var succeedsOrFails: String {
        self ? "succeeds" : "fails"
    }
}
