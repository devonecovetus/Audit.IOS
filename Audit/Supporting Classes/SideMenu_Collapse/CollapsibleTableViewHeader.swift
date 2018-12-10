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
   // let arrowLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Content View
        contentView.backgroundColor = UIColor.white
        
        contentView.addSubview(baseView)
        baseView.backgroundColor = UIColor(red: 242/255.0, green: 243/255.0, blue: 245/255.0, alpha: 1.0)
        baseView.frame = CGRect(x: 10, y: 0, width: ScreenSize.SCREEN_WIDTH - 40, height: 60)
        
    //    let marginGuide = contentView.layoutMarginsGuide
        
        // Title label
        baseView.addSubview(titleLabel)
        titleLabel.textColor = UIColor.black
   //     titleLabel.backgroundColor = .red
        //    titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.frame = CGRect(x: 10, y: 0, width: 220, height: 60)
        titleLabel.font = UIFont(name: "OpenSans-Regular", size: 21)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        //      titleLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        //       titleLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        //       titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        //      titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        
        // Count label
        baseView.addSubview(countLabel)
        countLabel.textColor = UIColor.black
   //     countLabel.backgroundColor = .red
        //    titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.frame = CGRect(x: 245, y: 0, width: 50, height: 60)
        countLabel.font = UIFont(name: "OpenSans-Regular", size: 21)
        countLabel.numberOfLines = 0
        countLabel.lineBreakMode = .byWordWrapping
        //      titleLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        //       titleLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        //       titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        //      titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true

        // Add Btn
        baseView.addSubview(addBtn)
        //addBtn.backgroundColor = .red
        //    titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addBtn.frame = CGRect(x: 290, y: 10, width: 40, height: 40)
        
        addBtn.setImage(UIImage.init(named: "ic_plus"), for: .normal)
        addBtn.tintColor = UIColor(red: 249/255.0,
                                   green: 95/255.0,
                                   blue: 98/255.0,
                                   alpha: 1.0)

        addBtn.addTarget(self, action: #selector(btn_add), for: .touchUpInside)

       // addBtn.addTarget(self, action: btn_add, for: .ui)
        //      titleLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        //       titleLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        //       titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        //      titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        
//        // Arrow label
        contentView.addSubview(arrowimg)
       // arrowimg.backgroundColor = UIColor.blue
        arrowimg.image = UIImage.init(named: "left_arrow_icon")
        arrowimg.frame = CGRect(x: baseView.frame.maxX - 40, y: 17, width: 26, height: 26)
 //       arrowimg.translatesAutoresizingMaskIntoConstraints = false
 //       arrowimg.widthAnchor.constraint(equalToConstant: 40).isActive = true
 //       arrowimg.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
 //       arrowimg.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
 //       arrowimg.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true

//        baseView.addSubview(arrowLabel)
//        arrowLabel.textColor = UIColor.white
//        arrowLabel.backgroundColor = UIColor.blue
//        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
//        arrowLabel.widthAnchor.constraint(equalToConstant: 12).isActive = true
//        arrowLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
//        arrowLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
//        arrowLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        
        //
        // Call tapHeader when tapping on this header
        //
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleTableViewHeader.tapHeader(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Button Actions:
    @IBAction func btn_add(_ sender: Any) {
        print("self tag = \(self.tag)")
      //  delegate?.increaseValue(index: index)
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
