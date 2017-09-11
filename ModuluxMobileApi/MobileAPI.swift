//
//  MobileAPI.swift
//  ModuluxMobileApi
//
//  Created by Jonathan  Silva on 11/09/17.
//  Copyright © 2017 Modulux Studio. All rights reserved.
//

import Foundation
import Alamofire

public enum ApiStage : String {
    case develop
    case staging
    case testing
    case distribution
}

public typealias JSON = [AnyHashable:Any]
public typealias JSON_RESPONSE = ((Int,JSON?,Error?) -> Void)

public class MobileAPI {
    
    public static let shared = MobileAPI()
    
    private var apiStage : ApiStage! = .develop
    private var baseUrl  : String! = ""
    private var headers  : [String:String]! = [:]
    private var debugMode = false
    
    required public init(_ stage: ApiStage = .develop, debugMode: Bool = false) {
        setStage(stage)
        self.debugMode = debugMode
    }
    
    var _stage : ApiStage {
        return apiStage
    }
    
    var _url : String {
        return baseUrl
    }
    
    public func setStage(_ stage: ApiStage) {
        print("⚠️ Api Stage changed to \(stage.rawValue).")
        apiStage = stage
        
        var dictRoot : NSDictionary?
        if let path = Bundle.main.path(forResource: "apiInfo", ofType: "plist") {
            dictRoot = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = dictRoot {
            if let stageInfo = dict[stage.rawValue] as? NSDictionary {
                if let _url = stageInfo["url"] as? String {
                    baseUrl = _url
                    return;
                }
            }
        }
        print("❌ No apiInfo.plist was found, or you didn't set the correct \"url\" key in the plist.")
    }
    
    public func setHeader(key: String, value: String?) {
        headers[key] = value
    }
    
    public func getHeaders() -> [String:String] {
        if debugMode { print("Headers = \(headers)") }
        return headers
    }
    
    public func route(_ endPoint: String) -> String {
        let url = String(format: "%@/%@", baseUrl, endPoint).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if debugMode { print(url) }
        return url
    }
    
    public func handleResponse(response: DataResponse<Any>, callback: JSON_RESPONSE) {
        let status : Int = response.response?.statusCode ?? 0
        let json : JSON? = response.result.value as? JSON ?? nil
        if json == nil {
            if debugMode { print(response.description) }
            if let data = response.data, let dataStr = String(data: data, encoding: .utf8) {
                if debugMode { print(dataStr) }
            }
        } else {
            if debugMode {
                debugPrint(json!)
            }
        }
        callback(status, json, response.error)
    }
    
    public func handleUnauthorizedApiCall(url:String, method: HTTPMethod, params: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, callbackHandler: @escaping JSON_RESPONSE) {
        Alamofire.request(url, method: method, parameters: params, encoding: encoding).responseJSON { (response) in
            self.handleResponse(response: response, callback: callbackHandler)
        }
    }
    
    public func handleAuthorizedApiCall(url: String, method: HTTPMethod, params: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, callbackHandler: @escaping JSON_RESPONSE) {
        Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: getHeaders()).responseJSON { (response) in
            self.handleResponse(response: response, callback: callbackHandler)
        }
    }
    
}
