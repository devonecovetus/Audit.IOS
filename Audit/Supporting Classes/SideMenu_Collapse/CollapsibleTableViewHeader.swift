//
//  CollapsibleTableViewHeader.swift
//  ios-swift-collapsible-table-section
//
//  Created by Yong Su on 5/30/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//

import UIKit

protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int)
    func addFolder(section: Int)
}

class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
    
    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    
    let baseView = UIView()
    let titleLabel = UILabel()
    let countLabel = UILabel()
    let addBtn = UIButton()
    let arrowimg = UIImageView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Content View
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(baseView)
        baseView.backgroundColor = UIColor(red: 242/255.0, green: 243/255.0, blue: 245/255.0, alpha: 1.0)
        baseView.frame = CGRect(x: 10, y: 0, width: ScreenSize.SCREEN_WIDTH - 40, height: DeviceType.IS_PHONE ? 40 : 60)
  
        baseView.addSubview(titleLabel)
        titleLabel.textColor = UIColor.black

        titleLabel.frame = CGRect(x: 10, y: 0, width: 220, height: DeviceType.IS_PHONE ? 40 : 60)
        titleLabel.font = UIFont(name: CustomFont.themeFont, size: DeviceType.IS_PHONE ? 17 : 21)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        // Count label
        baseView.addSubview(countLabel)
        countLabel.textColor = UIColor.black
        countLabel.frame = CGRect(x: 245, y: 0, width: 50, height: DeviceType.IS_PHONE ? 40 : 60)
        countLabel.font = UIFont(name: CustomFont.themeFont, size: DeviceType.IS_PHONE ? 17 : 21)
        countLabel.numberOfLines = 0
        countLabel.lineBreakMode = .byWordWrapping
        countLabel.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
       
        // Add Btn
        baseView.addSubview(addBtn)
        addBtn.frame = CGRect(x: 290, y: DeviceType.IS_PHONE ? 5 : 10, width: DeviceType.IS_PHONE ? 36 : 45, height: DeviceType.IS_PHONE ? 36 : 45)
        addBtn.setImage(UIImage.init(named: "ic_plus"), for: .normal)
        addBtn.tintColor = UIColor(red: 249/255.0,  green: 95/255.0, blue: 98/255.0,  alpha: 1.0)

        addBtn.addTarget(self, action: #selector(btn_add), for: .touchUpInside)

//        // Arrow label
        contentView.addSubview(arrowimg)
        arrowimg.image = UIImage.init(named: "left_arrow_icon")
        arrowimg.frame = CGRect(x: baseView.frame.maxX - 40, y: DeviceType.IS_PHONE ? 13 : 17, width: DeviceType.IS_PHONE ? 22 : 26, height: DeviceType.IS_PHONE ? 22 : 26)

        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            countLabel.textAlignment = NSTextAlignment.right
            titleLabel.textAlignment = NSTextAlignment.right
        }
        
        //
        // Call tapHeader when tapping on this header
        //
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleTableViewHeader.tapHeader(_:))))
        setUpLanguageSetting()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpLanguageSetting() {
    }
    
    //MARK: Button Actions:
    @IBAction func btn_add(_ sender: Any) {
        //print("self tag = \(self.tag)")
        delegate?.addFolder(section: section)
    }
    //
    // Trigger toggle section when tapping on the header
    //
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader else {
            return
        }
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setCollapsed(_ collapsed: Bool) {
        //
        // Animate the arrow rotation (see Extensions.swf)
        //
        if collapsed{
            arrowimg.image = UIImage.init(named: "left_arrow_icon")
        } else {
            arrowimg.image = UIImage.init(named: "ic_green_downarrow")
        }
        
       // arrowLabel.rotate(collapsed ? 0.0 : .pi / 2)
    }
}
