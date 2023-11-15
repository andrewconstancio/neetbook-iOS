//
//  String-Ext.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 10/15/23.
//

import UIKit

extension String{
    var htmlStripped : String{
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
