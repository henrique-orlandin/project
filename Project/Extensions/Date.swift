//
//  Date.swift
//  Jam
//
//  Created by Henri on 2020-02-09.
//  Copyright © 2020 Henrique Orlandin. All rights reserved.
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
            return "\(secondsAgo) sec ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) min ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) h ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        }

        return "\(secondsAgo / week) weeks ago"
    }
}
