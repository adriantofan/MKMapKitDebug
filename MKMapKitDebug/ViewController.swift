//
//  ViewController.swift
//  MKMapKitDebug
//
//  Created by Adrian Tofan on 20/07/2016.
//  Copyright © 2016 tofan.co. All rights reserved.
//

import Cocoa
import MapKit

class ViewController: NSViewController {

  @IBOutlet weak var mapView: MKMapView!
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate  = self
    print(mapView.centerCoordinate)

    // Do any additional setup after loading the view.
  }
  func paste(sender:AnyObject){
    let pasteboard = NSPasteboard.generalPasteboard()
    let str = pasteboard.stringForType(NSPasteboardTypeString)
    print(str)
  }
  
  override var representedObject: AnyObject? {
    didSet {
    // Update the view, if already loaded.
    }
  }
}
extension ViewController : MKMapViewDelegate{

}

