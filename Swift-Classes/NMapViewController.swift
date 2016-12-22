//
//  NMapViewController.swift
//  NMapViewerLib
//
//  Created by YiSeungyoun on 2016. 12. 20..
//
//

import Foundation
import UIKit

private let kApplicationName = "Naver Map Sample"

private let kMyLocationStr = "내위치"
private let kMapModeStr = "지도보기"
private let kClearMapStr = "초기화"
private let KTestModeStr = "테스트"

private let KMapModeStandardStr = "일반지도"
private let KMapModeSatelliteStr = "위성지도"
private let KMapModeTrafficStr = "실시간교통"
private let KMapModeBicycleStr = "자전거지도"

private let kCancelStr = "취소"

private let kMapInvalidCompassValue: Double = -360
private let kClientID = ""


class NMapViewController: UIViewController, UIActionSheetDelegate, NMapViewDelegate, NMapPOIdataOverlayDelegate, MMapReverseGeocoderDelegate, NMapLocationManagerDelegate {
    
    
    var mapView: NMapView!
    var mapPOIdataOverlay: NMapPOIdataOverlay!
    
    @IBOutlet var toolbar: UIToolbar!
    
    func addBottomBar() {
        let locItem = UIBarButtonItem.init(title: kMyLocationStr, style: .plain, target: self, action: #selector(findMyLocation))
        let mapModeItem = UIBarButtonItem.init(title: kMapModeStr, style: .plain, target: self, action: #selector(mapModeAction))
        let clearMapItem = UIBarButtonItem.init(title: kClearMapStr, style: .plain, target: self, action: #selector(clearMap))
        let testModeItem = UIBarButtonItem.init(title: KTestModeStr, style: .plain, target: self, action: #selector(testModeAction))
        
        let items = [locItem, mapModeItem, clearMapItem, testModeItem]
        toolbar.items = items
        toolbar.sizeToFit()
        toolbar.layer.opacity = 0.9
        
    }
    
    func setMapViewVisibleBounds() {
        var frameOfParentView = mapView.superview?.frame
        frameOfParentView?.origin = CGPoint.zero
        
        var boundsVisible = frameOfParentView
        
        if toolbar.isHidden {
            boundsVisible?.size.height -= toolbar.frame.size.height
        }
        if let _boundsVisible = boundsVisible {
            mapView.boundsVisible = _boundsVisible
        }
    }
    
    func setCompassHeadingValue(headingValue: Double) {
        if mapView.isAutoRotateEnabled {
            if headingValue <= kMapInvalidCompassValue {
                mapView.setAutoRotateEnabled(false, animate: true)
            } else {
                mapView.setRotateAngle(Float(headingValue), animate: true)
            }
        }
    }
    
    func stopLocationUpdating() {
        let lm = NMapLocationManager.getSharedInstance()
        if let _lm = lm {
            if _lm.isUpdateLocationStarted() {
                _lm.stopUpdateLocationInfo()
                _lm.setDelegate(nil)
            }
            
            if _lm.isHeadingUpdateStarted() {
                _lm.stopUpdatingHeading()
            }
            
            if mapView.isAutoRotateEnabled {
                self.setCompassHeadingValue(headingValue: kMapInvalidCompassValue)
            }
        }
    }
    
    func findMyLocation() {
        let lm = NMapLocationManager.getSharedInstance()
        if let _lm = lm {
            let isAvailableCompass = _lm.headingAvailable()
            
            if _lm.locationServiceEnabled() == false {
                self.locationManager(_lm, didFailWithError: NMapLocationManagerErrorType.denied)
                return
            }
            
            if _lm.isUpdateLocationStarted() {
                if isAvailableCompass && _lm.isTrackingEnabled() {
                    if mapView.isAutoRotateEnabled {
                        // stop updating location
                        self.stopLocationUpdating()
                    } else {
                        mapView.setAutoRotateEnabled(false, animate: true)
                        // start updating heading
                        _lm.startUpdatingHeading()
                    }
                } else {
                // stop updating location
                self.stopLocationUpdating()
                }
            } else {
                // set delegate
                _lm.setDelegate(self)
                
                // start updating location
                _lm.startContinuousLocationInfo()
            }
            
        }
    }
    
    func clearOverlays() {
        let mapOverlayManager = mapView.mapOverlayManager
        mapOverlayManager?.clearOverlays()
        
        mapPOIdataOverlay = nil
    }
    
    func testPOIdata() {
        clearOverlays()
        
        let mapOverlayManager = mapView.mapOverlayManager
        
        //// create POI data overlay
        let poiDataOverlay = mapOverlayManager?.newPOIdataOverlay()
        
        if let _pathPOIdataOverlay = poiDataOverlay {

        _pathPOIdataOverlay.initPOIdata(3)
        _pathPOIdataOverlay.addPOIitemAtLocation(inUtmk: NPoint.init(x: 349652983, y: 149297368), title: "마커 1", type: NMapPOIflagType(NMapPOIflagTypePin), iconIndex: 0, with: nil)
        _pathPOIdataOverlay.addPOIitemAtLocation(inUtmk: NPoint.init(x: 349652966, y: 149296906), title: "마커 1", type: NMapPOIflagType(NMapPOIflagTypePin), iconIndex: 0, with: nil)
        _pathPOIdataOverlay.addPOIitemAtLocation(inUtmk: NPoint.init(x: 349651062, y: 149296913), title: "마커 2", type: NMapPOIflagType(NMapPOIflagTypePin), iconIndex: 0, with: nil)
        _pathPOIdataOverlay.addPOIitemAtLocation(inUtmk: NPoint.init(x: 349651376, y: 149297750), title: "마커 3", type: NMapPOIflagType(NMapPOIflagTypePin), iconIndex: 0, with: nil)
        _pathPOIdataOverlay.endPOIdata()
        
        _pathPOIdataOverlay.showAllPOIdata()
        }
    }
    
    func testPathData() {
        clearOverlays()
        
        let mapOverlayManager = mapView.mapOverlayManager
        
        // create path POI data overlay
        let pathPOIdataOverlay = mapOverlayManager?.newPOIdataOverlay()
        
        if let _pathPOIdataOverlay = pathPOIdataOverlay {
            _pathPOIdataOverlay.initPOIdata(4)
            
            _pathPOIdataOverlay.addPOIitemAtLocation(inUtmk: NPoint.init(x: 349652983, y: 149297368), title: "출발", type: NMapPOIflagType(NMapPOIflagTypeFrom), iconIndex: 0, with: nil)
            _pathPOIdataOverlay.addPOIitemAtLocation(inUtmk: NPoint.init(x: 349652966, y: 149296906), title: nil, type: NMapPOIflagType(NMapPOIflagTypeNumber), iconIndex: 0, with: nil)
            _pathPOIdataOverlay.addPOIitemAtLocation(inUtmk: NPoint.init(x: 349651062, y: 149296913), title: nil, type: NMapPOIflagType(NMapPOIflagTypeNumber), iconIndex: 1, with: nil)
            _pathPOIdataOverlay.addPOIitemAtLocation(inUtmk: NPoint.init(x: 349651376, y: 149297750), title: "도착", type: NMapPOIflagType(NMapPOIflagTypeTo), iconIndex: 0, with: nil)
            
            _pathPOIdataOverlay.endPOIdata()
        }
        
        let pathData = NMapPathData.init(capacity: 9)
        pathData?.initPathData()
        pathData?.addPathPointLongitude(127.108099, latitude: 37.366034, lineType: .solid)
        pathData?.addPathPointLongitude(127.108088, latitude: 37.366043, lineType: NMapPathLineType(rawValue: 0)!)
        pathData?.addPathPointLongitude(127.107458, latitude: 37.365608, lineType: NMapPathLineType(rawValue: 0)!)
        pathData?.addPathPointLongitude(127.107232, latitude: 37.365608, lineType: NMapPathLineType(rawValue: 0)!)
        pathData?.addPathPointLongitude(127.106904, latitude: 37.365624, lineType: NMapPathLineType(rawValue: 0)!)
        pathData?.addPathPointLongitude(127.105933, latitude: 37.365621, lineType: .dash)
        pathData?.addPathPointLongitude(127.105929, latitude: 37.366378, lineType: NMapPathLineType(rawValue: 0)!)
        pathData?.addPathPointLongitude(127.106279, latitude: 37.366380, lineType: NMapPathLineType(rawValue: 0)!)
        
        pathData?.end()
        
        let pathDataOverlay = mapOverlayManager?.newPathDataOverlay(pathData)
            // add path data with polygon type
            let pathData2 = NMapPathData()
            pathData2.initPathData()
            pathData2.addPathPointLongitude(127.106, latitude: 37.367, lineType: .solid)
            pathData2.addPathPointLongitude(127.107, latitude: 37.367, lineType: NMapPathLineType(rawValue: 0)!)
            pathData2.addPathPointLongitude(127.107, latitude: 37.368, lineType: NMapPathLineType(rawValue: 0)!)
            pathData2.addPathPointLongitude(127.106, latitude: 37.368, lineType: NMapPathLineType(rawValue: 0)!)
            pathData2.end()
            pathDataOverlay?.add(pathData2)
            // set path line style
            let pathLineStyle = NMapPathLineStyle()
            pathLineStyle.pathDataType = .polygon
            pathLineStyle.setLineColorWithRed(0xa0 * 1.0 / 255.0, green: 0x4d * 1.0 / 255.0, blue: 0xd2 * 1.0 / 255.0, alpha: 0xff * 1.0 / 255.0)
            pathLineStyle.fillColor = UIColor.clear
            pathData2.pathLineStyle = pathLineStyle
            // add circle data
            let circleData = NMapCircleData() /* capacity: 1 */
            circleData.initCircleData()
            circleData.addCirclePointLongitude(127.1075, latitude: 37.3675, radius: 50.0)
            circleData.end()
            pathDataOverlay?.add(circleData)
        
            // set circle style
            let circleStyle = NMapCircleStyle()
            circleStyle?.setLineType(.dash)
            circleStyle?.fillColor = UIColor.clear
            circleData.circleStyle = circleStyle
            // show all path data
            pathDataOverlay?.showAllPathData()
        
    }
    
    func testFloatingData() {
        self.clearOverlays()
        let mapOverlayManager = mapView.mapOverlayManager
        // create POI data overlay
        let poiDataOverlay = mapOverlayManager?.newPOIdataOverlay()
        // set POI data
        poiDataOverlay?.initPOIdata(1)
        let poiItem = poiDataOverlay?.addPOIitem(atLocation: NGeoPoint.init(longitude: 126.984, latitude: 37.565), title: "Touch & Drag to Move", type: NMapPOIflagType(NMapPOIflagTypeTo), iconIndex: 0, with: nil)
        // set floating mode
        poiItem?.setPOIflagMode(.touch)
        // hide right button on callout
        poiItem?.hasRightCalloutAccessory = false
        poiDataOverlay?.endPOIdata()
        // select item
        poiDataOverlay?.selectPOIitem(at: 0, moveToCenter: true)
        self.mapPOIdataOverlay = poiDataOverlay
    }
    
    func testAutoRotate() {
        if mapView.isAutoRotateEnabled {
            mapView.isAutoRotateEnabled = false
        }
        else {
            mapView.isAutoRotateEnabled = true
            self.setCompassHeadingValue(headingValue: -45.0)
        }
        self.setMapViewVisibleBounds()
    }
    
    func clearMap() {
        mapView.mapViewMode = .vector
        mapView.mapViewTrafficMode = false
        mapView.mapViewBicycleMode = false
        
        // clear overlays
        self.stopLocationUpdating()
        if mapView.mapOverlayManager.hasMyLocationOverlay() {
            mapView.mapOverlayManager.clearMyLocationOverlay()
        }
        self.clearOverlays()
    }
    
    func mapModeAction() {
        let actionSheet = UIActionSheet.init(title: kMapModeStr, delegate: self, cancelButtonTitle: kCancelStr, destructiveButtonTitle: nil)
        actionSheet.actionSheetStyle = .default
        actionSheet.addButton(withTitle: KMapModeStandardStr)
        actionSheet.addButton(withTitle: KMapModeSatelliteStr)
        if mapView.mapViewTrafficMode {
            actionSheet.addButton(withTitle: "\(KMapModeTrafficStr) Off")
        }
        else {
            actionSheet.addButton(withTitle: "\(KMapModeTrafficStr) On")
        }
        if mapView.mapViewBicycleMode {
            actionSheet.addButton(withTitle: "\(KMapModeBicycleStr) Off")
        }
        else {
            actionSheet.addButton(withTitle: "\(KMapModeBicycleStr) On")
        }
        actionSheet.show(in: self.view)
    }
    
    @objc(actionSheet:clickedButtonAtIndex:) func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        //NSLog(@"actionSheet:%@ clickedButtonAtIndex: %d", [actionSheet title], buttonIndex);
        if (actionSheet.title == kMapModeStr) {
            switch buttonIndex {
            case 1:
                mapView.mapViewMode = .vector
            case 2:
                mapView.mapViewMode = .hybrid
            case 3:
                mapView.mapViewTrafficMode = (!mapView.mapViewTrafficMode)
            case 4:
                mapView.mapViewBicycleMode = (!mapView.mapViewBicycleMode)
            default:
                break
            }
        }
        if (actionSheet.title == KTestModeStr) {
            switch buttonIndex {
            case 1:
                self.testPOIdata()
            case 2:
                self.testPathData()
            case 3:
                self.testFloatingData()
            case 4:
                self.testAutoRotate()
            default:
                break

            }
        }
    }
    
    func testModeAction() {
        let actionSheet = UIActionSheet.init(title: KTestModeStr, delegate: self, cancelButtonTitle: kCancelStr, destructiveButtonTitle: nil)
        actionSheet.actionSheetStyle = .default
        actionSheet.addButton(withTitle: "마커 표시")
        actionSheet.addButton(withTitle: "경로선 표시")
        actionSheet.addButton(withTitle: "직접 지정")
        actionSheet.addButton(withTitle: "지도 회전")
        actionSheet.show(in: self.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create map view
        self.mapView = NMapView(frame: self.view.frame)
        // set delegate to use reverse geocoder API
        mapView.reverseGeocoderDelegate = self
        // set delegate for map view
        mapView.delegate = self
        // set ClientID for Open MapViewer Library
        mapView.setClientId(kClientID)
        self.navigationController!.navigationBar.isTranslucent = false
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.title = kApplicationName
        self.view.addSubview(mapView)
        self.addBottomBar()
        self.view.bringSubview(toFront: toolbar)
        self.setMapViewVisibleBounds()
    }
    
    override func didReceiveMemoryWarning() {
        print("NMapViewController:didReceiveMemoryWarning ...")
        // release cached data in the map view
        mapView.didReceiveMemoryWarning()
        super.didReceiveMemoryWarning()
        // Releases the view if it doesn't have a superview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.viewWillDisappear()
        self.stopLocationUpdating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.viewDidDisappear()
    }
    
    deinit {
        mapView.delegate = nil
    }
    
    func applicationWillSuspend() {
        print("applicationWillSuspend")
    }
    
    func applicationWillTerminate() {
        print("applicationWillTerminate")
    }
    
    // MARK: NMapViewDelegate Method
    
    func onMapView(_ mapView: NMapView!, initHandler error: NMapError!) {
        if error == nil {
            // success
            // set map center and level
            mapView.setMapCenter(NGeoPoint.init(longitude: 126.978371, latitude: 37.5666091), atLevel: 11)
            mapView.setMapEnlarged(true, mapHD: true)
        }
        else {
            // fail
            print("onMapView:initHandler: \(error?.description)")
            let alert = UIAlertView(title: "NMapViewer", message: (error?.description)!, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
            alert.show()
        }

    }
    
    func onMapView(_ mapView: NMapView!, networkActivityIndicatorVisible visible: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = visible
    }
    
    func onMapView(_ mapView: NMapView!, didChangeMapLevel level: Int32) {
        print("onMapView:didChangeMapLevel: \(level)")
    }
    
    func onMapView(_ mapView: NMapView!, didChange status: NMapViewStatus) {
        print("onMapView:didChangedidChange: \(status)")
    }
    
    func onMapView(_ mapView: NMapView!, didChangeMapCenter location: NGeoPoint) {
        print("onMapView:didChangeMapCenter: (\(location.longitude), \(location.latitude))")
    }
    
    func onMapView(_ mapView: NMapView!, handleSingleTapGesture recogniser: UIGestureRecognizer!) {
        toolbar.isHidden = !toolbar.isHidden
        self.setMapViewVisibleBounds()

    }
    
    func onMapViewIsGPSTracking(_ mapView: NMapView) -> Bool {
        return NMapLocationManager.getSharedInstance().isTrackingEnabled()
    }
    
    //pragma mark NMapPOIdataOverlayDelegate
    
    func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay, imageForOverlayItem poiItem: NMapPOIitem, selected: Bool) -> UIImage {
        return NMapViewResource.image(forOverlayItem: poiItem, selected: selected, constraintSize: mapView.viewBounds.size)
    }
    
    @objc(onMapOverlay:anchorPointWithType:) func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay, anchorPointWithType poiFlagType: NMapPOIflagType) -> CGPoint {
        return NMapViewResource.anchorPoint(withType: poiFlagType)
    }
    
    func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay, viewForCalloutOverlayItem poiItem: NMapPOIitem, calloutPosition: UnsafeMutablePointer<CGPoint>) -> UIView? {
        // [TEST] nil을 리턴하면 onMapOverlay:imageForCalloutOverlayItem:... 이 다시 호출됨
        if poiItem.title.characters.count > 10 {
            return nil
        }
        let constraintSize = mapView.bounds.size
        var calloutHitRect = CGRect.init()
        let image = NMapViewResource.image(forCalloutOverlayItem: poiItem, constraintSize: constraintSize, selected: false, imageForCalloutRightAccessory: nil, calloutPosition: calloutPosition, calloutHit: &calloutHitRect)
        
        if poiItem.title.characters.count > 5 {
            if let imageSize = image?.size {
            // [TEST] userInteractionEnabled 값이 YES인 UIView를 리턴하면 터치 이벤트를 직접 처리해야함
            let button = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(imageSize.width), height: CGFloat(imageSize.height)))
            button.setBackgroundImage(image, for: .normal)
            return button
            }
        }
        // [TEST] userInteractionEnabled 값이 NO인 UIView를 리턴하면 선택시 onMapOverlay:imageForCalloutOverlayItem:...이 호출됨
        let calloutView = UIImageView(image: image)
        return calloutView
    }
    
    func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay, imageForCalloutOverlayItem poiItem: NMapPOIitem, constraintSize: CGSize, selected: Bool, imageForCalloutRightAccessory: UIImage, calloutPosition: UnsafeMutablePointer<CGPoint>, calloutHit calloutHitRect: UnsafeMutablePointer<CGRect>) -> UIImage {
        // handle overlapped items
        if !selected {
            // check if it is selected by touch event
            if !poiDataOverlay.isFocusedBySelectItem {
                var countOfOverlappedItems = 1
                let poiData: [NMapPOIitem] = poiDataOverlay.poiData() as! [NMapPOIitem]
                for item: NMapPOIitem in poiData {
                    // skip selected item
                    if item == poiItem {
                        
                    }
                    // check if overlapped or not
                    if item.frame.intersects(poiItem.frame) {
                        countOfOverlappedItems += 1
                    }
                }
                if countOfOverlappedItems > 1 {
                    // handle overlapped items
                    let strText = "\(countOfOverlappedItems) overlapped items for \(poiItem.title)"
                    let alert = UIAlertView(title: "NMapViewer", message: strText, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
                    alert.show()
                    // do not show callout overlay
                    return UIImage()
                }
            }
        }
        return NMapViewResource.image(forCalloutOverlayItem: poiItem, constraintSize: constraintSize, selected: selected, imageForCalloutRightAccessory: imageForCalloutRightAccessory, calloutPosition: calloutPosition, calloutHit: calloutHitRect)
    }
    
    @objc(onMapOverlay:calloutOffsetWithType:) func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay, calloutOffsetWithType poiFlagType: NMapPOIflagType) -> CGPoint {
        return NMapViewResource.calloutOffset(withType: poiFlagType)
    }
    
    func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay, willShowCalloutOverlayItem poiItem: NMapPOIitem) {
        print("onMapOverlay:willShowCalloutOverlayItem: \(poiItem)")
    }
    
    private func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay, didChangeSelectedPOIitemAt index: Int, withObject object: Any) -> Bool {
        print("onMapOverlay:didChangeSelectedPOIitemAtIndex: \(index)")
        return true
    }
    
    private func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay, didDeselectPOIitemAt index: Int, withObject object: Any) -> Bool {
        print("onMapOverlay:didDeselectPOIitemAtIndex: \(index)")
        return true
    }
    
    private func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay, didSelectCalloutOfPOIitemAt index: Int, withObject object: Any) -> Bool {
        print("onMapOverlay:didSelectCalloutOfPOIitemAtIndex: \(index)")
        let poiArray:[NMapPOIitem] = poiDataOverlay.poiData() as! [NMapPOIitem]
        let poiItem: NMapPOIitem = poiArray[index]
        if (poiItem.title != nil) {
            let alert = UIAlertView(title: kApplicationName, message: poiItem.title, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
            alert.show()
        }
        return true
    }
    
    private func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay, didChangePOIitemLocationTo location: NGeoPoint, with poiFlagType: NMapPOIflagType) {
        print("onMapOverlay:didChangePOIitemLocationTo: (\(location.longitude), \(location.latitude))")
        mapView.findPlacemark(atLocation: location)
    }
    
    //pragma mark MMapReverseGeocoderDelegate
    
    func location(_ location: NGeoPoint, didFind placemark: NMapPlacemark!) {
        print("location: \(location.longitude), \(location.latitude) didFindPlaceMark: \(placemark.address)")
        
        if mapPOIdataOverlay != nil {
            let poiItem = mapPOIdataOverlay.poiData()[0] as? NMapPOIitem
            
            if let _poiItem = poiItem {
                _poiItem.title = placemark.address
                mapPOIdataOverlay.selectPOIitem(at: 0, moveToCenter: false)
            }
        }
    }
    
    func location(_ location: NGeoPoint, didFailWithError error: NMapError!) {
        print("location: \(location.longitude), \(location.latitude) didFailWithError: \(error.description)")
    }
    
        
    //pragma mark NMapLocationManagerDelegate
    
    func locationManager(_ locationManager: NMapLocationManager!, didUpdateTo location: CLLocation!) {
        
        let coordinate = location.coordinate
        var myLocation = NGeoPoint.init()
        myLocation.longitude = coordinate.longitude
        myLocation.latitude = coordinate.latitude
        let locationAccuracy = location.horizontalAccuracy
        
        mapView.mapOverlayManager.setMyLocation(myLocation, locationAccuracy: Float(locationAccuracy))
        mapView.setMapCenter(myLocation)
    }
    
    func locationManager(_ locationManager: NMapLocationManager!, didFailWithError errorType: NMapLocationManagerErrorType) {
        
        var message = ""
        
        switch errorType {
        case .unknown:
            break
        case .canceled:
            break
        case .timeout:
            message = "일시적으로 내위치를 확인할 수 없습니다."
            break
        case .denied:
            let currentVersion = Float(UIDevice.current.systemVersion)
            if let _currentVersion = currentVersion {
            if _currentVersion >= 4.0 {
                message = "위치 정보를 확인할 수 없습니다.\n사용자의 위치 정보를 확인하도록 허용하시려면 위치서비스를 켜십시오."
                }
            } else {
                message = "위치 정보를 확인할 수 없습니다."
            }
            break
        case .unavailableArea:
            message = "현재 위치는 지도내에 표시할 수 없습니다."
            break
        case .heading:
            self.setCompassHeadingValue(headingValue: kMapInvalidCompassValue)
            break
            
        default:
            break
        }
        
        if !message.isEmpty {
            let alert = UIAlertView.init(title: kApplicationName, message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        mapView.mapOverlayManager.clearMyLocationOverlay()
    }
    
    func locationManager(_ locationManager: NMapLocationManager!, didUpdate heading: CLHeading!) {
        let headingValue = heading.trueHeading < 0.0 ? heading.magneticHeading : heading.trueHeading
        self.setCompassHeadingValue(headingValue: headingValue)
    }
    
}
