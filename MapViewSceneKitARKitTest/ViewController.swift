//
//  ViewController.swift
//  MapViewSceneKitARKitTest
//
//  Created by Alexander Freas on 11.07.17.
//  Copyright © 2017 Alexander Freas. All rights reserved.
//
import CoreGraphics
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
	
	func degreesValue() -> CGFloat {
		return self * 180.0/CGFloat.pi
	}
}

class ViewController: UIViewController, ARSCNViewDelegate {
	
	let startingPoint = CLLocationCoordinate2D(latitude: 48.8589507,longitude: 2.2775172)
	var session = ARSession()
	var sceneView: ARSCNView!
	var locationManager: CLLocationManager!
	var mapView: ARMapView = {
		let map = ARMapView()
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
	
	lazy var tapGesture: UITapGestureRecognizer = {
		let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
		return tap
	}()
	
	@objc func didTap(gesture: UITapGestureRecognizer) {
		let tapPoint = gesture.location(in: view)
		
		print("tap: \(tapPoint)")
		let coordinate = mapView.convert(tapPoint, toCoordinateFrom: view)
		let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 500.0, pitch: 45.0, heading: 0.0)
		mapView.setCamera(camera, animated: true)
		
	}
	
    var currentPitch: CGFloat = 45.0
	
    var distance: CLLocationDistance = 500.0
    @objc func decreasePitch() {
        
    }
    
    @objc func increasePitch() {
        
//        mapCamera.pitch += 10
        
        
//        let distance1 = 500 + mapCamera.altitude
//        let distance = 500 / Double(tan(currentPitch.radiansValue()))
//
		let mapPoint = MKMapPointForCoordinate(startingPoint)
		print("map point: \(mapPoint)")
        let coord = locationWithBearing(bearing: 0.0, distanceMeters: Double(distance), origin: startingPoint)
        let actualDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(coord), MKMapPointForCoordinate(startingPoint))
//        print("actual distance: \(actualDistance)")
        let camera = MKMapCamera(lookingAtCenter: coord, fromEyeCoordinate: startingPoint, eyeAltitude: 100.0)
        currentPitch -= 5.0
        distance -= 100
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
        
        view.addGestureRecognizer(tapGesture)
        
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
		mapCamera.centerCoordinate = startingPoint
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

