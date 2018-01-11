//
//  ViewController.swift
//  Ballistics
//
//  Created by Richard Padgett on 1/3/18.
//  Copyright © 2018 Richard-Padgett. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {
    
    var sockTimer = Timer()
    var weatherTimer = Timer()
    var altitudeTimer = Timer()
    var locationManager = CLLocationManager()
    var heading = CLLocationDegrees()
    var north = CLLocationDegrees()
    var latDelta: CLLocationDegrees = 0.002
    var lonDelta: CLLocationDegrees = 0.002
    var updating = true
    var userToPin = true
    var target: CLLocationCoordinate2D!
    var shooter: CLLocationCoordinate2D!
    var flightpathPolyline = MKGeodesicPolyline()
    var distinMeters : Double = 0
    var distanceYds : Double = 0
    var hypotenuse : Double = 0
    var targetheight : Double = 0
    var altitudeOn = true
    var setPin = false
    var targetIncrement: Int = 1
    
    private var mapBrain = MapBrain()

    @IBOutlet weak var viewBehindStackView: UIView!
    
    @IBOutlet weak var stackViewCenterC: NSLayoutConstraint!
    @IBOutlet weak var windSockRightC: NSLayoutConstraint!
    @IBOutlet weak var stackViewLCenterC: NSLayoutConstraint!
    
    @objc func keyboardDidShow(notification: NSNotification)
    {
        let test : Bool = true
        switch(test)
        {
        case targetBearing.isEditing:
            stackViewCenterC.constant = 0
            stackViewLCenterC.constant = 0
            break
        case targetDistance.isEditing:
            stackViewCenterC.constant = -40
            stackViewLCenterC.constant = -40
            break
        case zeroRange.isEditing:
            stackViewCenterC.constant = -80
            stackViewLCenterC.constant = -80
            break
        case sightHeight.isEditing:
            stackViewCenterC.constant = -120
            stackViewLCenterC.constant = -120
            break
        case ballisticCoefficient.isEditing:
            stackViewCenterC.constant = -160
            stackViewLCenterC.constant = -160
            break
        case weight.isEditing:
            stackViewCenterC.constant = -200
            stackViewLCenterC.constant = -200
            break
        case muzzleVelocity.isEditing:
            stackViewCenterC.constant = -280
            stackViewLCenterC.constant = -280
            break
        case temperature.isEditing:
            stackViewCenterC.constant = -320
            stackViewLCenterC.constant = -320
            break
        case windSpeed.isEditing:
            stackViewCenterC.constant = -360
            stackViewLCenterC.constant = -360
            break
        case windDirection.isEditing:
            stackViewCenterC.constant = -400
            stackViewLCenterC.constant = -400
            break
        case altitude.isEditing:
            stackViewCenterC.constant = -440
            stackViewLCenterC.constant = -440
            break
        default:
            break
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:
            {
                self.view.layoutIfNeeded()
        }) { (animationComplete) in }
    }
    @objc func keyboardDidHide(notification: NSNotification)
    {
        stackViewCenterC.constant = 0
        stackViewLCenterC.constant = 0
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:
            {
                self.view.layoutIfNeeded()
        }) { (animationComplete) in }
    }
    
    @IBOutlet weak var targetBearing: UITextField!
    @IBOutlet weak var targetDistance: UITextField!
    @IBOutlet weak var zeroRange: UITextField!
    @IBOutlet weak var sightHeight: UITextField!
    @IBOutlet weak var ballisticCoefficient: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var muzzleVelocity: UITextField!
    @IBOutlet weak var temperature: UITextField!
    @IBOutlet weak var windSpeed: UITextField!
    @IBOutlet weak var windDirection: UITextField!
    @IBOutlet weak var altitude: UITextField!
    
    
    var menuIsVisible = false
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    @IBOutlet weak var windSockTopC: NSLayoutConstraint!
    
    
    func menuButton()
    {
        if(!menuIsVisible)
        {
            
            leadingC.constant = viewBehindStackView.bounds.maxX + 36
            windSockRightC.constant = 2
            windSockTopC.constant = 42
            //trailingC.constant = -150
            
            menuIsVisible = true
        }
        else
        {
            leadingC.constant = 0
            windSockRightC.constant = 42
            windSockTopC.constant = 2
            //trailingC.constant = 0
            
            menuIsVisible = false
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:
            {
                self.view.layoutIfNeeded()
        }) { (animationComplete) in }
    }
    @IBAction func menuButtonTapped(_ sender: Any)
    {
        menuButton()
    }
    
   
    // drop target point and clear old targets
    @IBAction func lowerBarButtonAction(_ sender: UIButton)
    {
        
        if let title = sender.currentTitle
        {
            mapBrain.performOperation(buttonTitle: title)
        }
        
        
        
        
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        target = nil
        mapView.remove(flightpathPolyline)
        
        if (!(targetDistance.text?.isEmpty)!)
        {
            let targetDistString = self.targetDistance.text as! String
            guard let dist : Double = ((Double(targetDistString))! * 0.0009144)
                else
            {
                let alert = UIAlertController(title: "Distance Setting", message: "Enter a number for distance in menu.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: 
                {
                    action in
                    if(self.leadingC.constant == 0 )
                        {
                            self.menuButton()
                        }
                }))
                //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
                
                return
            }
            let newcoord : CLLocationCoordinate2D = shooter.translate(bearing: self.mapView.camera.heading, distanceKm: dist)
            
            let pressPin = TargetPin(title: "Target", locationName: "TestLocation", discipline: "Target", coordinate: newcoord)
            
            let loc = CLLocation(latitude: newcoord.latitude, longitude: newcoord.longitude)
            
            mapView.addAnnotation(pressPin)
        }
        else{
            let alert = UIAlertController(title: "Distance Setting", message: "Enter a number for distance in menu.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler:
            {
                action in
                if(self.leadingC.constant == 0 )
                    {
                        self.menuButton()
                    }
            }))
            //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    @IBOutlet weak var degreeLabel: UILabel!
    
    
    
    @IBOutlet weak var windSock: UIButton!
    //====================================================================
    //Control The degrees that the wind Sock Points
    @objc func setWindSock(){
        
         self.degreeLabel.text = String(describing: Int(GlobalSelectionModel.trueNorth))
        UIView.animate(withDuration: 0.5)
        {
            self.windSock.transform = CGAffineTransform(rotationAngle: CGFloat(((WeatherData.GlobalData.degrees -
                self.mapView.camera.heading) * Double.pi)/180))
            
            GlobalSelectionModel.trueNorth  = Double(self.mapView.camera.heading)
           
            //self.compass.setNeedsDisplay()
          //  print("Camera dir: " + String(self.mapView.camera.heading))
            
//            self.windSock.transform = CGAffineTransform(rotationAngle: CGFloat((self.north)))
            
            
              //  self.northLabel.text = String(self.north)
            
            //self.mapView.camera.heading) * Double.pi)/180))
        }
        
        
        
        if(WeatherData.GlobalData.windspeed != "NaN"){
            if(GlobalSelectionModel.imperial){
                //speed.text = String(format: "%.2lf", Double(JSONWeatherData.GlobalData.windspeed)!) + " mph"
                //degree.text = String(format: "%.0lf", Double(JSONWeatherData.GlobalData.degrees)) + " \u{00B0}"
            }
            else{
                //speed.text = String(format: "%.2lf", (Double(JSONWeatherData.GlobalData.windspeed)!) * 1.60934) + " kph"
                //degree.text = String(format: "%.0lf", Double(JSONWeatherData.GlobalData.degrees)) + " \u{00B0}"
            }

        }
    }
    
    // Map View outlet and Long Press Action
    // *************************************************************************
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func longPressMap(_ sender: UILongPressGestureRecognizer)
    {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        target = nil
        mapView.remove(flightpathPolyline)
        
        let pressPoint = sender.location(in: mapView)
        let pressCoordinate = mapView.convert(pressPoint, toCoordinateFrom: mapView)
        
        let pressPin = TargetPin(title: "Target", locationName: "TestLocation", discipline: "Target", coordinate: pressCoordinate)
        
    
        mapView.addAnnotation(pressPin)
    }
    
    // View Did Load
    // *************************************************************************
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //set map delegate
        mapView.delegate = self
 
        //Set initial location to Greenville SC
        let initialLocation = CLLocation(latitude: 34.8526, longitude: -82.3940)
        
       
        // enable location services
        enableLocationServices()
        
        // get weather timer
        getWeatherForCoordinate()
        weatherTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(ViewController.getWeatherForCoordinate), userInfo: nil, repeats: true)
        
        // get altitude timer
        getElevationForCoordinate()
        altitudeTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(ViewController.getElevationForCoordinate), userInfo: nil, repeats: true)
        
        // Set wind Sock interval
        setWindSock()
        sockTimer = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(ViewController.setWindSock), userInfo: nil, repeats: true)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        
    }
    
    // Memory Warning
    // *************************************************************************
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }

    // Center Map
    // *************************************************************************
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation)
    {
        print("Entered Center Map on Location")
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // *************************************************************************
    // Location Manager Code ***************************************************
    // *************************************************************************
    
    // Manage Location Services
    // *************************************************************************
    func enableLocationServices()
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            self.mapView.showsUserLocation = true;
            break
            
        case .restricted, .denied:
            // Disable location features
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            self.mapView.showsUserLocation = true;
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            print("location enabled")
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            locationManager.awakeFromNib()
            self.mapView.showsUserLocation = true;
            break
        }
    }
    
    // Did Update Heading
    // *************************************************************************
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //print("Entered did Update Heading")
        heading = newHeading.trueHeading - newHeading.magneticHeading
        
        north = newHeading.trueHeading
        
        self.mapView.camera.heading = newHeading.magneticHeading
        
       // self.mapView.setCamera(mapView.camera, animated: true)
    }
    
    // Did Update Locations
    // *************************************************************************
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //print("Entered did update locations")
        
        // center map on user
        centerMapOnLocation(location: locations[0])
        
        // draw polyline from shooter to target
        drawShotLine(location: locations[0])
    }
    
    func drawShotLine(location: CLLocation)
    {
        let userLocation: CLLocation = location
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        if(updating && userToPin)
        {
            shooter = CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!,
                                             longitude: (locationManager.location?.coordinate.longitude)!)
        }
        
        if(target != nil)
        {
            mapView.remove(flightpathPolyline)
            
            var coordinate: [CLLocationCoordinate2D] = [shooter, target]
            
            flightpathPolyline = MKGeodesicPolyline(coordinates: &coordinate, count: 2)
            
            mapView.add(flightpathPolyline)
            
            let loc1 = CLLocation(latitude: shooter.latitude , longitude: shooter.longitude)
            let loc2 = CLLocation(latitude: target.latitude, longitude: target.longitude)
            
            distinMeters = loc1.distance(from: loc2)
           
            
            //resetDistance()
            
            //self.mapView.setRegion(region, animated: true)
        }
    }
    
    // URLRequest Get Elevation Google
    // *************************************************************************
    @objc func getElevationForCoordinate()
    {
        guard let coordinate = locationManager.location?.coordinate
            else
        {
            return
        }
        WeatherData.GlobalData.setUrl(userLat: String(coordinate.latitude),userLon: String(coordinate.longitude))
        
        let urlRequest = URLRequest(url: WeatherData.GlobalData.alturl!)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest)
        {
            (data, response, error) in
            // check for any errors
            guard error == nil
                else
            {
                print("error calling GET on " + String(describing: urlRequest))
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data
                else
            {
                print("Error: did not receive elevation data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do
            {
                guard let elevation = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers)
                    as? [String: Any]
                    else
                {
                    print("error trying to convert elevation data to JSON")
                    return
                }
                
                WeatherData.GlobalData.initElevation(json: elevation as [String: AnyObject])
                print("Altitude: " + String(WeatherData.GlobalData.altitude))
                
            }
            catch
            {
                print("error trying to convert data to JSON")
                WeatherData.GlobalData.initAltInvalid()
                return
            }
        }
        task.resume()
    }
    
    // URLRequest Get Weather Weather API
    // *************************************************************************
    @objc func getWeatherForCoordinate()
    {
        guard let coordinate = locationManager.location?.coordinate
        else
        {
            return
        }
        WeatherData.GlobalData.setUrl(userLat: String(describing: coordinate.latitude),userLon: String(describing: coordinate.longitude))
        
        let urlRequest = URLRequest(url: WeatherData.GlobalData.url!)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest)
        {
            (data, response, error) in
            // check for any errors
            guard error == nil
            else
            {
                print("error calling GET on " + String(describing: urlRequest))
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data
            else
            {
                print("Error: did not receive weather data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do
            {
                guard let weather = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers)
                    as? [String: Any]
                else
                {
                        print("error trying to convert weather data to JSON")
                        return
                }
                
                WeatherData.GlobalData.initVars(json: weather as [String: AnyObject])
                print("Temp Farenheit: " + String(WeatherData.GlobalData.temperatureF))
                
            }
            catch
            {
                print("error trying to convert data to JSON")
                WeatherData.GlobalData.initInvalid()
                return
            }
        }
        task.resume()
    }
    
    // Did Fail With Error
    // *************************************************************************
    func locationManager(_ locationManager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed")
    }
    
    // *************************************************************************
    // Map View Code  **********************************************************
    // *************************************************************************
    
    // Did Select Annotation
    // *************************************************************************
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        let selectedAnnotation = view.annotation
        
        setWindSock()
        
        if(selectedAnnotation != nil){
            hypotenuse = 0.0
            
            if(userToPin){
                target = CLLocationCoordinate2D(latitude: (selectedAnnotation?.coordinate.latitude)!, longitude: (selectedAnnotation?.coordinate.longitude)!)
                
               // shooterheight = Double(JSONWeatherData.GlobalData.altitude)!
                
                if(selectedAnnotation?.subtitle! != nil){
                    //let height = selectedAnnotation!.subtitle!!
                    // let index1 = height.endIndex.advancedBy(-3)
                    // let substring1 = height.substringToIndex(index1)
                    
                    //let index1 = height
                    //let substring1 = height
                    //targetheight = Double(substring1)!
                    
                    //                    var index1 = height.index(height.endIndex, offsetBy: -3)
                    //                    var substring1 = string1.substring(to: index1)
                    //targetheight = Double(selectedAnnotation!.subtitle!!)!
                    //hello[hello.index(endIndex, offsetBy: -4)]
                }
                // print(selectedAnnotation!.subtitle!!)
                
                //http://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034&sensor=false
                
                //Update the Initial Pin Selection
                if(target != nil && shooter != nil){
                    mapView.remove(flightpathPolyline)
                    
                    var coordinate: [CLLocationCoordinate2D] = [shooter, target]
                    
                    flightpathPolyline = MKGeodesicPolyline(coordinates: coordinate, count: 2)
                    
                    print("polyline: (" +  String(flightpathPolyline.coordinate.latitude) + ", " + String(flightpathPolyline.coordinate
                    .longitude))
                    
                    mapView.add(flightpathPolyline, level: MKOverlayLevel.aboveLabels)
                    
                    
                    let loc1 = CLLocation(latitude: shooter.latitude , longitude: shooter.longitude)
                    let loc2 = CLLocation(latitude: target.latitude, longitude: target.longitude)
                    
                    distinMeters = loc1.distance(from: loc2)
                    distanceYds = (Double(distinMeters) * 1.09361)
                    
                    print("distance in yards: " + String(distanceYds) + " yds")
                    
                    
                    
                    if(altitudeOn){
                        //angleset()
                    }
                   // setBallistics(sender: self)
                }
            }
            else if !setPin
            {//set shooter
                shooter = nil
                target = nil
                mapView.remove(flightpathPolyline)
                
                shooter = CLLocationCoordinate2D(latitude: (selectedAnnotation?.coordinate.latitude)!, longitude: (selectedAnnotation?.coordinate.longitude)!)
                
                WeatherData.GlobalData.setUrl(userLat: String(shooter.latitude),userLon: String(shooter.longitude))
                let task = URLSession.shared.dataTask(with: WeatherData.GlobalData.url!) { (data, response, error) -> Void in
                    if let urlContent = data{
                        do{
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options:  JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary

                            //Set the weather data variables
                            WeatherData.GlobalData.initVars(json: jsonResult as! [String : AnyObject])
                        }catch {
                            print("JSON Ser Fail")

                            //Set the weather data NaN
                            WeatherData.GlobalData.initInvalid()
                        }
                    }
                }
                task.resume()
                
                if(selectedAnnotation?.subtitle! != nil)
                {
                    print("selected annotation subtitle not nil")
                    //let height = selectedAnnotation!.subtitle!!
                    //let index1 = height
                    //let substring1 = height
                    //shooterheight = Double(substring1)!
                }
                setPin = true
                distanceYds = 0
            }
            else
            {//set target
                target = CLLocationCoordinate2D(latitude: (selectedAnnotation?.coordinate.latitude)!, longitude: (selectedAnnotation?.coordinate.longitude)!)
                if(selectedAnnotation?.subtitle! != nil){
                    let height = selectedAnnotation!.subtitle!!
                    let index1 = height
                    let substring1 = height
                    targetheight = Double(substring1)!
                    
                }
                //Update the Initial Pin Selection
                if(target != nil && shooter != nil){
                    mapView.remove(flightpathPolyline)
                    
                    var coordinate: [CLLocationCoordinate2D] = [shooter, target]
                    
                    flightpathPolyline = MKGeodesicPolyline(coordinates: &coordinate, count: 2)
                    
                    mapView.add(flightpathPolyline, level: MKOverlayLevel.aboveRoads)
                    
                    let loc1 = CLLocation(latitude: shooter.latitude , longitude: shooter.longitude)
                    let loc2 = CLLocation(latitude: target.latitude, longitude: target.longitude)
                    
                    distinMeters = loc1.distance(from: loc2)
                    
                    
                    //resetDistance()
                    
                    setPin = false
                }
            }
        }
    }
    
    // Render OverLays
    // *************************************************************************
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if let polyline = overlay as? MKGeodesicPolyline
        {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = UIColor.black
            let lineDashPatterns: [NSNumber]?  = [2, 4, 2]
            testlineRenderer.lineDashPattern = lineDashPatterns
            testlineRenderer.lineDashPhase = CGFloat(0.87)
            testlineRenderer.lineWidth = 1.0
            return testlineRenderer
        }
        fatalError("Something wrong with renderer...")
    }
    
    // Popup Bubble View Annotations
    // *************************************************************************
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard let annotation = annotation as? TargetPin else { return nil }

        let identifier = "marker"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView
        {
            dequeuedView.annotation = annotation
            view = dequeuedView
        }
        else
        {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}
