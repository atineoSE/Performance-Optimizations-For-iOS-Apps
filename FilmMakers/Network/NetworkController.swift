//
//  NetworkController.swift
//  FilmMakers
//
//  Created by Adrian Tineo on 15.01.20.
//  Copyright © 2020 adriantineo.com. All rights reserved.
//
import Foundation

enum RootPath: String {
    typealias RawValue = String
    case smallPoster = "https://image.tmdb.org/t/p/w220_and_h330_face/"
    case bigPoster = "https://image.tmdb.org/t/p/original/"
}

class NetworkController {
    var filmPosterTask: URLSessionDataTask? = nil
    
    func fetchFilmPoster(posterId: String, small: Bool, completion: @escaping (Data) -> ()) {
        let rootUrl: URL
        if (small) {
            rootUrl = URL(string: RootPath.smallPoster.rawValue)!
        } else {
            rootUrl = URL(string: RootPath.bigPoster.rawValue)!
        }
        let filmPosterUrl = rootUrl.appendingPathComponent(posterId + ".jpg")
        filmPosterTask = TaskFactory.task(url: filmPosterUrl, completion: completion)
        filmPosterTask?.resume()
    }
}
