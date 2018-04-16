//
//  ViewController.swift
//  Ballistics
//
//  Created by Richard Padgett on 1/3/18.
//  Copyright © 2018 Richard-Padgett. All rights reserved.
//

import UIKit
import MapKit
import Speech

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, SFSpeechRecognizerDelegate
{
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    
    
    private let audioEngine = AVAudioEngine()
    
    
    
    //@IBOutlet var textView : UITextView!
    
    
    
 //   @IBOutlet var recordButton : UIButton!
    
    private static var recognitionReset = Timer()
    
    // Variables
    private var locationManager = CLLocationManager()
    
    private var heading = CLLocationDegrees()
    private var latDelta: CLLocationDegrees = 0.002
    private var lonDelta: CLLocationDegrees = 0.002
    private var target: TargetPin!
    private var shooter: CLLocationCoordinate2D!
    private var flightpathPolyline = MKGeodesicPolyline()
    private var trueNorth : Double = 0
    private var zoom : Double = 1000
    
    @IBOutlet weak var recordingImage: UIImageView!
    
    var microphoneOn = false
    var lockBearing : Bool = false
    var centerMap : Bool = true
    var menuIsVisible: Bool = false
    var windOn: Bool = true
    
    var ballisticCalculator = BallisticCalculator.sharedInstance
    var weatherData = WeatherData.sharedInstance
    
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
    

    @IBOutlet weak var recordingLabel: UILabel!
    
    @IBOutlet weak var recordedLabel: UILabel!
    
    @IBOutlet weak var windButton: UIBarButtonItem!
    
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
    @IBOutlet weak var labelMOA: UILabel!
    @IBOutlet weak var labelWMOA: UILabel!
    
    // Constraint Outlets
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    @IBOutlet weak var windSockTopC: NSLayoutConstraint!
    @IBOutlet weak var windSockRightC: NSLayoutConstraint!
      
    @IBOutlet weak var moasLeadingC: NSLayoutConstraint!
    // View Did Load
    // *************************************************************************
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //set map delegate
        mapView.delegate = self
        
        // enable location services
        enableLocationServices(sender: self)
        
          initializeTextFields()
          initializeCoreData()
        
        navigationCenterItem.title = " ∆ "
        
        //centerMapOnLocation(location: locationManager.location!)
        getWeatherForCoordinate()
        
        getElevationForCoordinate()
        
        microphoneButton.isEnabled = false
        

    }
    
    override public func viewDidAppear(_ animated: Bool) {
        recordedLabel.text = ""
        speechRecognizer.delegate = self
        
        requestAuth()
    }

    
    func mapView(_ mapview: MKMapView, regionWillChangeAnimated: Bool)
    {
        if(centerMap)
        {
            lockBearing = true
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if(centerMap)
        {
            self.zoom = self.mapView.camera.altitude
            lockBearing = false
        }
    }
    
    func initializeCoreData()
    {
        targetDistanceTextField.text = String(ballisticCalculator.distanceYards)
        ballisticCoefficientTextField.text = String(ballisticCalculator.ballisticCoefficient)
        zeroRangeTextField.text = String(ballisticCalculator.zeroRange)
        sightHeightTextField.text = String(ballisticCalculator.seightHeight)
        weightTextField.text = String(ballisticCalculator.projectileWeight)
        muzzleVelocityTextField.text = String(ballisticCalculator.muzzleVelocity)
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
        if(!ballisticCalculator.results.isEmpty)
        {
            if(ballisticCalculator.results[0] != 0)
            {
                let up = ballisticCalculator.results[2]
                if(up > 0)
                {
                    labelMOA.text = String(format: "\u{2b06} %.2lf", abs(up))
                }
                else
                {
                   labelMOA.text = String(format: "\u{2b07} %.2lf", abs(up))
                }
                
                let rt = ballisticCalculator.results[5]
                if(rt > 0)
                {
                    labelWMOA.text = String(format: "\u{27a1} %.2lf", abs(rt))
                }
                else
                {
                    labelWMOA.text = String(format: "\u{2b05} %.2lf", abs(rt))
                }
                //moasLeadingC.constant = -80
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
    
    func sinkTextFieldVariables()
    {
        targetBearingTextField.text = String(self.trueNorth)
        temperatureTextField.text = String(weatherData.temperatureF)
        pressureTextField.text = String(weatherData.pressure)
        humidityTextField.text = String(weatherData.humidity)
        windSpeedTextField.text = String(weatherData.windSpeed)
        windDirectionTextField.text = String(weatherData.windDirection)
        altitudeTextField.text = String(weatherData.altitude)
    }
    
    // Keyboard Close Function
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
        if(menuIsVisible)
        {
            operateMenuButton()
        }
    }

    @IBOutlet weak var stackViewTopC: NSLayoutConstraint!
    
    // Might not be used ***
    @IBAction func touchUpInsideTextField(_ sender: UITextField) {
        switch(sender)
        {
        case targetBearingTextField:
            stackViewTopC.constant = 0
            
            break
        case targetDistanceTextField:
            stackViewTopC.constant = 0
          
            break
        case zeroRangeTextField:
            stackViewTopC.constant = -0
      
            break
        case sightHeightTextField:
            stackViewTopC.constant = -0
           
            break
        case ballisticCoefficientTextField:
            stackViewTopC.constant = -80
           
            break
        case weightTextField:
            stackViewTopC.constant = -100
      
            break
        case muzzleVelocityTextField:
            stackViewTopC.constant = -120
      
            break
        case temperatureTextField:
            stackViewTopC.constant = -140
          
            break
        case pressureTextField:
            stackViewTopC.constant = -160
           
            break
        case humidityTextField:
            stackViewTopC.constant = -180
         
            break
        case windSpeedTextField:
            stackViewTopC.constant = -200
  
            break
        case windDirectionTextField:
            stackViewTopC.constant = -220
          
            break
        case altitudeTextField:
            stackViewTopC.constant = -240
  
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
            self.view.endEditing(true)
         
            ballisticCalculator.saveCoreData()
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
        getElevationForCoordinate()
        if targetDistanceTextField.text != ""
        {
            ballisticCalculator.distanceYards = Double(targetDistanceTextField.text!)!
            let distKm = ballisticCalculator.distanceKilometers
            if (distKm > 0)
            {
                
                let newcoord : CLLocationCoordinate2D = shooter.translate(bearing: self.trueNorth, distanceKm: distKm)
            
               
                let pressPin = TargetPin(title: "Target", locationName: "TestLocation", discipline: "Target", coordinate: newcoord)
            
                //mapView.addAnnotation(pressPin)
                //mapView.selectAnnotation(pressPin, animated: false)
                
                ballisticCalculator.setBallistics(shooter: shooter, target: pressPin, heading: self.trueNorth)
                setMOAs()
                
                mapView.remove(flightpathPolyline)
                
                let coordinate: [CLLocationCoordinate2D] = [shooter, pressPin.coordinate]
                
                flightpathPolyline = MKGeodesicPolyline(coordinates: coordinate, count: 2)
                
                print("polyline: (" +  String(flightpathPolyline.coordinate.latitude) + ", " + String(flightpathPolyline.coordinate
                    .longitude))
                
                mapView.add(flightpathPolyline, level: MKOverlayLevel.aboveLabels)
            }
            else
            {
                alertEnterDistance(self)
            }
        }
        else
        {
            alertEnterDistance(self)
        }
    }
    
    // Environment Button Function
    func useDontUseEnvironment()
    {
        ballisticCalculator.environmentOn = !ballisticCalculator.environmentOn
        environmentAlert(self)
    }
    
    // Bearing Button Function
    func lockUnlockBearing()
    {
        self.lockBearing = !self.lockBearing
        bearingLockedAlert(self)
        
        if(self.lockBearing)
        {
            centerMap = false
        }
        else
        {
            centerMap = true
        }
    }
    
    func turnOnOffWind()
    {
        self.windOn = !self.windOn
        ballisticCalculator.windOn = !ballisticCalculator.windOn
        windOnOffAlert(self)
        
    }
    
    // Altitude Button Function
    func useDontUseAngles()
    {
        ballisticCalculator.angleCorrection = !ballisticCalculator.angleCorrection
        angleAlert(self)
    }
    
    
    static var commandHeard : Bool = false
    static var indexOfCommand : Int = -1
    private func startRecording()  throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            
            recognitionTask.cancel()
            
            self.recognitionTask = nil
            
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode
        //else { fatalError("Audio engine has no input node") }
        
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
 
        // Configure request so that results are returned before audio recording is finished
        
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        
        // We keep a reference to the task so that it can be cancelled.
       
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            
            var isFinal = false

            if let result = result
            {
                let bestString = result.bestTranscription.formattedString
                
                let newStringArray = result.bestTranscription.segments
                print(bestString)
                
                
                
                if(!ViewController.commandHeard)
                {
                    var lastString = ""
                    
                    lastString = newStringArray[newStringArray.count - 1].substring
                    ViewController.indexOfCommand = newStringArray.count
                    self.checkForCommandStart(resultString: lastString)
                    
                }
                else
                {
                    print("countVVV")
                    print(newStringArray.count - ViewController.indexOfCommand)
                    if(newStringArray.count - ViewController.indexOfCommand == 3 || newStringArray.count - ViewController.indexOfCommand == 4)
                    {
                        if(self.checkForCommand(result: newStringArray))
                        {
                            self.recognitionTask?.finish()
                        }
                    }
                    else if(newStringArray.count - ViewController.indexOfCommand > 4)
                    {
                        print("resetting")
                        ViewController.commandHeard = false
                        self.recordedLabel.text = ""
                    }
                }
                
               


                isFinal = result.isFinal
            }
            
            

            if error != nil || isFinal
            {
                print("-----STOPPING------")
                self.audioEngine.stop()
                
        
               
                self.recordingImage.image = UIImage(named: "")
                self.recordingLabel.text = ""
                
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
               self.microphoneButton.isEnabled = true
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        try audioEngine.start()
        
        recordingImage.image = UIImage(named: "rec.png")
        
        recordingLabel.text = "Rec"
        
    }
    
    
    func checkForCommandStart(resultString: String)
    {
        
        switch resultString
        {
        case "set", "Set", "send", "Send", "sit", "Sit", "sat", "Sat", "said", "Said":
            //self.recordedLabel.text = resultString
            ViewController.commandHeard = true
        default:
            break
        }
    }
    
    func checkForCommand(result: [SFTranscriptionSegment]) -> Bool
    {
        if(ViewController.commandHeard)
        {
            if(result[0].substring == "set" || result[0].substring == "Set" || result[0].substring == "send" || result[0].substring == "Send" || result[0].substring == "Sit" || result[0].substring == "sit" || result[0].substring == "Sat" || result[0].substring == "sat" || result[0].substring == "said" || result[0].substring == "Said")
            {
                if(result[1].substring == "distance" || result[1].substring == "Distance")
                {
                    if(result[2].substring == "to" || result[2].substring == "To" || result[2].substring == "two" || result[2].substring == "Two")
                    {
                        if let num = Double(result[3].substring)
                        {
                            print(num)
                            self.targetDistanceTextField.text = result[3].substring
                            self.ballisticCalculator.distanceYards = num
                            dropTargetUsingData()
                            ViewController.indexOfCommand = -1
                            ViewController.commandHeard = false
                            
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
  
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
        if available
        {
            microphoneButton.isEnabled = true
        }
        else
        {
            microphoneButton.isEnabled = false
        }
    }
    
    // Microphone Button Function
    func turnOnOffMicrophone(screenTap: Bool)
    {
        if(!screenTap)
        {
            self.microphoneOn = !microphoneOn
            microphoneAlert(self)
        }

        if audioEngine.isRunning
        {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            recordingImage.image = UIImage(named: "")
            recordingLabel.text = ""
        }
        else
        {
            ViewController.indexOfCommand = -1
            try! startRecording()
        }
    }
    
    func requestAuth()
    {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /* The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.microphoneButton.isEnabled = true
                    //self.recordButton.isEnabled = true
                case .denied:
                    self.microphoneButton.isEnabled = false
                    //self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                case .restricted:
                    self.microphoneButton.isEnabled = false

                    //self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                case .notDetermined:
                    self.microphoneButton.isEnabled = false

//                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
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
        clearBallistics()
        setMOAs()
    }
    
    func clearBallistics()
    {
        ballisticCalculator.results = []
    }
    
    @IBAction func windSockButton(_ sender: UIButton)
    {
        setWindSock()
        sinkTextFieldVariables()
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
                useDontUseAngles()
            case "SetMicrophone":
                turnOnOffMicrophone(screenTap: false)
                // 5 second delay until new pin drop available
            case "SetWind":
                turnOnOffWind()
            default:
                break
            }
        }
    }
    
    // TextField Action Control
    @IBAction func textFieldAction(_ sender: UITextField)
    {
        if(sender.hasText)
        {
            let variable = sender.text!
            switch sender
            {
            case targetDistanceTextField:
                ballisticCalculator.setValue(type: "TARGET_DISTANCE", variable: variable)
            case zeroRangeTextField:
                ballisticCalculator.setValue(type: "ZERO_RANGE", variable: variable)
            case sightHeightTextField:
                ballisticCalculator.setValue(type: "SIGHT_HEIGHT", variable: variable)
            case ballisticCoefficientTextField:
                ballisticCalculator.setValue(type: "BALLISTIC_COEFFICIENT", variable: variable)
            case weightTextField:
                ballisticCalculator.setValue(type: "PROJECTILE_WEIGHT", variable: variable)
            case muzzleVelocityTextField:
                ballisticCalculator.setValue(type: "MUZZLE_VELOCITY", variable: variable)
            default:
                break
            }
        }
    }

    //====================================================================
    //Control The degrees that the wind Sock Points
    @objc func setWindSock()
    {
        
        UIView.animate(withDuration: 0.5)
        {
            self.windSock.transform = CGAffineTransform(rotationAngle: CGFloat(((self.weatherData.windDirection -
                self.mapView.camera.heading) * Double.pi)/180))
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
 
    
    

    // Did Select Annotation
    // *************************************************************************
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        
        if let selectedAnnotation = view.annotation as? TargetPin
        {
            //selectedAnnotation.getWeather()
            //selectedAnnotation.getAltitude()
            setWindSock()
        
            if(ballisticCalculator.distanceYards > 0)
            {
                
                target = selectedAnnotation
                
                //Update the Initial Pin Selection
                if(target != nil && shooter != nil)
                {
                    getWeatherForCoordinate()
                    sinkTextFieldVariables()
                    //getElevationForCoordinate()
                    
                    mapView.remove(flightpathPolyline)
                    
                    let coordinate: [CLLocationCoordinate2D] = [shooter, target.coordinate]
                    
                    flightpathPolyline = MKGeodesicPolyline(coordinates: coordinate, count: 2)
                    
                    print("polyline: (" +  String(flightpathPolyline.coordinate.latitude) + ", " + String(flightpathPolyline.coordinate
                        .longitude))
                    
                    mapView.add(flightpathPolyline, level: MKOverlayLevel.aboveLabels)
                    
                    let loc1 = CLLocation(latitude: shooter.latitude , longitude: shooter.longitude)
                    let loc2 = CLLocation(latitude: target.coordinate.latitude, longitude: target.coordinate.longitude)
                    
                    ballisticCalculator.distanceYards = (Double(loc1.distance(from: loc2)) * 1.09361)
                    ballisticCalculator.setBallistics(shooter: shooter, target: target, heading: -1)
                    setMOAs()
                }
            }
        }
    }

    // Center Map
    // *************************************************************************
    let regionRadius: CLLocationDistance = 50
    func centerMapOnLocation(location: CLLocation)
    {
        let l1 = location.coordinate.latitude + 0.005
        let l2 = location.coordinate.longitude
        let loc = CLLocation(latitude: l1, longitude: l2)
        let reg = MKCoordinateRegionMakeWithDistance(loc.coordinate, CLLocationDistance(100), CLLocationDistance(100))
        mapView.setRegion(reg, animated: true)
    }
    
    // *************************************************************************
    // Location Manager Code ***************************************************
    // *************************************************************************

    // Did Update Heading
    // *************************************************************************
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        
        //centerMapOnLocation(location: locationManager.location!)
        heading = newHeading.trueHeading - newHeading.magneticHeading
        setWindSock()
        if(!lockBearing)
        {
            //self.mapView.camera.heading = newHeading.magneticHeading
            
            let camera = MKMapCamera(lookingAtCenter: (locationManager.location?.coordinate)!, fromDistance: self.zoom, pitch: 0, heading: newHeading.trueHeading)
            self.mapView.setCamera(camera, animated: false)
            self.trueNorth = newHeading.trueHeading
            navigationCenterItem.title = String(describing: Int(newHeading.trueHeading))
            
            targetBearingTextField.text = String(describing: newHeading.trueHeading)
        }
        //centerMapOnLocation(location: locationManager.location!)
    }
    
    
    // Manage Location Services
    // *************************************************************************
    func enableLocationServices(sender: CLLocationManagerDelegate)
    {
        locationManager.delegate = sender
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
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
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            print("location enabled")
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            locationManager.awakeFromNib()
            break
        }
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
            
            var coordinate: [CLLocationCoordinate2D] = [shooter, target.coordinate]
            
            flightpathPolyline = MKGeodesicPolyline(coordinates: &coordinate, count: 2)
            
            mapView.add(flightpathPolyline)
            
            let loc1 = CLLocation(latitude: shooter.latitude , longitude: shooter.longitude)
            let loc2 = CLLocation(latitude: target.coordinate.latitude, longitude: target.coordinate.longitude)
            
            ballisticCalculator.distanceYards = (Double(loc1.distance(from: loc2)) * 1.09361)
            ballisticCalculator.setBallistics(shooter: shooter, target: target, heading: -1)
            
        }
    }
    
    // Did Update Locations
    // *************************************************************************
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            setWindSock()
            //sinkTextFieldVariables()
        #else
            weatherData.altitude = ((locationManager.location?.altitude)! * 1.09361) * 3
            altitudeTextField.text = String(describing: (((locationManager.location?.altitude)! * 1.09361) * 3))
        #endif
        if(!lockBearing)
        {

        }
        // draw polyline from shooter to target
        //drawShotLine(location: locations[0])
    }
    
    // Render OverLays
    // *************************************************************************
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if let polyline = overlay as? MKGeodesicPolyline
        {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = UIColor.magenta
            let lineDashPatterns: [NSNumber]?  = [2, 4, 2]
            testlineRenderer.lineDashPattern = lineDashPatterns
            testlineRenderer.lineDashPhase = CGFloat(0.87)
            testlineRenderer.lineWidth = 1.5
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
    
    // Info button on Target Popup
    // *************************************************************************
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl)
    {
        alertBallistics(self)
    }
    
    
    // URLRequest Get Weather Weather API
    // *************************************************************************
    func getWeatherForCoordinate()
    {
        guard let coordinate = locationManager.location?.coordinate
            else
        {
            return
        }
        weatherData.setUrl(userLat: String(describing: coordinate.latitude),userLon: String(describing: coordinate.longitude))
        
        let urlRequest = URLRequest(url: weatherData.url!)
        
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
                self.weatherData.initVars(json: weather as [String: AnyObject])
                
            }
            catch
            {
                print("error trying to convert data to JSON")
                self.weatherData.initInvalid()
                return
            }
           
        }
        task.resume()
    }
    
    // URLRequest Get Elevation Google
//     *************************************************************************
    func getElevationForCoordinate()
    {
        guard let coordinate = locationManager.location?.coordinate
            else
        {
            return
        }
        weatherData.setUrl(userLat: String(coordinate.latitude),userLon: String(coordinate.longitude))

        let urlRequest = URLRequest(url: weatherData.alturl!)

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
                self.weatherData.initElevation(json: elevation as [String: AnyObject])
            }
            catch
            {
                print("error trying to convert data to JSON")
                self.weatherData.initAltInvalid()
                return
            }
        }
        task.resume()
    }
    

}

let MERCATOR_OFFSET = 268435456.0
let MERCATOR_RADIUS = 85445659.44705395
let DEGREES = 180.0

extension MKMapView
{
    //MARK: Map Conversion Methods
    private func longitudeToPixelSpaceX(longitude:Double)->Double{
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * Double.pi / DEGREES)
    }
    
    private func latitudeToPixelSpaceY(latitude:Double)->Double{
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * Double.pi / DEGREES)) / (1 - sin(latitude * Double.pi / DEGREES))) / 2.0)
    }
    
    private func pixelSpaceXToLongitude(pixelX:Double)->Double{
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * DEGREES / Double.pi
        
    }
    
    private func pixelSpaceYToLatitude(pixelY:Double)->Double{
        return (Double.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * DEGREES / Double.pi
    }
    
    private func coordinateSpanWithCenterCoordinate(centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double)->MKCoordinateSpan{
        
        // convert center coordiate to pixel space
        let centerPixelX = longitudeToPixelSpaceX(longitude: centerCoordinate.longitude)
        let centerPixelY = latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)
        
        // determine the scale value from the zoom level
        let zoomExponent:Double = 20.0 - zoomLevel
        let zoomScale:Double = pow(2.0, zoomExponent)
        
        // scale the map’s size in pixel space
        let mapSizeInPixels = self.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        // figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2.0)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2.0)
        
        // find delta between left and right longitudes
        let minLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        let maxLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        
        let minLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        let maxLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1.0 * (maxLat - minLat)
        
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    func setCenterCoordinate(centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double, animated:Bool){
        // clamp large numbers to 28
        var zoomLevel = zoomLevel
        zoomLevel = min(zoomLevel, 900)
        
        // use the zoom level to compute the region
        let span = self.coordinateSpanWithCenterCoordinate(centerCoordinate: centerCoordinate, zoomLevel: zoomLevel)
        let region = MKCoordinateRegionMake(centerCoordinate, span)
        if region.center.longitude == -180.00000000{
            print("Invalid Region")
        }
        else{
            self.setRegion(region, animated: animated)
        }
    }
    
    func getZoom() -> Double {
        // function returns current zoom of the map
        
        
        var angleCamera = self.camera.heading
        if angleCamera > 270 {
            angleCamera = 360 - angleCamera
        } else if angleCamera > 90 {
            angleCamera = fabs(angleCamera - 180)
        }
        let angleRad = Double.pi * angleCamera / 180 // camera heading in radians
        let width = Double(self.frame.size.width)
        let height = Double(self.frame.size.height)
        let heightOffset : Double = 20 // the offset (status bar height) which is taken by MapKit into consideration to calculate visible area height
        // calculating Longitude span corresponding to normal (non-rotated) width
        let spanStraight = width * self.region.span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
        return log2(360 * ((width / 256) / spanStraight)) + 1;
    }
}
