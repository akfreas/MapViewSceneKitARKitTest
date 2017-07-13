//
//  ViewController.swift
//  MapViewSceneKitARKitTest
//
//  Created by Alexander Freas on 11.07.17.
//  Copyright © 2017 Alexander Freas. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MapKit

class MyMapCamera: MKMapCamera {
    
    var aPitch: CGFloat!
    override var pitch: CGFloat {
        set(p) {
            self.aPitch = p
        }
        get { return self.aPitch }
    }
    override var altitude: CLLocationDistance {
        set(a) {
            
        }
        get {
            return 0
        }
    }
}

extension MKMapCamera {
    
    
    
    func printDescription() {
        print ("pitch: \(self.pitch) altitude: \(self.altitude) centerCoordinate: \(self.centerCoordinate)")
    }
    
}

extension CGFloat {
    
    func radiansValue() -> CGFloat {
        return self * CGFloat.pi/180.0
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {
	
	let startingPoint = CLLocationCoordinate2D(latitude: 48.8589507,longitude: 2.2775172)
	var session = ARSession()
	var sceneView: ARSCNView!
	var locationManager: CLLocationManager!
	var mapView: MKMapView = {
		let map = MKMapView()
		return map
	}()
	var mapCamera: MKMapCamera = {
		let camera = MKMapCamera()
        
        camera.pitch = 0.0
        camera.altitude = 1000.0
        camera.heading = 0.0
		return camera
	}()
    lazy var increasePitchButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(increasePitch), for: .touchUpInside)
        return button
    }()
    var currentPitch: CGFloat = 1.0
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
    }
    var distance: CLLocationDistance = 500.0
    @objc func decreasePitch() {
        
    }
    
    @objc func increasePitch() {
        
//        mapCamera.pitch += 10
        
        
//        let distance1 = 500 + mapCamera.altitude
//        let distance = 500 / Double(tan(currentPitch.radiansValue()))
//
        let coord = locationWithBearing(bearing: 0.0, distanceMeters: Double(distance), origin: startingPoint)
        let actualDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(coord), MKMapPointForCoordinate(startingPoint))
//        print("actual distance: \(actualDistance)")
        let camera = MKMapCamera(lookingAtCenter: coord, fromEyeCoordinate: startingPoint, eyeAltitude: 100.0)
        currentPitch += 5.0
        distance += 100
//        camera.pitch = 45.0
        camera.printDescription()
        mapView.setCamera(camera, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		sceneView = ARSCNView(frame: .zero, options: nil)
		sceneView.delegate = self
		
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
		
		// Create a new scene
        
        
        
        session.delegate = self
        sceneView.session = session
        view.addSubview(sceneView)
        view.addSubview(mapView)
        increasePitchButton.backgroundColor = .white
        view.addSubview(increasePitchButton)
        increasePitchButton.frame = CGRect(x: 5.0, y: 5.0, width: 44.0, height: 44.0)
		mapView.showsUserLocation = true
		mapView.delegate = self
		mapView.mapType = .satelliteFlyover
//		mapCamera.pitch = 30.0
		mapCamera.centerCoordinate = startingPoint
		mapView.setCamera(mapCamera, animated: true)
		locationManager = CLLocationManager()
		locationManager.requestWhenInUseAuthorization()
		locationManager.delegate = self
		locationManager.desiredAccuracy = 10.0
		locationManager.startUpdatingLocation()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		sceneView.frame = view.bounds
		mapView.frame = view.bounds
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
		
        // Run the view's session
        session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        session.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 100000*5)) {
//
//        }
        
        mapView.setCamera(mapCamera, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension ViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else { return }
		
//		mapView.centerCoordinate = location.coordinate
	}
}
var coordinate: CLLocationCoordinate2D!
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let camera = mapView.camera
        camera.printDescription()
    }
//	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//		mapCamera.centerCoordinate = userLocation.coordinate
//		coordinate = userLocation.coordinate
//		mapView.setCamera(mapCamera, animated: true)
//	}
}

extension ViewController: ARSessionDelegate {
	public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        return
//        print("transform: \(frame.camera.transform)")
////        let pitch = CGFloat(frame.camera.eulerAngles.x * 180.0/Float.pi)
////        mapCamera.altitude
//        let distance = (3000 * sqrt(pow(session.currentFrame!.camera.transform.columns.3.z, 2.0) + pow(session.currentFrame!.camera.transform.columns.3.y, 2.0))) - 500
//        print("distance: \(distance)")
//        mapCamera.pitch = 45.0
//        let bearing = Double(frame.camera.eulerAngles.y) * 180.0/Double.pi
//        print("bearing: \(bearing)")
//
//        mapCamera.altitude = 1000.0
//        mapCamera.heading = bearing
//
//        let angle1 = 90.0 - mapCamera.pitch
//        let pitch = frame.camera.eulerAngles.x
//        guard pitch != 0.0 else { return }
//        print("pitch: \(frame.camera.eulerAngles.x)")
//        let distance1 = CGFloat(mapCamera.altitude) / CGFloat(tan(frame.camera.eulerAngles.x))
//        print("bearing: \(bearing) distance1: \(distance1)")
//        let location = locationWithBearing(bearing: Double(frame.camera.eulerAngles.y), distanceMeters: Double(distance1), origin: startingPoint)
//
//        mapCamera.centerCoordinate = startingPoint
//		mapCamera = MKMapCamera(lookingAtCenter: location, fromDistance: 1000, pitch: 45.0, heading: bearing)
//		mapCamera = MKMapCamera(lookingAtCenter: location, fromEyeCoordinate: startingPoint, eyeAltitude: 1000)
//		mapCamera.pitch = pitch
		
		
		
		
		let distanceX = session.currentFrame!.camera.transform.columns.3.x
		let distanceY = session.currentFrame!.camera.transform.columns.3.z
		
//		let coord = (distanceX, distanceY)
//		print("coord: \(coord)")
//		let pointDistance = sqrt(pow(distanceX, 2.0) + pow(distanceY, 2.0) + pow(session.currentFrame!.camera.transform.columns.3.y, 2.0)) * 1000
//		print("pointDistance: \(pointDistance)")
//		let newLocation = locationWithBearing(bearing: Double(session.currentFrame!.camera.eulerAngles.y), distanceMeters: Double(pointDistance), origin: coordinate)
//		print("new location: \(newLocation)")
//		mapCamera.centerCoordinate = newLocation
		mapCamera.pitch = 45.0
		mapView.setCamera(mapCamera, animated: false)
	}
	
	func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
		let distRadians = distanceMeters / (6372797.6) // earth radius in meters
		
		let lat1 = origin.latitude * Double.pi / 180
		let lon1 = origin.longitude * Double.pi / 180
		
		let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
		let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
		
		return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
	}
	
	
}
