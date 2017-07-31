//
//  ViewController.swift
//  TestRegionCN
//
//  Copyright © 2017年 mrarronz. All rights reserved.
//

import UIKit
import RegionCN

class ViewController: UIViewController, RegionPickerDelegate {

    @IBOutlet weak var regionLabel: UILabel!
    
    var pickerView: RegionPickerView {
        let picker = RegionPickerView.init(delegate: self)
        return picker
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func selectRegionButtonClicked(_ sender: Any) {
        pickerView.show()
    }
    
    func picker(picker: RegionPickerView, didSelectRegion region: String?) {
        regionLabel.text = region
    }
}

