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
import XCGLogger


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
            
            self.parameters = [
                "q" : "\(self._queryString!) AND NOT collection:web AND NOT collection:webwidecrawl AND format:\"VBR MP3\"",
                "output" : "json",
                "rows" : "50"
            ];
            
        }
        get {
            return self._queryString
        }
        
    }
    
    var request : Request?
    
    
    typealias ServiceResponse = (_ result: [IAMapperDoc]?, _ error: Error?) -> Void

    
    init() {
        self.searchField = SearchFields.all
    }
    
    //https://archive.org/advancedsearch.php?q=hunter+lee+brown&sort%5B%5D=&sort%5B%5D=&sort%5B%5D=&rows=50&page=1&output=json
    func fetch(_ completion:@escaping ServiceResponse) {
        self.request?.cancel()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        request = Alamofire.request(urlStr!, method:.post, parameters: parameters)
            .validate(statusCode: 200..<201)
            .validate(contentType: ["application/json"])
            .responseArray(keyPath: "response.docs") { (response: DataResponse<[IAMapperDoc]>) in
                switch response.result {
                case .success(let contents):
                    print("--------------> contents: \(contents)")
                    completion(contents,nil)
                case .failure(let error):
                    print("--------------> error: \(error)")
                    completion(nil,error)

                    break
                }
            
        }.responseJSON { response in
        }
        
    }
    

}
