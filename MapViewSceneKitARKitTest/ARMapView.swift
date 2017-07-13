import Foundation
import UIKit
import ARKit
import MapKit

extension CGFloat {
	
	func radiansValue() -> CGFloat {
		return self * CGFloat.pi/180.0
	}
	
	func degreesValue() -> CGFloat {
		return self * 180.0/CGFloat.pi
	}
}

class ARMapView: MKMapView {
	
	var session = ARSession()
	var locationManager: CLLocationManager!
	
	override var centerCoordinate: CLLocationCoordinate2D {
		didSet {
			if startingPoint == nil {
				startingPoint = centerCoordinate
			}
		}
	}
	
	var startingPoint: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 52.5300866,longitude:13.4304882)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		configureMap()
		configureARSession()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func startARSession() {
		session.run(ARWorldTrackingSessionConfiguration())
	}
	
	func stopARSession() {
		session.pause()
	}
	
	func configureARSession() {
		session.delegate = self
	}
	
	func configureMap() {
		showsUserLocation = true
		delegate = self
		mapType = .satelliteFlyover
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

extension ARMapView: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		
	}
}

extension ARMapView: ARSessionDelegate {
	func session(_ session: ARSession, didUpdate frame: ARFrame) {
		
		let altitudeScale = 5000.0
		let minimumAltitude = 100.0
		let travelledDistanceScale: Float = 1000.0
		
		guard let startingPoint = self.startingPoint else { return }
		
		let pitch = CGFloat(frame.camera.eulerAngles.x)
		guard pitch != 0.0 else { return }
		let cameraTransform = frame.camera.transform
		let degreesPitch = pitch.degreesValue()+90
		let radiansHeading = CGFloat(session.currentFrame!.camera.eulerAngles.y)
		
		var translationAdvanced = sqrt(pow(frame.camera.transform.columns.3.z, 2.0) + pow(cameraTransform.columns.3.y, 2.0))
		
		if cameraTransform.columns.3.z + cameraTransform.columns.3.y < 0 {
			translationAdvanced = -translationAdvanced
		}
		let altitude: Double = max(altitudeScale * Double(translationAdvanced) + minimumAltitude, minimumAltitude)
		
		let travelledPointDistance = sqrt(pow(session.currentFrame!.camera.transform.columns.3.z, 2.0) + pow(session.currentFrame!.camera.transform.columns.3.x, 2.0))
		let travelledMeters: Double = Double(travelledPointDistance * travelledDistanceScale)
		
		
		let eyeCoordinate = locationWithBearing(bearing: Double(-radiansHeading), distanceMeters: travelledMeters, origin: startingPoint)
		let coordinateDistance = -Double(tan(degreesPitch.radiansValue())) * altitude
		print("Coordinate distance: \(coordinateDistance)")
		let newCoordinate = locationWithBearing(bearing: Double(-radiansHeading), distanceMeters: coordinateDistance, origin: eyeCoordinate)
		
		
		
		let camera = MKMapCamera(lookingAtCenter: newCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: Double(altitude))
//		camera.pitch = degreesPitch
		
		setCamera(camera, animated: false)
	}
}
