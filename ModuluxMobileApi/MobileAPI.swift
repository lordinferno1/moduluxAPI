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

public struct MobileApiError : Swift.Error {
    public enum ParsingError : Equatable {
        case missingConfigurationFile
        case invalidConfigurationFile
        case missingOrInvalidStage(stageKey: ApiStage)
        case stageFieldIsNotString(stageKey: ApiStage, dic: NSDictionary)
        
        public static func ==(lhs: ParsingError, rhs: ParsingError) -> Bool {
            switch (lhs, rhs) {
            case (.missingConfigurationFile, .missingConfigurationFile):
                return true
            case (.invalidConfigurationFile, .invalidConfigurationFile):
                return true
            case (.missingOrInvalidStage(let stage1), .missingOrInvalidStage(let stage2)):
                return stage1 == stage2
            case (.stageFieldIsNotString(let stage1, let d1), .stageFieldIsNotString(let stage2, let d2)):
                return stage1 == stage2
            default:
                return false
            }
        }
    }
    
    let description : String
    let localizedDescription: String
    let error: ParsingError
}

public typealias JSON = [AnyHashable:Any]
public typealias JSON_RESPONSE = ((Int,JSON?,Error?) -> Void)

open class MobileAPI {
    
    public static let shared = try! MobileAPI()
    
    private var configFileName : String
    private var apiStage : ApiStage! = nil
    private var baseUrl  : String! = ""
    private var customUrls : [String:String] = [:]
    private var headers  : [String:String]! = [:]
    private var debugMode = false
    
    required public init(configFileName fileName: String = "apiInfo", _ debugMode: Bool = false) throws {
        configFileName = fileName
        self.debugMode = debugMode
    }
    
    public var _stage : ApiStage {
        return apiStage
    }
    
    public var _url : String {
        return baseUrl
    }
    
    public var _headers : [String:String] {
        if debugMode { print("Headers = \(headers)") }
        return headers
    }
    
    public func setStage(_ stage: ApiStage) throws {
        print("⚠️ Api Stage changed to \(stage.rawValue).")
        apiStage = stage
        customUrls.removeAll(keepingCapacity: true)
        var dictRoot : NSDictionary?
        
        //
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: configFileName, ofType: "plist") else {
            throw MobileApiError(description: "The file \(configFileName).plist doesn't exists", localizedDescription: "MissingMobileApiConfigFile", error: .missingConfigurationFile)
        }
        dictRoot = NSDictionary(contentsOfFile: path)
        guard let dictionary = dictRoot else {
            throw MobileApiError(description: "Coult parse file to a dictionary", localizedDescription: "NotADictionary", error: .invalidConfigurationFile)
        }
        guard let stageInfo = dictionary[stage.rawValue] as? NSDictionary else {
            throw MobileApiError(description: "Missing or Invalid \(stage.rawValue)", localizedDescription: "MissingOrInvalidStage", error: .missingOrInvalidStage(stageKey: stage))
        }
        for field in stageInfo {
            guard let fieldKey = field.key as? String, let value = field.value as? String else {
                throw MobileApiError(description: "Stage \(stage) has invalid key/values", localizedDescription: "InvalidStageKeyValues", error: .stageFieldIsNotString(stageKey: stage, dic: stageInfo))
            }
            if let valueStr = field.value as? String, fieldKey.elementsEqual("url") {
                baseUrl = valueStr
            } else {
                customUrls[fieldKey] = value
            }
        }
    }
    
    public func setHeader(key: String, value: String?) {
        headers[key] = value
    }
    
    open func route(customUrl key: String, endPoint: String) -> String? {
        guard let url = customUrls[key] else {
            return nil
        }
        return String(format: "%@%@",url, endPoint)
    }
    
    open func route(_ endPoint: String) -> String {
        if apiStage == nil {
            assertionFailure("❌ apiStage has not been set with setStage(_:)")
        }
        let url = String(format: "%@/%@", baseUrl, endPoint).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if debugMode { print(url) }
        return url
    }
    
    open func handleResponse(response: DataResponse<Any>, callback: JSON_RESPONSE) {
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
    
    open func handleUnauthorizedApiCall(key: String, url:String, method: HTTPMethod, params: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, callbackHandler: @escaping JSON_RESPONSE) {
        let req = Alamofire.request(url, method: method, parameters: params, encoding: encoding).responseJSON { (response) in
            RequestManager.shared.removeRequest(forKey: key)
            self.handleResponse(response: response, callback: callbackHandler)
        }
        RequestManager.shared.makeRequest(withKey: key, request: req)
    }
    
    open func handleAuthorizedApiCall(key: String, url: String, method: HTTPMethod, params: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, callbackHandler: @escaping JSON_RESPONSE) {
        let req = Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: _headers).responseJSON { (response) in
            RequestManager.shared.removeRequest(forKey: key)
            self.handleResponse(response: response, callback: callbackHandler)
        }
        RequestManager.shared.makeRequest(withKey: key, request: req)
    }
    
}
