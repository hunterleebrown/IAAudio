//
//  IAService.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/9/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import UIKit

import Alamofire

enum SearchFields : Int {
    case all = 0
    case creator = 1
}


class IAService {

    var urlStr : String?
    var parameters : Dictionary<String, String>!
    var _queryString : String?
    var _identifier : String?
    var _start : Int = 0
    var searchField : SearchFields

    let baseItemUrl = "https://archive.org/metadata/"
    
    var queryString : String? {
        set {
            self._queryString = newValue!
            self.urlStr = "https://archive.org/advancedsearch.php"
            
            switch self.searchField {
            case .all:
                self._queryString = newValue!
            case .creator:
                self._queryString = "creator:\(newValue!)"
            }

            let nots = ["podcasts_mirror", "web", "webwidecrawl", "samples_only"]
            var queryExclusions = ""
            for not in nots {
                queryExclusions += " AND NOT collection:\(not)"
            }

            self.parameters = [
                "q" : "\(self._queryString!)\(queryExclusions) AND format:\"VBR MP3\" AND (mediatype:audio OR mediatype:etree)",
                "output" : "json",
                "rows" : "50"
            ];
            
        }
        get {
            return self._queryString
        }
        
    }
    
    var request : Request?
    
    
    typealias SearchResponse = (_ result: [IASearchDocDecodable]?, _ error: Error?) -> Void

    init() {
        self.searchField = SearchFields.all
    }
    
    //r
    func searchFetch(_ completion:@escaping SearchResponse) {
        self.request?.cancel()

        guard let qs = self._queryString, qs.count > 0 else {
            completion([IASearchDocDecodable](), nil)
            return
        }

        request = AF.request(urlStr!, method:.post, parameters: parameters)
            .validate(statusCode: 200..<201)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: IASearchResults.self) { response in
                switch response.result {
                case .success(let results):
                    completion(results.response?.docs, nil)
                case .failure(let error):
                    completion(nil, error)
                }

            }

    }
    
    typealias ArchiveDocResponse = (_ result: IAArchiveDocDecodable?, _ error: Error?) -> Void

    func archiveDoc(identifier:String, completion:@escaping ArchiveDocResponse) {
        self.request?.cancel()
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let baseItemUrl = "https://archive.org/metadata/"
        let urlStr = "\(baseItemUrl)\(identifier)"

        print("url: \(urlStr)")
        
        request = AF.request(urlStr, method:.get, parameters:nil)
            .validate(statusCode: 200..<201)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: IAArchiveDocDecodable.self) { response in
                switch response.result {
                case .success(let doc):

                    print("doc: \(doc)")

                    completion(doc, nil)
                case .failure(let error):

                    print("error: \(error)")

                    completion(nil, error)
                }

            }

        print("request: \(String(describing: request))")
    }
    

}
