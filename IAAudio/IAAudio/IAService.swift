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
import AlamofireObjectMapper
import ObjectMapper

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
    
    
    typealias SearchResponse = (_ result: [IASearchDocMappable]?, _ error: Error?) -> Void

    init() {
        self.searchField = SearchFields.all
    }
    
    //https://archive.org/advancedsearch.php?q=hunter+lee+brown&sort%5B%5D=&sort%5B%5D=&sort%5B%5D=&rows=50&page=1&output=json
    func searchFetch(_ completion:@escaping SearchResponse) {
        self.request?.cancel()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        request = Alamofire.request(urlStr!, method:.post, parameters: parameters)
            .validate(statusCode: 200..<201)
            .validate(contentType: ["application/json"])
            .responseArray(keyPath: "response.docs") { (response: DataResponse<[IASearchDocMappable]>) in
                switch response.result {
                case .success(let contents):
//                    print("--------------> contents: \(contents)")
                    completion(contents,nil)
                case .failure(let error):
//                    print("--------------> error: \(error)")
                    completion(nil,error)

                    break
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }.responseJSON { response in
            
//            switch response.result {
//            case .success(let JSON):
//                print(JSON)
//            case .failure(let error):
//                print(error)
//            }

        }
        
    }
    
    typealias ArchiveDocResponse = (_ result: IAArchiveDocMappable?, _ error: Error?) -> Void

    func archiveDoc(identifier:String, completion:@escaping ArchiveDocResponse) {
        self.request?.cancel()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let baseItemUrl = "https://archive.org/metadata/"
        let urlStr = "\(baseItemUrl)\(identifier)"
        
        request = Alamofire.request(urlStr, method:.get, parameters:nil)
            .validate(statusCode: 200..<201)
            .validate(contentType: ["application/json"])
            .responseObject(completionHandler: { (response: DataResponse<IAArchiveDocMappable>) in
                
                switch response.result {
                case .success(let doc):
                    completion(doc, nil)
                case .failure(let error):
                    completion(nil, error)
                    break
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
    }
    

}
