//
//  TaskFactory.swift
//  FilmMakers
//
//  Created by Adrian Tineo on 15.01.20.
//  Copyright © 2020 adriantineo.com. All rights reserved.
//
import Foundation

class TaskFactory {
    static func task(url: URL, completion: @escaping (Data) -> ()) -> URLSessionDataTask {
        func dumpInfo(data: Data?, response: URLResponse?, error: Error?) {
            if let data = data {
                print("Data: \(String(describing: String(data: data, encoding: .utf8)))")
            } else {
                print("Data: none")
            }
            if let response = response {
                print("Response: \(response)")
            } else {
                print("Response: none")
            }
            if let error = error {
                print("Network error: \(error)")
            } else {
                print("Network error: none")
            }
        }
        
        let session = URLSession(configuration: .ephemeral)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                dumpInfo(data: data, response: response, error: error)
                return
            }
            guard let data = data else {
                dumpInfo(data: nil, response: response, error: error)
                return
            }
            DispatchQueue.main.async {
                completion(data)
            }
        }
        return task
    }
}




