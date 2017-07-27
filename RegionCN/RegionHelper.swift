//
//  RegionHelper.swift
//  RegionCN
//
//  Copyright © 2017年 mrarronz. All rights reserved.
//

import UIKit
import MJExtension

class District: NSObject {
    var districtId: String?
    var districtName: String?
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["districtId" : "_id", "districtName" : "_name"]
    }
}

class City: NSObject {
    var cityId: String?
    var cityName: String?
    var district: Any?
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["cityId" : "_id", "cityName" : "_name"]
    }
}

class Province: NSObject {
    var provinceId: String?
    var provinceName: String?
    var city: NSArray?
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["provinceId" : "_id", "provinceName" : "_name"]
    }
    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["city" : "City"]
    }
}

class RegionHelper: NSObject {

    static let shared = RegionHelper()
    
    var provincesXMLArray: NSMutableArray {
        let bundle = Bundle.init(for: self.classForCoder)
        let path = bundle.path(forResource: "regions", ofType: "xml")
        let xmlData = NSData.init(contentsOfFile: path!)
        let xmlDict = NSDictionary.init(xmlData: xmlData! as Data)
        let provinceData = xmlDict?.object(forKey: "province")
        let provinces = Province.mj_objectArray(withKeyValuesArray: provinceData)
        return provinces!
    }
    
    var regionTXTData: Array<String> {
        let bundle = Bundle.init(for: self.classForCoder)
        let filePath = bundle.path(forResource: "region", ofType: "txt")
        let regionString = try! NSString.init(contentsOfFile: filePath!, encoding: String.Encoding.utf8.rawValue)
        let array: Array<String> = regionString.components(separatedBy: "\n")
        return array
    }
    
    var regionTXTArray: Array<Dictionary<String, String>> {
        
        var array = Array<Dictionary<String, String>>()
        
        for item in self.regionTXTData {
            let regionString = item.replacingOccurrences(of: "\r", with: "").trimmingCharacters(in: .whitespaces)
            let regionCode = regionString.substring(to: regionString.index(regionString.startIndex, offsetBy: 6))
            let regionName = regionString.substring(from: regionString.index(regionString.startIndex, offsetBy: 7))
            let dictionary = ["regionCode" : regionCode, "regionName" : regionName]
            
            array.append(dictionary)
        }
        
        return array
    }
    
    /// 根据地区名字查找地区对应的数据字典
    func findRegionByName(regionName: String) -> Dictionary<String, String> {
        var dict = Dictionary<String, String>()
        for item in self.regionTXTArray {
            let name: String = item["regionName"]!
            if name == regionName {
                dict = item
                break
            }
        }
        return dict
    }
    
    /// 根据地区编码查找对应的数据字典
    func findRegionByCode(regionCode: String) -> Dictionary<String, String> {
        var dict = Dictionary<String, String>()
        for item in self.regionTXTArray {
            let code: String = item["regionCode"]!
            if code == regionCode {
                dict = item
                break
            }
        }
        return dict
    }
    
    /// 查找中国所有省份
    func allProvinces() -> NSArray {
        let defaultCountryCode = "100000"
        let suffix = "0000"
        let predicate = NSPredicate.init(format: "regionCode != %@ AND regionCode ENDSWITH[cd] %@", defaultCountryCode, suffix)
        let results: NSArray = (self.regionTXTArray as NSArray).filtered(using: predicate) as NSArray
        return results
    }
    
    /// 根据省份编码查找该省份下所有的市区县
    func regionsInProvince(provinceCode: String) -> NSArray {
        let prefix = provinceCode.substring(to: provinceCode.index(provinceCode.startIndex, offsetBy: 2))
        let predicate = NSPredicate.init(format: "regionCode != %@ AND regionCode BEGINSWITH[cd] %@", provinceCode, prefix)
        let results: NSArray = (self.regionTXTArray as NSArray).filtered(using: predicate) as NSArray
        return results
    }
    
    /// 根据省份代码和最后两个数字00查找这个省份下面的所有城市
    func allCitiesInProvince(provinceCode: String) -> NSArray {
        let prefix = provinceCode.substring(to: provinceCode.index(provinceCode.startIndex, offsetBy: 2))
        let suffix = "00"
        let predicate = NSPredicate.init(format: "regionCode != %@ AND regionCode BEGINSWITH[cd] %@ AND regionCode ENDSWITH[cd] %@", provinceCode, prefix, suffix)
        let results: NSArray = (self.regionTXTArray as NSArray).filtered(using: predicate) as NSArray
        return results
    }
    
    /// 根据城市编码查找这个城市下面所有的区县
    func allAreasInCity(cityCode: String) -> NSArray {
        let prefix = cityCode.substring(to: cityCode.index(cityCode.startIndex, offsetBy: 4))
        let predicate = NSPredicate.init(format: "regionCode != %@ AND regionCode BEGINSWITH[cd] %@", cityCode, prefix)
        let results: NSArray = (self.regionTXTArray as NSArray).filtered(using: predicate) as NSArray
        return results
    }
    
}
