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
}

public protocol RegionPickerDelegate : class {
    func picker(picker: RegionPickerView, didSelectProvince province:Province?, city: City?, district: NSDictionary?)
}

public class RegionPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    public var style: PickerViewStyle {
        let style = PickerViewStyle.init()
        style.toolBarHeight = 44
        style.contentHeight = 264
        style.pickerHeight = 220
        style.buttonWidth = 70
        return style
    }
    
    let pickerWidth = UIScreen.main.bounds.size.width
    
    var delegate: RegionPickerDelegate?
    
    private var provinceList: NSArray {
        let items = RegionHelper.shared.provincesXMLArray
        return items
    }
    
    private var cityList: NSArray?
    
    private var districtList: NSArray?
    
    private var selectedProvince: Province?
    
    private var selectedCity: City?
    
    private var selectedDistrict: NSDictionary?
    
    // MARK: - Init UI
    
    var pickerView: UIPickerView {
        let pickerView = UIPickerView.init(frame: CGRect.init(x: 0, y: style.toolBarHeight!, width: pickerWidth, height: style.pickerHeight!))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        return pickerView
    }
    
    var contentView: UIView {
        let contentView = UIView.init(frame: CGRect.init(x: 0,
                                                         y: self.bounds.size.height - style.contentHeight!,
                                                         width: pickerWidth,
                                                         height: style.contentHeight!))
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(toolbar)
        contentView.addSubview(pickerView)
        return contentView
    }
    
    var toolbar: UIToolbar {
        
        let toolBar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: pickerWidth, height: style.toolBarHeight!))
        toolBar.barTintColor = UIColor.init(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        
        let cancelButtonItem = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonClicked))
        let doneButtonItem = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(doneButtonClicked))
        let flexButtonItem = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action:nil)
        
        toolBar.items = [flexButtonItem, cancelButtonItem, doneButtonItem]
        for buttonItem in toolBar.items! {
            buttonItem.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.init(red: 0, green: 122/255, blue: 1.0, alpha: 1.0)], for: .normal)
        }
        return toolBar
    }
    
    // MARK: - Init
    
    public init(delegate: RegionPickerDelegate) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0)
        self.addSubview(contentView)
        self.delegate = delegate
        
        // init default data
        let province = provinceList.firstObject as! Province
        self.cityList = City.mj_objectArray(withKeyValuesArray: province.city)
        let city = self.cityList?.firstObject as! City
        if (city.district as AnyObject).isKind(of: NSArray.classForCoder()) {
            self.districtList = city.district as? NSArray
        } else {
            self.districtList = NSArray.init(array: city.district as! NSArray)
        }
        self.selectedProvince = province
        self.selectedCity = city
        self.selectedDistrict = self.districtList?.firstObject as? NSDictionary
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            titleLabel?.textColor = UIColor.darkGray
            titleLabel?.textAlignment = .center
            titleLabel?.adjustsFontSizeToFitWidth = true
        }
        switch component {
        case 0:
            let province = provinceList.object(at: row) as! Province
            titleLabel?.text = province.provinceName
            break
        case 1:
            if (cityList?.count)! > 0 {
                let city = cityList?.object(at: row) as! City
                titleLabel?.text = city.cityName
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
            let province = provinceList.object(at: row) as! Province
            self.cityList = City.mj_objectArray(withKeyValuesArray: province.city)
            pickerView.reloadComponent(1)
            selectFirstRowInComponent(component: 1, forItems: self.cityList)
            
            if self.cityList != nil && (self.cityList?.count)! > 0 {
                let city = self.cityList?.firstObject as! City
                if (city.district as AnyObject).isKind(of: NSArray.classForCoder()) {
                    self.districtList = city.district as? NSArray
                } else {
                    self.districtList = NSArray.init(object: city.district!)
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
                let city = self.cityList?.object(at: row) as! City
                if (city.district as AnyObject).isKind(of: NSArray.classForCoder()) {
                    self.districtList = city.district as? NSArray
                } else {
                    self.districtList = NSArray.init(object: city.district!)
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
        self.delegate?.picker(picker: self, didSelectProvince: selectedProvince, city: selectedCity, district: selectedDistrict)
    }
    
    // MARK: - Show & Dismiss
    
    func show() {
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow?.addSubview(self)
        
        UIView.animate(withDuration: 0.25) { 
            self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            self.contentView.frame = CGRect.init(x: 0,
                                                 y: self.bounds.size.height - self.style.contentHeight!,
                                                 width: self.pickerWidth,
                                                 height: self.style.contentHeight!)
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.25, animations: { 
            self.backgroundColor = UIColor.init(white: 0, alpha: 0)
            self.contentView.frame = CGRect.init(x: 0,
                                                 y: self.bounds.size.height,
                                                 width: self.pickerWidth,
                                                 height: self.style.contentHeight!)
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(self.contentView)
        print(self.pickerView)
        print(self.toolbar)
    }
}
