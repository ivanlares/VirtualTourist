//
//  Client.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/23/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import Foundation

/*
 Main Client class used to make all the requests
 for the  app.
 Inherits from BaseClient.
 */

class Client: BaseClient{
    
    static let sharedInstance = Client()
    
    private override init() {}
    
    // MARK: - Networking Methods
    
    func flickrPhotoSearch(withlatitude latitude:String, longitude:String, perPage:String, page: Int = 1, completion: @escaping ((FlickrAlbum?, Error?) -> Void)){
        
        guard let searchUrl = flickrSearchUrl(withlatitude: latitude, longitude: longitude, perPage: perPage, page: page) else{
            completion(nil, NetworkingError.customError("Unable to make flickr request"))
            return
        }
        
        self.perform(method: BaseClient.HttpMethod.get, withUrl: searchUrl){ (data: Data?,_ ,error: Error?) in
            
            if let error = error{
                completion(nil, error)
                return
            }
            
            guard let data = data else{
                completion(nil, NetworkingError.unexpectedData)
                return
            }
            
            do{
                let parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                self.parseFlickrPhoto(data: parsedData, completion: completion)
            } catch{
                completion(nil, error)
            }
        }
    }
    
    /// Method to parse flickr data
    ///
    /// - Parameter data: parsed data
    fileprivate func parseFlickrPhoto(data: Any, completion:@escaping ((FlickrAlbum?, Error?) -> Void)){
        
        if let flickrDictionary = data as? [String:Any]{
            
            // check for server error
            if let error = flickrDictionary[Constants.FlickrJsonKey.errorMessage] as? String{
                completion(nil, NetworkingError.customError(error))
                return
            }
            
            // the main dictionary accessed with `photos` key
            guard let photosDictionary = flickrDictionary[Constants.FlickrJsonKey.photos] as? [String:Any] else { return }
            
            // array that holds photo dictionaries
            guard let photosArray = photosDictionary[Constants.FlickrJsonKey.photo] as? [[String:Any]] else { return }
            
            // page for request (page of album)
            guard let page = photosDictionary[Constants.FlickrJsonKey.page] as? Int else { return }
            
            var flickrAlbum = FlickrAlbum(page: page)
            
            for photoDictionary in photosArray{
                
                var flickrPhoto: FlickrPhoto?
                
                guard let photoUrlString = photoDictionary[Constants.FlickrJsonKey.url_m] as? String else {
                    continue
                }
                
                guard let photoTitle = photoDictionary[Constants.FlickrJsonKey.title] as? String else {
                    continue
                }
                
                flickrPhoto = FlickrPhoto(urlString: photoUrlString, title: photoTitle)
                
                if let flickrPhoto = flickrPhoto{
                    flickrAlbum.photos.append(flickrPhoto)
                }
            }
            
            if flickrAlbum.photos.isEmpty{
                completion(nil, NetworkingError.customError("No photos found"))
            } else {
                completion(flickrAlbum, nil)
            }
        }
    }
    
}

// MARK: - Url Formation

extension Client{
    
    /// url generated with the flickr.photos.search method
    ///
    /// - Returns: nil if unable to form url
    fileprivate func flickrSearchUrl(withlatitude latitude:String, longitude:String, perPage:String, page:Int = 1) -> URL?{
        
        if let queryItems = flickrPhotoSearchQuery(withlatitude: latitude, longitude: longitude, perPage: perPage, page: page) {
            let flickrUrl = url(withScheme: Constants.FlickrUrlComponents.scheme, host: Constants.FlickrUrlComponents.host, path: Constants.FlickrUrlComponents.path, queryItems: queryItems)
            return flickrUrl
        }
        
        return nil
    }
    
    /// generates the specific query related to the flickr photo search method
    fileprivate func flickrPhotoSearchQuery(withlatitude latitude:String, longitude:String, perPage:String, page:Int = 1) -> [URLQueryItem]?{
        
        guard let apiKey = Constants.FlickrQueryValue.flickrApiKey else{
            return nil
        }
        
        let queryItems: [URLQueryItem] = {
            let methodQuery =
                URLQueryItem(name: Constants.FlickrQueryKey.method, value: Constants.FlickrQueryValue.photSearchMethod)
            let formatQuery =
                URLQueryItem(name: Constants.FlickrQueryKey.format, value: Constants.FlickrQueryValue.json)
            let apiKeyQuery =
                URLQueryItem(name: Constants.FlickrQueryKey.api_key, value: apiKey)
            let latitudeQuery = URLQueryItem(name: Constants.FlickrQueryKey.lat, value: latitude)
            let longitudeQuery = URLQueryItem(name: Constants.FlickrQueryKey.lon, value: longitude)
            let perPageQuery = URLQueryItem(name: Constants.FlickrQueryKey.perPage, value: perPage)
            let safeSearchQuery = URLQueryItem(name: Constants.FlickrQueryKey.safeSearch, value: Constants.FlickrQueryValue.safeSearch)
            let extrasQuery = URLQueryItem(name: Constants.FlickrQueryKey.extras, value: Constants.FlickrQueryValue.url_m)
            let noJsonCallbackQuery = URLQueryItem(name: Constants.FlickrQueryKey.nojsoncallback, value: Constants.FlickrQueryValue.noJsonCallBack)
            let pageQuery = URLQueryItem(name: Constants.FlickrQueryKey.page, value: String(page))
            
            var queries = [URLQueryItem]()
            for query in [methodQuery,formatQuery,apiKeyQuery,latitudeQuery,longitudeQuery,perPageQuery,safeSearchQuery,extrasQuery,noJsonCallbackQuery,pageQuery]{
                queries.append(query)
            }
            
            return queries
        }()
        
        return queryItems
    }
}

// MARK: - Constants

extension Client{
    
    struct Constants{
        
        struct FlickrJsonKey {
            
            static let photos = "photos"
            static let photo = "photo"
            static let page = "page"
            static let errorMessage = "message"
            static let url_m = "url_m"
            static let title = "title"
            
            private init() {}
        }
        
        /// Commponents used to build the flickr url
        /// Excluding the query
        struct FlickrUrlComponents{
            
            /// https
            static let scheme = "https"
            static let host = "api.flickr.com"
            static let path = "/services/rest"
            
            private init() {}
        }
        
        /// The key part of a key-value pair in a query
        struct FlickrQueryKey{
            
            static let method = "method"
            static let format = "format"
            static let api_key = "api_key"
            static let lat = "lat"
            static let lon = "lon"
            static let perPage = "per_page"
            static let safeSearch = "safe_search"
            static let extras = "extras"
            static let nojsoncallback = "nojsoncallback"
            static let page = "page"
            
            private init() {}
        }
        
        /// The value part of a key-value pair in a query
        struct FlickrQueryValue{
            
            /// `flickr.photos.search`
            static let photSearchMethod = "flickr.photos.search"
            static let json = "json"
            static let photoPerPage = "10"
            /// 1 for safe search on
            static let safeSearch = "1"
            /// possible `extras` query value.
            /// provides a url to a medium photo.
            static let url_m = "url_m"
            /// 1 for raw JSON, with no function wrapper.
            static let noJsonCallBack = "1"
            
            static var flickrApiKey:String? {
                let keyDictionary = PlistHelper.getPlist(withName: "ApiKeys")
                
                return keyDictionary?["FlickrApiKey"] as? String
            }
            
            static var flickrApiSecret:String? {
                let keyDictionary = PlistHelper.getPlist(withName: "ApiKeys")
                
                return keyDictionary?["FlickrApiSecret"] as? String
            }
            
            private init() {}
        }
        
        private init() {}
    }
}
