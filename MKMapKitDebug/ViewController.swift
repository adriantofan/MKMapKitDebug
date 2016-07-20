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
  var points:[MKPointAnnotation] = []
  @IBOutlet weak var mapView: MKMapView!
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate  = self
    print(mapView.centerCoordinate)

    // Do any additional setup after loading the view.
  }
  @IBAction func clear(sender:AnyObject){
    mapView.removeOverlays(mapView.overlays)
    mapView.removeAnnotations(mapView.annotations)
  }

  func paste(sender:AnyObject){
    let pasteboard = NSPasteboard.generalPasteboard()
    if let str = pasteboard.stringForType(NSPasteboardTypeString){
      let matches = matchesForRegexInText("(\\d+.\\d+)", text: str)
      var values = matches
        .map({ ($0 as NSString).doubleValue})
        .reduce([], combine: { (pairs:[(Double,Double)], v) -> [(Double,Double)] in
            if let last = pairs.first {
              let (lat,lon) = last
              if lon.isNaN {
                return [(lat,v)] + pairs[1 ..< pairs.count]
              } else {
                return [(v,Double.NaN)] + pairs
              }
            }
            return [(v,Double.NaN)] + pairs
          })
        .map({ (pair) -> CLLocationCoordinate2D in
          let (lat, lon) = pair
          return CLLocationCoordinate2DMake(lat, lon)
        })
      if values.count == 1 {
        let coordinate = values[0]
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(points.count)"
        annotation.subtitle = "\(coordinate.latitude),\(coordinate.longitude)"
        points.append(annotation)
        mapView.addAnnotation(annotation)
        mapView.centerCoordinate = annotation.coordinate
      } else if  values.count > 1{
        let polyline = MKPolyline(coordinates: &values, count: values.count)
        mapView.addOverlay(polyline)
        mapView.visibleMapRect =  mapView.mapRectThatFits(polyline.boundingMapRect)
      }
    }
  }
  
  override var representedObject: AnyObject? {
    didSet {
    // Update the view, if already loaded.
    }
  }
}
extension ViewController : MKMapViewDelegate{
 func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    if let polyline = overlay as? MKPolyline {
      let r =  MKPolylineRenderer(polyline: polyline)
      r.strokeColor = NSColor.redColor()
      r.fillColor = NSColor.whiteColor()
      r.lineWidth = 3
      return r
    }
    return MKOverlayRenderer(overlay: overlay)
  }

 func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if let pointAnnotation = annotation as? MKPointAnnotation {
      let v = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "point")
      v.canShowCallout = true
      return v
    }
    return nil
  }
}

func matchesForRegexInText(regex: String, text: String) -> [String] {
  var result = [String]()
  do {
    let regex = try NSRegularExpression(pattern: regex, options: [])
    let nsString = text as NSString
    regex.enumerateMatchesInString(text, options: [], range: NSMakeRange(0, nsString.length), usingBlock: { (match, flag, stopPtr) in
      if match!.range.length == 0 {
        return
      }
      for i in 1..<match!.numberOfRanges {
        result.append(nsString.substringWithRange(match!.rangeAtIndex(i)))
      }
    })
  } catch let error as NSError {
    print("invalid regex: \(error.localizedDescription)")
  }
  return result
}
