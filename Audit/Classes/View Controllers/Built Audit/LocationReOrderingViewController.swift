//
//  LocationReOrderingViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 15/01/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class LocationReOrderingViewController: UIViewController {
    //MARK: Variables & Outlets
    var arrLocationList = [LocationModel]()
    var intAuditId = Int()
    var intCountryId = Int()
    
    @IBOutlet weak var btn_Submit: UIButton!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var colView_Order: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(actionLongPressGesture(gesture:)))
        gestureRecognizer.minimumPressDuration = 0.2
        colView_Order!.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        arrLocationList = obSqlite.getLocationList(isModified: AuditStatus.Pending, auditId: intAuditId)
        colView_Order.reloadData()
    }
    
    @objc func actionLongPressGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = self.colView_Order.indexPathForItem(at: gesture.location(in: self.colView_Order)) else {
                break
            }
            colView_Order.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            colView_Order.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            //break
        case .ended:
            colView_Order.endInteractiveMovement()
           // break
        default:
           colView_Order.cancelInteractiveMovement()
           // break
        }
    }
    

    // MARK: - BUtton Actions:
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Submit(_ sender: Any) {
        
        var strLocationId = String()
        let strOrderId = "1,2,3"
        
        var arrLocationTemp = [LocationModel]()
        
        for i in 0..<arrLocationList.count {
            arrLocationTemp.append(arrLocationList[(arrLocationList.count - 1) - i])
        }
        
        for items in arrLocationTemp {
        //for items in arrLocationTemp.reversed() {
       // for (i, items) in arrLocationTemp.enumerated() {
            strLocationId = String(format: "%d,%@",  items.locationId! , strLocationId)
           // strOrderId = String(format: "%d,%@", i + 1, strOrderId)
            //print("Lcoation Name = \(items.locationName!)")
        }
       
        if strLocationId.count > 1 {
            strLocationId = String(strLocationId.dropLast())
        }
        //print("strLocationId= \(strLocationId)")
        
        let dictP = MF.initializeDictWithUserId()
        dictP.setValue(strLocationId, forKey: "location_id")
        dictP.setValue(strOrderId, forKey: "order_id")
        dictP.setValue(intAuditId, forKey: "audit_id")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.LocationArrange, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                
                self.executeUIProcess({
                    let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "BusinessCategoryViewController") as! BusinessCategoryViewController
                    vc.intAuditId = self.intAuditId
                    vc.intCountryId = self.intCountryId
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            }
        }
    }
}

extension LocationReOrderingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 30), height: DeviceType.IS_PHONE ? 40 : 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return arrLocationList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuiltLocationCell", for: indexPath) as! BuiltLocationCell
        if arrLocationList.count > 0 {
          cell.index = indexPath.row
          cell.lbl_Name.text = String(format: "%@",  arrLocationList[indexPath.row].locationName!)
          //print("index: =\(indexPath.row), Name = \(arrLocationList[indexPath.row].locationName!), id = \(arrLocationList[indexPath.row].locationId!)")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {  }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let src = arrLocationList[sourceIndexPath.row]
        arrLocationList.remove(at: sourceIndexPath.row)
        arrLocationList.insert(src, at: destinationIndexPath.row)
        
        self.colView_Order.reloadData()
    }
}


