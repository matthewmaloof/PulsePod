//
//  DateFormatter+Extensions.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/19/23.
//

import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
}
