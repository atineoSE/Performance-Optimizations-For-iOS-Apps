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
    var filmPosterTasks: [String: URLSessionDataTask] = [:]
    
    func fetchFilmPoster(posterId: String, small: Bool, completion: @escaping (Data) -> ()) {
        let rootUrl: URL
        if (small) {
            rootUrl = URL(string: RootPath.smallPoster.rawValue)!
        } else {
            rootUrl = URL(string: RootPath.bigPoster.rawValue)!
        }
        let filmPosterUrl = rootUrl.appendingPathComponent(posterId + ".jpg")
        let filmPosterTask = TaskFactory.task(url: filmPosterUrl, completion: completion)
        filmPosterTasks[posterId] = filmPosterTask
        filmPosterTask.resume()
    }
    
    func cancelFetch(for posterId: String) {
        guard let filmPosterTask = filmPosterTasks[posterId] else { return }
        filmPosterTask.cancel()
        filmPosterTasks.removeValue(forKey: posterId)
    }
    
    func isFetching(posterId: String) -> Bool {
        return filmPosterTasks[posterId] != nil
    }
    
    deinit {
        filmPosterTasks.forEach { $0.value.cancel() }
    }
}
