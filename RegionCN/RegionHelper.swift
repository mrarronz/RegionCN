//
//  RegionHelper.swift
//  RegionCN
//
//  Copyright © 2017年 mrarronz. All rights reserved.
//

import UIKit

public class RegionHelper: NSObject {

    public static let shared = RegionHelper()
    
    public var provincesXMLArray: NSArray {
        let bundle = Bundle.init(for: self.classForCoder)
        let path = bundle.path(forResource: "regions", ofType: "xml")
        let xmlData = NSData.init(contentsOfFile: path!)
        let xmlDict = NSDictionary.init(xmlData: xmlData! as Data)
        let provinces = xmlDict?.object(forKey: "province")
        return provinces as! NSArray
    }
    
    private var regionTXTData: Array<String> {
        let bundle = Bundle.init(for: self.classForCoder)
        let filePath = bundle.path(forResource: "region", ofType: "txt")
        let regionString = try! NSString.init(contentsOfFile: filePath!, encoding: String.Encoding.utf8.rawValue)
        let array: Array<String> = regionString.components(separatedBy: "\n")
        return array
    }
    
    public var regionTXTArray: Array<Dictionary<String, String>> {
        
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
    public func findRegionByName(regionName: String) -> Dictionary<String, String> {
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
    public func findRegionByCode(regionCode: String) -> Dictionary<String, String> {
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
    public func allProvinces() -> NSArray {
        let defaultCountryCode = "100000"
        let suffix = "0000"
        let predicate = NSPredicate.init(format: "regionCode != %@ AND regionCode ENDSWITH[cd] %@", defaultCountryCode, suffix)
        let results: NSArray = (self.regionTXTArray as NSArray).filtered(using: predicate) as NSArray
        return results
    }
    
    /// 根据省份编码查找该省份下所有的市区县
    public func regionsInProvince(provinceCode: String) -> NSArray {
        let prefix = provinceCode.substring(to: provinceCode.index(provinceCode.startIndex, offsetBy: 2))
        let predicate = NSPredicate.init(format: "regionCode != %@ AND regionCode BEGINSWITH[cd] %@", provinceCode, prefix)
        let results: NSArray = (self.regionTXTArray as NSArray).filtered(using: predicate) as NSArray
        return results
    }
    
    /// 根据省份代码和最后两个数字00查找这个省份下面的所有城市
    public func allCitiesInProvince(provinceCode: String) -> NSArray {
        let prefix = provinceCode.substring(to: provinceCode.index(provinceCode.startIndex, offsetBy: 2))
        let suffix = "00"
        let predicate = NSPredicate.init(format: "regionCode != %@ AND regionCode BEGINSWITH[cd] %@ AND regionCode ENDSWITH[cd] %@", provinceCode, prefix, suffix)
        let results: NSArray = (self.regionTXTArray as NSArray).filtered(using: predicate) as NSArray
        return results
    }
    
    /// 根据城市编码查找这个城市下面所有的区县
    public func allAreasInCity(cityCode: String) -> NSArray {
        let prefix = cityCode.substring(to: cityCode.index(cityCode.startIndex, offsetBy: 4))
        let predicate = NSPredicate.init(format: "regionCode != %@ AND regionCode BEGINSWITH[cd] %@", cityCode, prefix)
        let results: NSArray = (self.regionTXTArray as NSArray).filtered(using: predicate) as NSArray
        return results
    }
    
}
