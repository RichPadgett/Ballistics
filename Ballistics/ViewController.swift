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
    // Timers
    private var sockTimer = Timer()
    private var weatherTimer = Timer()
    private var textFieldTimer = Timer()
    private var altitudeTimer = Timer()
    private var moaListener = Timer()
    
    private var locationManager = CLLocationManager()
    private var heading = CLLocationDegrees()
    private var latDelta: CLLocationDegrees = 0.002
    private var lonDelta: CLLocationDegrees = 0.002
    private var target: CLLocationCoordinate2D!
    private var shooter: CLLocationCoordinate2D!
    private var flightpathPolyline = MKGeodesicPolyline()
    private var trueNorth : Double = 0
    
    var microphoneOn = false
    var lockBearing : Bool = false
    var menuIsVisible: Bool = false
    
    private var ballisticsBrain = BallisticsBrain()
  
    func getBallisticsBrain() -> BallisticsBrain
    {
        return ballisticsBrain
    }
    
    
    // View Outlets
    @IBOutlet weak var viewBehindStackView: UIView!
    
    // NavigationItem Outlets
    @IBOutlet weak var navigationCenterItem: UINavigationItem!
    
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
    @IBOutlet weak var labelMOA: UILabel!
    @IBOutlet weak var labelWMOA: UILabel!
    
    // Constraint Outlets
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    @IBOutlet weak var windSockTopC: NSLayoutConstraint!

    @IBOutlet weak var windSockRightC: NSLayoutConstraint!
  
    
    // View Did Load
    // *************************************************************************
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //set map delegate
        mapView.delegate = self
        
        //Set initial location to Greenville SC
        let initialLocation = CLLocation(latitude: 34.8526, longitude: -82.3940)
        centerMapOnLocation(location: initialLocation)
        
        mapView.register(TargetPin.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        // enable location services
        enableLocationServices()
        
        // get weather timer
        getWeatherForCoordinate()
        weatherTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(ViewController.getWeatherForCoordinate), userInfo: nil, repeats: true)
        
        // get altitude timer
        getElevationForCoordinate()
        altitudeTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(ViewController.getElevationForCoordinate), userInfo: nil, repeats: true)
        
        textFieldTimer = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(ViewController.sinkTextFieldVariables), userInfo: nil, repeats: true)
        
        // Set wind Sock interval
        setWindSock()
        sockTimer = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(ViewController.setWindSock), userInfo: nil, repeats: true)
        
        moaListener = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(ViewController.setMOAs), userInfo: nil, repeats: true)
        
          initializeTextFields()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        navigationCenterItem.title = " ∆ "

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
    
    @objc func setMOAs()
    {
        if(!ballisticsBrain.results.isEmpty)
        {
            if(ballisticsBrain.results[0] != 0)
            {
                let up = ballisticsBrain.results[2]
                if(up >= 0)
                {
                    labelMOA.text = String(format: "\u{2b06} %.2lf", up)
                }
                else
                {
                   labelMOA.text = String(format: "\u{2b07} %.2lf", (up * -1))
                }
                
                let rt = ballisticsBrain.results[5]
                if(rt > 0)
                {
                    labelWMOA.text = String(format: "\u{27a1} %.2lf", rt)
                }
                else
                {
                    labelWMOA.text = String(format: "\u{2b05} %.2lf", (rt * -1))
                }
                
                //Animate the keyboard opening and textfield moving
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:
                    {
                        self.view.layoutIfNeeded()
                }) { (animationComplete) in }
            }
            else
            {
                labelMOA.text = "Target Out of Range!"
                labelWMOA.text = ""
            }
        }
        else
        {
            labelMOA.text = ""
            labelWMOA.text = ""
        }
    }
    
    @objc func sinkTextFieldVariables()
    {
        targetBearingTextField.text = String(self.trueNorth)
        temperatureTextField.text = String(WeatherData.GlobalData.temperatureF)
        pressureTextField.text = String(WeatherData.GlobalData.pressure)
        humidityTextField.text = String(WeatherData.GlobalData.humidity)
        windSpeedTextField.text = String(WeatherData.GlobalData.windspeed)
        windDirectionTextField.text = String(WeatherData.GlobalData.degrees)
        altitudeTextField.text = String(WeatherData.GlobalData.altitude)
    }
    
    // Keyboard Close Function
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
       // if(menuIsVisible)
        //{
         //   operateMenuButton()
       // }
        
    }

    @IBOutlet weak var stackViewTopC: NSLayoutConstraint!
    
    // Might not be used ***
    @IBAction func touchUpInsideTextField(_ sender: UITextField) {
        print("touched " + String(describing: sender))
        switch(sender)
        {
        case targetBearingTextField:
            stackViewTopC.constant = 0
            
            break
        case targetDistanceTextField:
            stackViewTopC.constant = 0
          
            break
        case zeroRangeTextField:
            stackViewTopC.constant = 0
      
            break
        case sightHeightTextField:
            stackViewTopC.constant = 0
           
            break
        case ballisticCoefficientTextField:
            stackViewTopC.constant = 0
           
            break
        case weightTextField:
            stackViewTopC.constant = 0
      
            break
        case muzzleVelocityTextField:
            stackViewTopC.constant = 0
      
            break
        case temperatureTextField:
            stackViewTopC.constant = -200
          
            break
        case pressureTextField:
            stackViewTopC.constant = -200
           
            break
        case humidityTextField:
            stackViewTopC.constant = -200
         
            break
        case windSpeedTextField:
            stackViewTopC.constant = -200
  
            break
        case windDirectionTextField:
            stackViewTopC.constant = -200
          
            break
        case altitudeTextField:
            stackViewTopC.constant = -200
  
            break
        default:
            stackViewTopC.constant = 0
    
            break
        }
        
        //Animate the keyboard opening and textfield moving
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:
            {
                self.view.layoutIfNeeded()
        }) { (animationComplete) in }
    }
    
    // Keyboard Open Features
    @objc func keyboardDidShow(notification: NSNotification)
    {
        //Keyboard popped up
    }
    
    // Keyboard hide Features
    @objc func keyboardDidHide(notification: NSNotification)
    {
        //Keyboard closed
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
            
            stackViewTopC.constant = 0
            stackViewTopC.constant = 0
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
        let dist = ballisticsBrain.distanceYds * 0.0009144
        if (dist > 0)
        {
        let newcoord : CLLocationCoordinate2D = shooter.translate(bearing: self.trueNorth, distanceKm: dist)
            
        let pressPin = TargetPin(title: "Target", locationName: "TestLocation", discipline: "Target", coordinate: newcoord)
            
            mapView.addAnnotation(pressPin)
        }
        else
        {
            alertEnterDistance(self)
        }
    }
    
    // Environment Button Function
    func useDontUseEnvironment()
    {
        ballisticsBrain.environmentOn = !ballisticsBrain.environmentOn
        environmentAlert(self)
    }
    
    // Bearing Button Function
    func lockUnlockBearing()
    {
        self.lockBearing = !self.lockBearing
        bearingLockedAlert(self)
    }
    
    // Altitude Button Function
    func useDontUseAltitude()
    {
        ballisticsBrain.altitudeOn = !ballisticsBrain.altitudeOn
        altitudeAlert(self)
    }
    
    // Microphone Button Function
    func turnOnOffMicrophone()
    {
        self.microphoneOn = !microphoneOn
        microphoneAlert(self)
    }
    
    // Button Functions Control
    // *************************************************************************
    @IBAction func menuButtonAction(_ sender: Any)
    {
        operateMenuButton()
    }
    @IBAction func removePinsAction(_ sender: Any)
    {
        removePinsFromMap()
    }
    
    // drop target point and clear old targets
    @IBAction func barButtonAction(_ sender: UIBarButtonItem)
    {
     
        if let title = sender.title
        {
            switch title
            {
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
         self.degreeLabel.text = String(describing: Int(self.trueNorth))
        UIView.animate(withDuration: 0.5)
        {
            self.windSock.transform = CGAffineTransform(rotationAngle: CGFloat(((WeatherData.GlobalData.degrees -
                self.mapView.camera.heading) * Double.pi)/180))
            
            if(!self.lockBearing)
            {
                self.trueNorth  = Double(self.mapView.camera.heading)
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
            
            // 5 second delay until new pin drop available
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ViewController.setCanPinDrop), userInfo: nil, repeats: false)
        }
        else
        {
            //Pin Drop Skipped for 5 seconds
        }
    }

    // Center Map
    // *************************************************************************
    let regionRadius: CLLocationDistance = 7
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
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        heading = newHeading.trueHeading - newHeading.magneticHeading
        self.mapView.camera.heading = newHeading.magneticHeading
    }
    
    // Draw shot line on Map
    func drawShotLine(location: CLLocation)
    {
        // Shooter = Your Location
        shooter = CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!,
                longitude: (locationManager.location?.coordinate.longitude)!)
        
        // If target set, draw the line
        if(target != nil)
        {
            mapView.remove(flightpathPolyline)
            
            var coordinate: [CLLocationCoordinate2D] = [shooter, target]
            
            flightpathPolyline = MKGeodesicPolyline(coordinates: &coordinate, count: 2)
            
            mapView.add(flightpathPolyline)
            
            let loc1 = CLLocation(latitude: shooter.latitude , longitude: shooter.longitude)
            let loc2 = CLLocation(latitude: target.latitude, longitude: target.longitude)
            
            ballisticsBrain.distinMeters = loc1.distance(from: loc2)
            ballisticsBrain.resetDistance()
            ballisticsBrain.setBallistics(shooter: shooter, target: target)
        }
    }
    
    // Did Update Locations
    // *************************************************************************
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // draw polyline from shooter to target
        drawShotLine(location: locations[0])
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
    
    // *************************************************************************
    // Map View Code  **********************************************************
    // *************************************************************************
    
    
    // Did Select Annotation
    // *************************************************************************
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        let selectedAnnotation = view.annotation
        
        setWindSock()
        
        if(selectedAnnotation != nil && ballisticsBrain.distanceYds > 0)
        {
            target = CLLocationCoordinate2D(latitude: (selectedAnnotation?.coordinate.latitude)!, longitude: (selectedAnnotation?.coordinate.longitude)!)
                
            //Update the Initial Pin Selection
            if(target != nil && shooter != nil)
            {
                mapView.remove(flightpathPolyline)
                
                let coordinate: [CLLocationCoordinate2D] = [shooter, target]
                
                flightpathPolyline = MKGeodesicPolyline(coordinates: coordinate, count: 2)
                
                print("polyline: (" +  String(flightpathPolyline.coordinate.latitude) + ", " + String(flightpathPolyline.coordinate
                .longitude))
                
                mapView.add(flightpathPolyline, level: MKOverlayLevel.aboveLabels)
                
                let loc1 = CLLocation(latitude: shooter.latitude , longitude: shooter.longitude)
                let loc2 = CLLocation(latitude: target.latitude, longitude: target.longitude)
                
                ballisticsBrain.distinMeters = loc1.distance(from: loc2)
                ballisticsBrain.distanceYds = (Double(ballisticsBrain.distinMeters) * 1.09361)
                ballisticsBrain.angleset()
                ballisticsBrain.setBallistics(shooter: shooter, target: target)
                alertBallistics(self)
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl)
    {
        alertBallistics(self)
    }
    
   
}
