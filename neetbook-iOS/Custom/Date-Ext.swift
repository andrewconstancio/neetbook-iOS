//
//  Date-Ext.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/6/24.
//

import Foundation

extension Date {
func timeAgoDisplay() -> String {
  let secondsAgo = Int(Date().timeIntervalSince(self))
  let minute = 60
  let hour = 60 * minute
  let day = 24 * hour
  let week = 7 * day
  if secondsAgo < minute {
      return "a few seconds ago"
  }
  
  else if secondsAgo < hour {
      return "\(secondsAgo / minute)m"
  }
  else if secondsAgo < day {
      return "\(secondsAgo / hour)h"
  }
  else if secondsAgo < week {
      return "\(secondsAgo / day)d"
  }
    
    return "\(secondsAgo / week)w"
  }
}
