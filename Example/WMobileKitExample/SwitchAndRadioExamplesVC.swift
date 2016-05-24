//
//  SwitchAndRadioExamplesVC.swift
//  WMobileKitExample

import Foundation
import WMobileKit

public class SwitchAndRadioExamplesVC: WSideMenuContentVC {
    let switch1 = WSwitch()
    let switch2 = WSwitch(false)
    
    let switchLabel1 = UILabel()
    let switchLabel2 = UILabel()
    
    @IBOutlet var storyboardSwitch: WSwitch!
    @IBOutlet var storyboardLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(switch1)
        switch1.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(210)
        }
        switch1.tag = 1
        
        view.addSubview(switchLabel1)
        switchLabel1.snp_makeConstraints { (make) in
            make.centerY.equalTo(switch1)
            make.right.equalTo(switch1.snp_left).offset(-10)
            make.left.equalTo(view).offset(10)
        }
        switchLabel1.text = "On"
        switchLabel1.textAlignment = .Right
        
        view.addSubview(switch2)
        switch2.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(switch1.snp_bottom).offset(10)
        }
        switch2.tag = 2
        
        view.addSubview(switchLabel2)
        switchLabel2.snp_makeConstraints { (make) in
            make.centerY.equalTo(switch2)
            make.right.equalTo(switch2.snp_left).offset(-10)
            make.left.equalTo(view).offset(10)
        }
        switchLabel2.text = "Off"
        switchLabel2.textAlignment = .Right
        
        view.layoutIfNeeded()
        
        switch1.addTarget(self, action: #selector(SwitchAndRadioExamplesVC.switchValueChanged(_:)), forControlEvents: .ValueChanged)
        switch2.addTarget(self, action: #selector(SwitchAndRadioExamplesVC.switchValueChanged(_:)), forControlEvents: .ValueChanged)
    }
    
    @IBAction func storyboardSwitchValueChanged(sender: WSwitch) {
        storyboardLabel.text = sender.on ? "On" : "Off"
    }
    
    public func switchValueChanged(sender: WSwitch) {
        switch sender.tag {
        case 1:
            switchLabel1.text = sender.on ? "On" : "Off"
        case 2:
            switchLabel2.text = sender.on ? "On" : "Off"
        default:
            break
        }
    }
}