//
//  Throwable.swift
//  IAAudio
//
//  Created by Hunter Lee Brown on 10/1/20.
//  Copyright © 2020 Hunter Lee Brown. All rights reserved.
//

import Foundation


public struct Throwable<T: Decodable>: Decodable {

    public let result: Result<T, Error>

    public init(from decoder: Decoder) throws {
        let catching = { try T(from: decoder) }
        result = Result(catching: catching )
    }
}
