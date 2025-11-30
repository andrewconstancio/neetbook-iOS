//
//  BookViewHorizontalTabs.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/10/25.
//

enum HorizontalTab {
    case info, comments, activity, lastReads
    
    var title: String {
        switch self {
        case .info:
            return "Info"
        case .comments:
            return "Comments"
        case .activity:
            return "Activity"
        case .lastReads:
            return "Last Read"
        }
    }
}

