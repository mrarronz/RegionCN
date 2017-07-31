//
//  RegionPickerView.swift
//  TestRegionCN
//
//  Copyright © 2017年 mrarronz. All rights reserved.
//

import UIKit
import RegionCN

public class PickerViewStyle: NSObject {
    public var toolBarHeight: CGFloat?
    public var contentHeight: CGFloat?
    public var pickerHeight: CGFloat?
    public var buttonWidth: CGFloat?
    public var pickerTextColor: UIColor?
    public var itemTitleColor: UIColor?
}

@objc public protocol RegionPickerDelegate : class {
    
    @objc optional func picker(picker: RegionPickerView, didSelectRegion region: String?)
}

open class RegionPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    open var style: PickerViewStyle?
    
    let pickerWidth = UIScreen.main.bounds.size.width
    
    var delegate: RegionPickerDelegate?
    
    private var provinceList: NSArray {
        let items = RegionHelper.shared.provincesXMLArray
        return items
    }
    
    private var cityList: NSArray?
    
    private var districtList: NSArray?
    
    private var selectedProvince: NSDictionary?
    
    private var selectedCity: NSDictionary?
    
    private var selectedDistrict: NSDictionary?
    
    // MARK: - Init UI
    
    var pickerView: UIPickerView {
        let pickerView = UIPickerView.init(frame: CGRect.init(x: 0, y: (style?.toolBarHeight)!, width: pickerWidth, height: (style?.pickerHeight)!))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        return pickerView
    }
    
    var contentView: UIView {
        let contentView = UIView.init(frame: CGRect.init(x: 0,
                                                         y: self.bounds.size.height - (style?.contentHeight)!,
                                                         width: pickerWidth,
                                                         height: (style?.contentHeight)!))
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(toolbar)
        contentView.addSubview(pickerView)
        return contentView
    }
    
    var toolbar: UIToolbar {
        
        let toolBar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: pickerWidth, height: (style?.toolBarHeight)!))
        toolBar.barTintColor = UIColor.init(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        
        let cancelBtn = UIButton.init(type: .system)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(style?.itemTitleColor, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cancelBtn.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        toolBar.addSubview(cancelBtn)
        
        let doneBtn = UIButton.init(type: .system)
        doneBtn.setTitle("完成", for: .normal)
        doneBtn.setTitleColor(style?.itemTitleColor, for: .normal)
        doneBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        doneBtn.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
        toolBar.addSubview(doneBtn)
        
        cancelBtn.frame = CGRect.init(x: 0, y: 0, width: (style?.buttonWidth)!, height: (style?.toolBarHeight)!)
        doneBtn.frame = CGRect.init(x: pickerWidth-(style?.buttonWidth)!, y: 0, width: (style?.buttonWidth)!, height: (style?.toolBarHeight)!)
        
        return toolBar
    }
    
    // MARK: - Init
    
    public init(delegate: RegionPickerDelegate) {
        super.init(frame: UIScreen.main.bounds)
        
        if self.style == nil {
            style = PickerViewStyle.init()
            style?.toolBarHeight = 44
            style?.contentHeight = 264
            style?.pickerHeight = 220
            style?.buttonWidth = 70
            style?.pickerTextColor = UIColor.blue
            style?.itemTitleColor = UIColor.orange
        }
        self.delegate = delegate
        initData()
    }
    
    init(style:PickerViewStyle, delegate: RegionPickerDelegate) {
        super.init(frame: UIScreen.main.bounds)
        self.style = style
        self.delegate = delegate
        initData()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initData() {
        self.backgroundColor = UIColor.init(white: 0, alpha: 0)
        self.addSubview(contentView)
        
        // init default data
        let province = provinceList.firstObject as! NSDictionary
        self.cityList = province.object(forKey: "city") as? NSArray
        let city = self.cityList?.firstObject as? NSDictionary
        let district = city?.object(forKey: "district") as AnyObject
        
        if district.isKind(of: NSArray.classForCoder()) {
            self.districtList = district as? NSArray
        } else {
            self.districtList = NSArray.init(array: district as! NSArray)
        }
        self.selectedProvince = province
        self.selectedCity = city
        self.selectedDistrict = self.districtList?.firstObject as? NSDictionary
    }
    
    // MARK: - UIPickerViewDataSource
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var count: Int?
        
        switch component {
            
        case 0:
            count = provinceList.count
            break
        case 1:
            count = (cityList == nil) ? 0 : cityList?.count
            break
        case 2:
            count = (districtList == nil) ? 0 : districtList?.count
            break
        default:
            count = 0
            break
        }
        return count!
    }
    
    // MARK: - UIPickerViewDelegate
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var titleLabel: UILabel? = view as? UILabel
        if titleLabel == nil {
            titleLabel = UILabel.init()
            titleLabel?.font = UIFont.systemFont(ofSize: 16)
            titleLabel?.textColor = (style?.pickerTextColor)!
            titleLabel?.textAlignment = .center
            titleLabel?.adjustsFontSizeToFitWidth = true
        }
        switch component {
        case 0:
            let province = provinceList.object(at: row) as! NSDictionary
            titleLabel?.text = province.object(forKey: "_name") as? String
            break
        case 1:
            if (cityList?.count)! > 0 {
                let city = cityList?.object(at: row) as! NSDictionary
                titleLabel?.text = city.object(forKey: "_name") as? String
            }
            break
        case 2:
            if (districtList?.count)! > 0 {
                let dict = districtList?.object(at: row) as? NSDictionary
                titleLabel?.text = dict?.object(forKey: "_name") as? String
            }
            break
        default:
            break
        }
        return titleLabel!
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            let province = provinceList.object(at: row) as! NSDictionary
            self.cityList = province.object(forKey: "city") as? NSArray
            pickerView.reloadComponent(1)
            selectFirstRowInComponent(component: 1, forItems: self.cityList)
            
            if self.cityList != nil && (self.cityList?.count)! > 0 {
                let city = self.cityList?.firstObject as? NSDictionary
                let district = city?.object(forKey: "district") as AnyObject
                
                if district.isKind(of: NSArray.classForCoder()) {
                    self.districtList = district as? NSArray
                } else {
                    self.districtList = NSArray.init(array: district as! NSArray)
                }
                pickerView.reloadComponent(2)
                selectFirstRowInComponent(component: 2, forItems: self.districtList)
                
                self.selectedCity = city
                self.selectedDistrict = self.districtList?.firstObject as? NSDictionary
            } else {
                self.districtList = nil
                pickerView.reloadComponent(2)
                self.selectedCity = nil
                self.selectedDistrict = nil
            }
            self.selectedProvince = province
            break
        case 1:
            if self.cityList != nil && (self.cityList?.count)! > 0 {
                let city = self.cityList?.object(at: row) as! NSDictionary
                let district = city.object(forKey: "district") as AnyObject
                
                if district.isKind(of: NSArray.classForCoder()) {
                    self.districtList = district as? NSArray
                } else {
                    self.districtList = NSArray.init(array: district as! NSArray)
                }
                pickerView.reloadComponent(2)
                selectFirstRowInComponent(component: 2, forItems: self.districtList)
                
                self.selectedCity = city
                self.selectedDistrict = self.districtList?.firstObject as? NSDictionary
            }
            break
        case 2:
            if self.districtList != nil && (self.districtList?.count)! > 0 {
                self.selectedDistrict = self.districtList?.object(at: row) as? NSDictionary
            }
            break
        default:
            break
        }
    }
    
    func selectFirstRowInComponent(component: Int, forItems items: NSArray?) {
        if items != nil && (items?.count)! > 0 {
            self.pickerView.selectRow(0, inComponent: component, animated: true)
        }
    }
        
    // MARK: - Button events
    func cancelButtonClicked() {
        dismiss()
    }
    
    func doneButtonClicked() {
        dismiss()
        
        let provinceName: String = selectedProvince?.object(forKey: "_name") as! String
        var cityName: String? = selectedCity?.object(forKey: "_name") as? String
        if cityName == "市辖区" || cityName == "县" || cityName == nil {
            cityName = ""
        }
        let districtName: String = (selectedDistrict?.object(forKey: "_name") == nil) ? "" : (selectedDistrict?.object(forKey: "_name") as! String)
        let region = String.init(format: "%@%@%@", provinceName, cityName!, districtName)
        self.delegate?.picker?(picker: self, didSelectRegion: region)
    }
    
    // MARK: - Show & Dismiss
    
    func show() {
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow?.addSubview(self)
        
        UIView.animate(withDuration: 0.25) { 
            self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            self.contentView.frame = CGRect.init(x: 0,
                                                 y: self.bounds.size.height - (self.style?.contentHeight)!,
                                                 width: self.pickerWidth,
                                                 height: (self.style?.contentHeight)!)
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.25, animations: { 
            self.backgroundColor = UIColor.init(white: 0, alpha: 0)
            self.contentView.frame = CGRect.init(x: 0,
                                                 y: self.bounds.size.height,
                                                 width: self.pickerWidth,
                                                 height: (self.style?.contentHeight)!)
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
}
