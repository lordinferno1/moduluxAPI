//
//  ModuluxMobileApiTests.swift
//  ModuluxMobileApiTests
//
//  Created by Jonathan  Silva on 11/09/17.
//  Copyright © 2017 Modulux Studio. All rights reserved.
//

import XCTest
@testable import ModuluxMobileApi

class ModuluxMobileApiSetStageTests: XCTestCase {
    
    var api : MobileAPI!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        api = nil
        super.tearDown()
    }
    
    func testMissingConfigFile() {
        api = try! MobileAPI(configFileName: "inexistentFile")
        api.isUnitTesting = true
        do {
            try api.setStage(.develop)
        } catch let e as MobileApiError {
            let expression = e.error == .missingConfigurationFile
            XCTAssert(expression, "❌ Wrong Error Catched, expected _\(MobileApiError.ParsingError.missingConfigurationFile)_")
        } catch {
            XCTAssert(false, "❌ Error is not MobileApiError")
        }
    }
    
    func testInvalidConfigFile() {
        api = try! MobileAPI(configFileName: "invalidType")
        api.isUnitTesting = true
        do {
            try api.setStage(.develop)
        } catch let e as MobileApiError {
            let expression = e.error == .invalidConfigurationFile
            XCTAssert(expression,
                      "❌ Wrong Error Catched, expected _\(MobileApiError.ParsingError.invalidConfigurationFile)_")
        } catch {
            XCTAssert(false, "❌ Error is not MobileApiError")
        }
    }
    
    func testMissingStage() {
        api = try! MobileAPI(configFileName: "missingStage")
        api.isUnitTesting = true
        do {
            try api.setStage(.staging)
        } catch let e as MobileApiError {
            switch e.error {
            case .missingOrInvalidStage(let stage):
                XCTAssertEqual(stage, ApiStage.staging, "❌ Stage must have been \(ApiStage.staging)")
                let expression =
                    MobileApiError.ParsingError.missingOrInvalidStage(stageKey: stage) ==
                        .missingOrInvalidStage(stageKey: .staging)
                XCTAssertTrue(expression,
                              "❌ Staging is not in the correct stage")
            default:
                XCTAssert(false,
                          "❌ Wrong Error Catched, expected _\(MobileApiError.ParsingError.invalidConfigurationFile)_")
            }
        } catch {
            XCTAssert(false, "❌ Error is not MobileApiError")
        }
    }
    
    func testInvalidStageField() {
        api = try! MobileAPI(configFileName: "missingStage")
        api.isUnitTesting = true
        do {
            try api.setStage(.testing)
        } catch let e as MobileApiError {
            switch e.error {
            case .stageFieldIsNotString(let stage, let dic):
                XCTAssertEqual(stage, ApiStage.testing, "❌ Stage must have been \(ApiStage.testing)")
                let expression = MobileApiError.ParsingError.stageFieldIsNotString(stageKey: stage, dic: dic) ==
                    .stageFieldIsNotString(stageKey: .testing, dic: [:])
                XCTAssertTrue(expression,
                              "❌ Testing is not in the correct stage")
            default:
                XCTAssert(false,
                          "❌ Wrong Error Catched, expected _\(MobileApiError.ParsingError.invalidConfigurationFile)_")
            }
        } catch {
            XCTAssert(false, "❌ Error is not MobileApiError")
        }
    }
}
