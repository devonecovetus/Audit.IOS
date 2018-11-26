
//
//  Drag_VC.swift
//  Audit
//
//  Created by Mac on 10/23/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class Drag_VC: UIViewController {
    
    //MARK: Outlets:
    @IBOutlet weak var tblView1: DragNDropTableView!
    @IBOutlet weak var tblView2: DragNDropTableView!
    
    var arrItems = ["Car", "Bike", "Moped", "Bicycle", "Truck", "Bus", "Two Wheeler", "Four Wheeler"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)

        // Do any additional setup after loading the view.
        tblView1.strTitle = "Main List"
        tblView1.stickers = arrItems
        tblView2.isEnabled = true
        tblView2.strTitle = "Drag N Drop Objects"
        tblView2.stickers = []
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
