//
//  ViewController.swift
//  Ballistics
//
//  Created by Richard Padgett on 1/3/18.
//  Copyright © 2018 Richard-Padgett. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate  {
    
    
    // Variables
    private var sockTimer = Timer()
    private var weatherTimer = Timer()
    private var altitudeTimer = Timer()
    private var locationManager = CLLocationManager()
    private var heading = CLLocationDegrees()
    private var north = CLLocationDegrees()
    private var latDelta: CLLocationDegrees = 0.002
    private var lonDelta: CLLocationDegrees = 0.002
    private var updating = true
    private var userToPin = true
    private var target: CLLocationCoordinate2D!
    private var shooter: CLLocationCoordinate2D!
    private var flightpathPolyline = MKGeodesicPolyline()
    private var distinMeters : Double = 0
    private var distanceYds : Double = 0
    
    private var microphoneOn = false
    
    private var targetheight : Double = 0
    private var setPin = false
    private var targetIncrement: Int = 1
    private var lockBearing : Bool = false
    private var menuIsVisible: Bool = false
    
    private var mapBrain = MapBrain()
    private var ballisticsBrain = BallisticsBrain()
    
    // View Outlets
    @IBOutlet weak var viewBehindStackView: UIView!
    
    // Button Outlets
    @IBOutlet weak var windSock: UIButton!
    @IBOutlet weak var microphoneButton: UIBarButtonItem!
    @IBOutlet weak var altitudeButton: UIBarButtonItem!
    @IBOutlet weak var compassButton: UIBarButtonItem!
    @IBOutlet weak var environmentButton: UIBarButtonItem!
    
    // TextField Outlets
    @IBOutlet weak var targetBearingTextField: UITextField!
    @IBOutlet weak var targetDistanceTextField: UITextField!
    @IBOutlet weak var zeroRangeTextField: UITextField!
    @IBOutlet weak var sightHeightTextField: UITextField!
    @IBOutlet weak var ballisticCoefficientTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var muzzleVelocityTextField: UITextField!
    @IBOutlet weak var temperatureTextField: UITextField!
    @IBOutlet weak var pressureTextField: UITextField!
    @IBOutlet weak var humidityTextField: UITextField!
    @IBOutlet weak var windSpeedTextField: UITextField!
    @IBOutlet weak var windDirectionTextField: UITextField!
    @IBOutlet weak var altitudeTextField: UITextField!
    
    // Label Outlets
    @IBOutlet weak var degreeLabel: UILabel!
    
    // Constraint Outlets
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    @IBOutlet weak var windSockTopC: NSLayoutConstraint!
    @IBOutlet weak var stackViewCenterC: NSLayoutConstraint!
    @IBOutlet weak var windSockRightC: NSLayoutConstraint!
    @IBOutlet weak var stackViewLCenterC: NSLayoutConstraint!
    
    // View Did Load
    // *************************************************************************
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //set map delegate
        mapView.delegate = self
        
        //Set initial location to Greenville SC
        //let initialLocation = CLLocation(latitude: 34.8526, longitude: -82.3940)
        
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
        
          initializeTextFields()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)

    }
    
    func setKeyboardStyle(textField: UITextField)
    {
        textField.delegate = self
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.keyboardType = UIKeyboardType.decimalPad
    }
    
    func initializeTextFields()
    {
        setKeyboardStyle(textField: targetBearingTextField)
        setKeyboardStyle(textField: targetDistanceTextField)
        setKeyboardStyle(textField: zeroRangeTextField)
        setKeyboardStyle(textField: sightHeightTextField)
        setKeyboardStyle(textField: ballisticCoefficientTextField)
        setKeyboardStyle(textField: weightTextField)
        setKeyboardStyle(textField: muzzleVelocityTextField)
        setKeyboardStyle(textField: temperatureTextField)
        setKeyboardStyle(textField: pressureTextField)
        setKeyboardStyle(textField: humidityTextField)
        setKeyboardStyle(textField: windSpeedTextField)
        setKeyboardStyle(textField: windDirectionTextField)
        setKeyboardStyle(textField: altitudeTextField)
    }
    
    // Memory Warning
    // *************************************************************************
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Keyboard Close Function
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
        
    }
    
    // Keyboard Open Features
    
    @IBAction func touchUpInsideTextField(_ sender: UITextField) {
        print("touched " + String(describing: sender))
        switch(sender)
        {
        case targetBearingTextField:
            stackViewCenterC.constant = 0
            stackViewLCenterC.constant = 0
            break
        case targetDistanceTextField:
            stackViewCenterC.constant = 0
            stackViewLCenterC.constant = 0
            break
        case zeroRangeTextField:
            stackViewCenterC.constant = 0
            stackViewLCenterC.constant = 0
            break
        case sightHeightTextField:
            stackViewCenterC.constant = 0
            stackViewLCenterC.constant = 0
            break
        case ballisticCoefficientTextField:
            stackViewCenterC.constant = 0
            stackViewLCenterC.constant = 0
            break
        case weightTextField:
            stackViewCenterC.constant = 0
            stackViewLCenterC.constant = 0
            break
        case muzzleVelocityTextField:
            stackViewCenterC.constant = 0
            stackViewLCenterC.constant = 0
            break
        case temperatureTextField:
            stackViewCenterC.constant = -200
            stackViewLCenterC.constant = -200
            break
        case pressureTextField:
            stackViewCenterC.constant = -200
            stackViewLCenterC.constant = -200
            break
        case humidityTextField:
            stackViewCenterC.constant = -200
            stackViewLCenterC.constant = -200
            break
        case windSpeedTextField:
            stackViewCenterC.constant = -200
            stackViewLCenterC.constant = -200
            break
        case windDirectionTextField:
            stackViewCenterC.constant = -200
            stackViewLCenterC.constant = -200
            break
        case altitudeTextField:
            stackViewCenterC.constant = -200
            stackViewLCenterC.constant = -200
            break
        default:
            stackViewCenterC.constant = 0
            stackViewLCenterC.constant = 0
            break
        }
        
        //Animate the keyboard opening and textfield moving
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:
            {
                self.view.layoutIfNeeded()
        }) { (animationComplete) in }
    }
    @objc func keyboardDidShow(notification: NSNotification)
    {
        
    }
    
    // Keyboard hide Features
    @objc func keyboardDidHide(notification: NSNotification)
    {

    }
    
    // Button Functions
    // *************************************************************************
    
    // Menu Button Function
    func operateMenuButton()
    {
        if(!menuIsVisible)
        {
            leadingC.constant = viewBehindStackView.bounds.maxX + 36
            windSockRightC.constant = 2
            windSockTopC.constant = 42
            menuIsVisible = true
        }
        else
        {
            leadingC.constant = 0
            windSockRightC.constant = 42
            windSockTopC.constant = 2
            menuIsVisible = false
            
            stackViewCenterC.constant = 0
            stackViewLCenterC.constant = 0
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:
        { self.view.layoutIfNeeded() })
        {
            (animationComplete) in
        }
    }
    
    // Unpin Button Function
    func removePinsFromMap()
    {
        print("removing pins")
        let annotationsToRemove = mapView.annotations.filter
        {
            $0 !== mapView.userLocation
        }
        mapView.removeAnnotations( annotationsToRemove )
        target = nil
        mapView.remove(flightpathPolyline)
    }
    
    // Target Button Function
    func dropTargetUsingData()
    {
        if (!(targetDistanceTextField.text?.isEmpty)!)
        {
            let targetDistString = self.targetDistanceTextField.text as! String
            guard let dist : Double = ((Double(targetDistString))! * 0.0009144)
                else
            {
                alertEnterDistance()
                return
            }
            //let newcoord : CLLocationCoordinate2D = shooter.translate(bearing: self.mapView.camera.heading, distanceKm: dist)
            
            let newcoord : CLLocationCoordinate2D = shooter.translate(bearing: GlobalSelectionModel.trueNorth, distanceKm: dist)
            
            let pressPin = TargetPin(title: "Target", locationName: "TestLocation", discipline: "Target", coordinate: newcoord)
            
            let loc = CLLocation(latitude: newcoord.latitude, longitude: newcoord.longitude)
            
            mapView.addAnnotation(pressPin)
        }
        else
        {
            alertEnterDistance()
        }
    }
    
    // Environment Button Function
    func useDontUseEnvironment()
    {
        ballisticsBrain.environmentOn = !ballisticsBrain.environmentOn
        environmentAlert()
    }
    
    // Bearing Button Function
    func lockUnlockBearing()
    {
        self.lockBearing = !self.lockBearing
        bearingLockedAlert()
    }
    
    // Altitude Button Function
    func useDontUseAltitude()
    {
        ballisticsBrain.altitudeOn = !ballisticsBrain.altitudeOn
        altitudeAlert()
    }
    
    // Microphone Button Function
    func turnOnOffMicrophone()
    {
        self.microphoneOn = !microphoneOn
        microphoneAlert()
    }
    
    // Button Functions Control
    // *************************************************************************
    
    // drop target point and clear old targets
    @IBAction func barButtonAction(_ sender: UIBarButtonItem)
    {
        if let title = sender.title
        {
            switch title
            {
            case "SetMenu":
                operateMenuButton()
            case "SetUnpin":
                removePinsFromMap()
            case "SetTarget":
                dropTargetUsingData()
            case "SetEnvironment":
                useDontUseEnvironment()
            case "SetBearing":
                lockUnlockBearing()
            case "SetAltitude":
                useDontUseAltitude()
            case "SetMicrophone":
                turnOnOffMicrophone()
            default:
                break
            }
        }
    }
    
    // TextField Action Control
    @IBAction func textFieldAction(_ sender: UITextField)
    {
        print("editing ended")
        if(sender.hasText)
        {
            let variable = sender.text!
            switch sender
            {
            case targetBearingTextField:
                ballisticsBrain.setValue(type: "USER_BEARING", variable: variable)
            case targetDistanceTextField:
                ballisticsBrain.setValue(type: "TARGET_DISTANCE", variable: variable)
            case zeroRangeTextField:
                ballisticsBrain.setValue(type: "ZERO_RANGE", variable: variable)
            case sightHeightTextField:
                ballisticsBrain.setValue(type: "SIGHT_HEIGHT", variable: variable)
            case ballisticCoefficientTextField:
                ballisticsBrain.setValue(type: "BALLISTIC_COEFFICIENT", variable: variable)
            case weightTextField:
                ballisticsBrain.setValue(type: "PROJECTILE_WEIGHT", variable: variable)
            case muzzleVelocityTextField:
                ballisticsBrain.setValue(type: "MUZZLE_VELOCITY", variable: variable)
            case temperatureTextField:
                ballisticsBrain.setValue(type: "OUTSIDE_TEMPERATURE", variable: variable)
            case pressureTextField:
                ballisticsBrain.setValue(type: "PRESSURE", variable: variable)
            case humidityTextField:
                ballisticsBrain.setValue(type: "HUMIDITY", variable: variable)
            case windSpeedTextField:
                ballisticsBrain.setValue(type: "WIND_SPEED", variable: variable)
            case windDirectionTextField:
                ballisticsBrain.setValue(type: "WIND_DIRECTION", variable: variable)
            case altitudeTextField:
                ballisticsBrain.setValue(type: "ALTITUDE", variable: variable)
            default:
                break
            }
        }
    }

    //====================================================================
    //Control The degrees that the wind Sock Points
    @objc func setWindSock()
    {
         self.degreeLabel.text = String(describing: Int(GlobalSelectionModel.trueNorth))
        UIView.animate(withDuration: 0.5)
        {
            self.windSock.transform = CGAffineTransform(rotationAngle: CGFloat(((WeatherData.GlobalData.degrees -
                self.mapView.camera.heading) * Double.pi)/180))
            
            if(!self.lockBearing)
            {
                GlobalSelectionModel.trueNorth  = Double(self.mapView.camera.heading)
            }
        }

        if(WeatherData.GlobalData.windspeed != "NaN")
        {
            if(GlobalSelectionModel.imperial)
            {
                //speed.text = String(format: "%.2lf", Double(JSONWeatherData.GlobalData.windspeed)!) + " mph"
                //degree.text = String(format: "%.0lf", Double(JSONWeatherData.GlobalData.degrees)) + " \u{00B0}"
            }
            else
            {
                //speed.text = String(format: "%.2lf", (Double(JSONWeatherData.GlobalData.windspeed)!) * 1.60934) + " kph"
                //degree.text = String(format: "%.0lf", Double(JSONWeatherData.GlobalData.degrees)) + " \u{00B0}"
            }
        }
    }
    
    @objc func setCanPinDrop()
    {
        ViewController.canPinDrop = true
    }
    private static var canPinDrop = true
    // Map View outlet and Long Press Action
    // *************************************************************************
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func longPressMap(_ sender: UILongPressGestureRecognizer)
    {
        if(ViewController.canPinDrop)
        {
            ViewController.canPinDrop = false
            let pressPoint = sender.location(in: mapView)
            let pressCoordinate = mapView.convert(pressPoint, toCoordinateFrom: mapView)
        
            let pressPin = TargetPin(title: "Target", locationName: "TestLocation", discipline: "Target", coordinate: pressCoordinate)
        
            mapView.addAnnotation(pressPin)
            
            var timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ViewController.setCanPinDrop), userInfo: nil, repeats: false)
        }
        print("skipped pin drop")
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
    }
    
    // Did Update Locations
    // *************************************************************************
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
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

            ballisticsBrain.resetDistance()
            ballisticsBrain.setBallistics(shooter: shooter, target: target)
            //alertBallistics()
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
        
        if(selectedAnnotation != nil)
        {
            target = CLLocationCoordinate2D(latitude: (selectedAnnotation?.coordinate.latitude)!, longitude: (selectedAnnotation?.coordinate.longitude)!)
            
           // shooterheight = Double(JSONWeatherData.GlobalData.altitude)!
            
            if(selectedAnnotation?.subtitle! != nil)
            {
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
                
            //Update the Initial Pin Selection
            if(target != nil && shooter != nil)
            {
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

                ballisticsBrain.angleset()
                print("BALL BRAIN:" + String(ballisticsBrain.distanceYds))
                ballisticsBrain.setBallistics(shooter: shooter, target: target)
                alertBallistics()
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
               
                if(selectedAnnotation?.subtitle! != nil)
                {
                    let height = selectedAnnotation!.subtitle!!
                    let index1 = height
                    let substring1 = height
                    targetheight = Double(substring1)!
                    
                }
                //Update the Initial Pin Selection
                if(target != nil && shooter != nil)
                {
                    mapView.remove(flightpathPolyline)
                    
                    var coordinate: [CLLocationCoordinate2D] = [shooter, target]
                    
                    flightpathPolyline = MKGeodesicPolyline(coordinates: &coordinate, count: 2)
                    
                    mapView.add(flightpathPolyline, level: MKOverlayLevel.aboveRoads)
                    
                    let loc1 = CLLocation(latitude: shooter.latitude , longitude: shooter.longitude)
                    let loc2 = CLLocation(latitude: target.latitude, longitude: target.longitude)
                    
                    distinMeters = loc1.distance(from: loc2)

                    ballisticsBrain.resetDistance()
                    
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
    
    
    // Alerts
    // *************************************************************************
    // Distance Missing Alert
    func alertEnterDistance()
    {
        let alert = UIAlertController(title: "Distance Setting", message: "Enter a number for distance in menu.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler:
            {
                action in
                if(self.leadingC.constant == 0 )
                {
                    self.operateMenuButton()
                }
        }))
        
        self.present(alert, animated: true)
    }
    
    // Distance Missing Alert
    func altitudeAlert()
    {
        var altitudeDesc : String
        if(ballisticsBrain.altitudeOn)
        {
            altitudeDesc = "On"
            altitudeButton.tintColor = self.view.tintColor
        }
        else
        {
            altitudeDesc = "Off"
            altitudeButton.tintColor = UIColor.red
            
        }
        let alert = UIAlertController(title: "Altitude On/Off", message: "Altitude is set to " + altitudeDesc , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func environmentAlert()
    {
        var environmentDesc : String
        if(ballisticsBrain.environmentOn)
        {
            environmentDesc = "On"
            environmentButton.tintColor = self.view.tintColor
        }
        else
        {
            environmentDesc = "Off"
            environmentButton.tintColor = UIColor.red
        }
        let alert = UIAlertController(title: "Environment On/Off", message: "Environment is set to " + environmentDesc , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // Distance Missing Alert
    func bearingLockedAlert()
    {
        var bearingDesc : String
        if(self.lockBearing)
        {
            bearingDesc = "Locked"
            compassButton.tintColor = self.view.tintColor
        }
        else
        {
            bearingDesc = "Unlocked"
            compassButton.tintColor = UIColor.red
        }
        let alert = UIAlertController(title: "Bearing Locked/Unlocked", message: "Bearing is set to " + bearingDesc , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // Distance Missing Alert
    func microphoneAlert()
    {
        var microphoneDesc : String
        if(self.microphoneOn)
        {
            microphoneDesc = "On"
            microphoneButton.tintColor = self.view.tintColor
        }
        else
        {
            microphoneDesc = "Off"
            microphoneButton.tintColor = UIColor.red
        }
        let alert = UIAlertController(title: "Turn On/Off Microphone", message: "Microphone is set to " + microphoneDesc , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alert, animated: true)
        
    }
    
    func alertBallistics()
    {
        var message : String
        if(GlobalSelectionModel.Results[0] == 0)
        {
            message = "Target is out of range"
        }
        else
        {
            message = String(ballisticsBrain.bc) + " BC\n"
                +   String(format: "%.2lf", GlobalSelectionModel.Results[0]) + " Range (Yds)\n"
                +   String(format: "%.2lf", GlobalSelectionModel.Results[1]) + " Drop  (in)\n"
                +   String(format: "%.2lf", GlobalSelectionModel.Results[2]) + " Drop  (MoA)\n"
                +   String(format: "%.2lf", GlobalSelectionModel.Results[6]) + " Velocity  (ft/s)\n"
                +   String(format: "%.2lf", GlobalSelectionModel.Results[4]) + " Wind  (in)\n"
                +   String(format: "%.2lf", GlobalSelectionModel.Results[5]) + " Wind  (MoA)\n"
                +   String(format: "%d",(Int(GlobalSelectionModel.Results[9]))) + " Energy  (ft-lb)\n"
                +   String(format: "%.2lf", GlobalSelectionModel.Results[3]) + " Time  (s)\n"
        }
        let alert = UIAlertController(title: "Ballistics", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
}
