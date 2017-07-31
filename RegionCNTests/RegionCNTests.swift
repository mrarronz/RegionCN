//
//  RegionCNTests.swift
//  RegionCNTests
//
//  Copyright © 2017年 mrarronz. All rights reserved.
//

import XCTest
@testable import RegionCN

class RegionCNTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testRegionByCode() {
        let region = RegionHelper.shared.findRegionByCode(regionCode: "110000")
        let regionName = region["regionName"]
        XCTAssert(regionName == "北京市")
    }
    
    func testRegionByName() {
        let region = RegionHelper.shared.findRegionByName(regionName: "中国")
        let regionCode = region["regionCode"]
        XCTAssert(regionCode == "100000")
    }
    
    func testAllProvince() {
        let allProvince = RegionHelper.shared.allProvinces()
        print("all province: \(allProvince)")
        XCTAssert(allProvince.count != 0)
    }
    
    func testRegionsInProvince() {
        let regions = RegionHelper.shared.regionsInProvince(provinceCode: "130000")
        XCTAssert(regions.count != 0)
    }
    
    func testAllCitiesInProvince() {
        let cities = RegionHelper.shared.allCitiesInProvince(provinceCode: "130000")
        XCTAssert(cities.count == 11)
    }
    
    func testAllAreasInCity() {
        
        self.measure {
            let areas = RegionHelper.shared.allAreasInCity(cityCode: "130185")
            XCTAssert(areas.count != 0)
        }
    }
    
    func testProvincesXMLArray() {
        let provinces = RegionHelper.shared.provincesXMLArray
        XCTAssert(provinces.count != 0)
    }
    
    func testCityClassInXMLProvince() {
        let provinces = RegionHelper.shared.provincesXMLArray
        let province = provinces.firstObject as! NSDictionary
        let cityList = province.object(forKey: "city") as? NSArray
        let firstCity = cityList?.firstObject as AnyObject
        XCTAssert(firstCity.isKind(of: NSDictionary.classForCoder()))
    }
    
    func testCityList() {
        let provinces = RegionHelper.shared.provincesXMLArray
        let province = provinces.firstObject as! NSDictionary
        let cityList = RegionHelper.shared.cityList(inProvince: province)
        XCTAssertTrue(cityList != nil)
    }
    
    func testDistrictList() {
        let provinces = RegionHelper.shared.provincesXMLArray
        let province = provinces.firstObject as! NSDictionary
        let cityList = RegionHelper.shared.cityList(inProvince: province)
        let districtList = RegionHelper.shared.districtList(inCityList: cityList, atIndex: 0)
        XCTAssertTrue(districtList != nil)
    }
    
}
