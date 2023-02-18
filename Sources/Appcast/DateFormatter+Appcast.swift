//
//  DateFormatter+Appcast.swift
//  Appcast
//
//  Created by Marcel Dierkes on 17.02.23.
//

import Foundation

extension DateFormatter {
    static var simple: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()
    
    static var gmt: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
}
