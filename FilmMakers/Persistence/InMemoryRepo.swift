//
//  InMemoryRepo.swift
//  FilmMakers
//
//  Created by Adrian Tineo on 21.01.20.
//  Copyright © 2020 adriantineo.com. All rights reserved.
//

import Foundation
import UIKit

class InMemoryRepo {
    private var store: [String:UIImage] = [:]
    
    func save(posterId: String, poster: UIImage) {
        store[posterId] = poster
    }
    
    func retrieve(posterId: String) -> UIImage? {
        return store[posterId]
    }
}

