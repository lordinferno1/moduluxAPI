//
//  RequestManager.swift
//  ModuluxMobileApi
//
//  Created by Jonathan  Silva on 11/09/17.
//  Copyright © 2017 Modulux Studio. All rights reserved.
//

import Foundation
import Alamofire

public class RequestManager {
    
    public static let shared = RequestManager()
    
    private var requests : [String:DataRequest]?
    
    public func cancelRequest(forKey key: String) {
        if let request = requests?[key] {
            request.cancel()
            removeRequest(forKey: key)
        }
    }
    
    public func removeRequest(forKey key: String) {
        if let _ = requests?[key] {
            requests?[key] = nil
        }
    }
    
    public func makeRequest(withKey key: String, request: DataRequest) {
        if requests == nil {
            requests = [String:DataRequest]()
        }
        requests?[key] = request
    }
    
    
    
}

