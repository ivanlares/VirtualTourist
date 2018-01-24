//
//  BaseClient.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/22/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import Foundation

/*
    This class is meant to be inherited by a Client class.
    It will provide basic Post and Get request methods.
*/

class BaseClient{
    
    func  perform(method: HttpMethod, withUrl url: URL, completion: @escaping RequestCompletionHandler){
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
       
        let task = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) -> Void in
            
            if let data = data{
                completion(data, nil, nil)
                return
            }
            
            if let error = error{
                completion(nil, nil, error)
                return
            }
            
            // unknown error occured
            let customError = NetworkingError.customError("Unable to make \(method.rawValue) request.")
            completion(nil, nil, customError)
        }
        
        task.resume()
    }
    
    // MARK: - Helper

    /// Buils url with the following components
    func url(withScheme scheme: String, host:String, path: String, queryItems: [URLQueryItem]?) -> URL?{
        
        let urlComponents = NSURLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
    }

}

// MARK: Data Types

extension BaseClient{
    
    enum HttpMethod: String{
        case post = "POST"
        case get = "GET"
    }
    
    typealias RequestCompletionHandler = ((Data?, URLResponse?, Error?) -> Void)
}
