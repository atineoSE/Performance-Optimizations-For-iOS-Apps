//
//  NetworkController.swift
//  FilmMakers
//
//  Created by Adrian Tineo on 15.01.20.
//  Copyright © 2020 adriantineo.com. All rights reserved.
//
import Foundation

let rootUrl = URL(string: "https://image.tmdb.org/t/p/original/")!

class NetworkController {
    var filmPosterTask: URLSessionDataTask? = nil
    
    func fetchFilmPoster(posterId: String, completion: @escaping (Data) -> ()) {
        let filmPosterUrl = rootUrl.appendingPathComponent(posterId + ".jpg")
        filmPosterTask = TaskFactory.task(url: filmPosterUrl, completion: completion)
        filmPosterTask?.resume()
    }
}
