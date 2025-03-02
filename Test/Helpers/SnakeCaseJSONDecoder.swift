//
//  SnakeCaseJSONDecoder.swift
//  Test
//
//  Created by Maksim Zakharov on 25.02.2025.
//

import Foundation

final class SnakeCaseJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}
