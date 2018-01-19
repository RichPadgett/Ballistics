//
//  BallisticCalculator.swift
//  DropZero-P3
//
//  Created by Richard Padgett on 10/12/16.
//  Copyright © 2016 Richard-Padgett. All rights reserved.
//


import MapKit
import Foundation
import CoreData

class BallisticCalculator
{
    static let shared = BallisticCalculator()
    
    let GRAVITY = -(32.194)
    let _BCOMP_MAXRANGE_ = 50001
    
    func DegtoMOA(deg: Double) -> Double
    {
        return deg*60
    }
    
    func DegtoRad(deg: Double) -> Double
    {
        return deg*Double.pi / 180
    }
    
    func MOAtoDeg(moa: Double) -> Double
    {
        return moa/60
    }
    
    func MOAtoRad(moa: Double) -> Double
    {
        return moa/60*Double.pi/180
    }
    
    func RadtoDeg(rad: Double) -> Double
    {
        return rad*180/Double.pi
    }
    
    func RadtoMOA(rad: Double) -> Double
    {
        return rad*60*180/Double.pi
    }
    
    /// ############## Functions for correcting for atmosphere
    func calcFR(Temperature: Double, Pressure: Double, RelativeHumidity: Double) -> Double
    {
        let VPw=4e-6*pow(Temperature, 3) - 0.0004*pow(Temperature, 2)+0.0234*Temperature-0.2517
        let FRH = 0.995*(Pressure/(Pressure-(0.3783)*(RelativeHumidity)*VPw))
        return FRH
    }
    
    func calcFP(Pressure: Double) -> Double
    {
        let Pstd=29.53 //in-hg
        var FP : Double = 0
        FP = (Pressure - Pstd)/(Pstd)
        return FP
    }
    
    func calcFT(Temperature: Double, Altitude: Double) -> Double
    {
        let Tstd = -0.0036*Altitude+59
        let FT = (Temperature - Tstd)/(459.6+Tstd)
        return FT
    }
    
    func calcFA(Altitude: Double) -> Double{
        var fa : Double = 0
        fa = -4e-15*pow(Altitude, 3)+4e-10*pow(Altitude, 2)-3e-5*Altitude+1
        return (1/fa)
    }
    
    /* Arguments:
     DragCoefficient:  The coefficient of drag for a given projectile.
     Altitude:  The altitude above sea level in feet.  Standard altitude is 0 feet above sea level.
     Barometer:  The barometric pressure in inches of mercury (in Hg).
     This is not "absolute" pressure, it is the "standardized" pressure reported in the papers and news.
     Standard pressure is 29.53 in Hg.
     Temperature:  The temperature in Fahrenheit.  Standard temperature is 59 degrees.
     RelativeHumidity:  The relative humidity fraction.  Ranges from 0.00 to 1.00, with 0.50 being 50% relative humidity.
     Standard humidity is 78%
     
     Return Value:
     The function returns a ballistic coefficient, corrected for the supplied atmospheric conditions.
     */
    // A function to correct a "standard" Drag Coefficient for differing atmospheric conditions.
    // Returns the corrected drag coefficient for supplied drag coefficient and atmospheric conditions.
    func AtmCorrect(DragCoefficient: Double, Altitude: Double, Barometer: Double,
                    Temperature: Double, RelativeHumidity: Double) -> Double{
        let FA = calcFA(Altitude: Altitude)
        let FT = calcFT(Temperature: Temperature, Altitude: Altitude)
        let FR = calcFR(Temperature: Temperature, Pressure: Barometer, RelativeHumidity: RelativeHumidity)
        let FP = calcFP(Pressure: Barometer)
        
        //Calculate the atmospheric correction factor
        let CD = (FA*(1+FT-FP)*FR)
        return DragCoefficient*CD
        
    }
    
    // ############# Functions for correcting for ballistic drag
    func retard(DragFunction: Int, DragCoefficient: Double, Velocity: Double) -> Double{
        
        //	printf("DF: %d, CD: %f, V: %f,)
        
        let vp : Double = Velocity
        var val: Double = -1
        var A : Double = -1
        var M : Double = -1
        
        
        
        switch(DragFunction){
        case 1:
            if (vp > 4230) { A = 1.477404177730177e-04; M = 1.9565; }
            else if (vp > 3680) { A = 1.920339268755614e-04; M = 1.925 ; }
            else if (vp > 3450) { A = 2.894751026819746e-04; M = 1.875 ; }
            else if (vp > 3295) { A = 4.349905111115636e-04; M = 1.825 ; }
            else if (vp > 3130) { A = 6.520421871892662e-04; M = 1.775 ; }
            else if (vp > 2960) { A = 9.748073694078696e-04; M = 1.725 ; }
            else if (vp > 2830) { A = 1.453721560187286e-03; M = 1.675 ; }
            else if (vp > 2680) { A = 2.162887202930376e-03; M = 1.625 ; }
            else if (vp > 2460) { A = 3.209559783129881e-03; M = 1.575 ; }
            else if (vp > 2225) { A = 3.904368218691249e-03; M = 1.55  ; }
            else if (vp > 2015) { A = 3.222942271262336e-03; M = 1.575 ; }
            else if (vp > 1890) { A = 2.203329542297809e-03; M = 1.625 ; }
            else if (vp > 1810) { A = 1.511001028891904e-03; M = 1.675 ; }
            else if (vp > 1730) { A = 8.609957592468259e-04; M = 1.75  ; }
            else if (vp > 1595) { A = 4.086146797305117e-04; M = 1.85  ; }
            else if (vp > 1520) { A = 1.954473210037398e-04; M = 1.95  ; }
            else if (vp > 1420) { A = 5.431896266462351e-05; M = 2.125 ; }
            else if (vp > 1360) { A = 8.847742581674416e-06; M = 2.375 ; }
            else if (vp > 1315) { A = 1.456922328720298e-06; M = 2.625 ; }
            else if (vp > 1280) { A = 2.419485191895565e-07; M = 2.875 ; }
            else if (vp > 1220) { A = 1.657956321067612e-08; M = 3.25  ; }
            else if (vp > 1185) { A = 4.745469537157371e-10; M = 3.75  ; }
            else if (vp > 1150) { A = 1.379746590025088e-11; M = 4.25  ; }
            else if (vp > 1100) { A = 4.070157961147882e-13; M = 4.75  ; }
            else if (vp > 1060) { A = 2.938236954847331e-14; M = 5.125 ; }
            else if (vp > 1025) { A = 1.228597370774746e-14; M = 5.25  ; }
            else if (vp >  980) { A = 2.916938264100495e-14; M = 5.125 ; }
            else if (vp >  945) { A = 3.855099424807451e-13; M = 4.75  ; }
            else if (vp >  905) { A = 1.185097045689854e-11; M = 4.25  ; }
            else if (vp >  860) { A = 3.566129470974951e-10; M = 3.75  ; }
            else if (vp >  810) { A = 1.045513263966272e-08; M = 3.25  ; }
            else if (vp >  780) { A = 1.291159200846216e-07; M = 2.875 ; }
            else if (vp >  750) { A = 6.824429329105383e-07; M = 2.625 ; }
            else if (vp >  700) { A = 3.569169672385163e-06; M = 2.375 ; }
            else if (vp >  640) { A = 1.839015095899579e-05; M = 2.125 ; }
            else if (vp >  600) { A = 5.71117468873424e-05 ; M = 1.950 ; }
            else if (vp >  550) { A = 9.226557091973427e-05; M = 1.875 ; }
            else if (vp >  250) { A = 9.337991957131389e-05; M = 1.875 ; }
            else if (vp >  100) { A = 7.225247327590413e-05; M = 1.925 ; }
            else if (vp >   65) { A = 5.792684957074546e-05; M = 1.975 ; }
            else if (vp >    0) { A = 5.206214107320588e-05; M = 2.000 ; }
            break;
            
        case 2:
            if (vp > 1674 ) { A = 0.0079470052136733   ;  M = 1.36999902851493; }
            else if (vp > 1172 ) { A = 1.00419763721974e-03;  M = 1.65392237010294; }
            else if (vp > 1060 ) { A = 7.15571228255369e-23;  M = 7.91913562392361; }
            else if (vp >  949 ) { A = 1.39589807205091e-10;  M = 3.81439537623717; }
            else if (vp >  670 ) { A = 2.34364342818625e-04;  M = 1.71869536324748; }
            else if (vp >  335 ) { A = 1.77962438921838e-04;  M = 1.76877550388679; }
            else if (vp >    0 ) { A = 5.18033561289704e-05;  M = 1.98160270524632; }
            break
            
            
        case 5:
            if (vp > 1730 ){ A = 7.24854775171929e-03; M = 1.41538574492812; }
            else if (vp > 1228 ){ A = 3.50563361516117e-05; M = 2.13077307854948; }
            else if (vp > 1116 ){ A = 1.84029481181151e-13; M = 4.81927320350395; }
            else if (vp > 1004 ){ A = 1.34713064017409e-22; M = 7.8100555281422 ; }
            else if (vp >  837 ){ A = 1.03965974081168e-07; M = 2.84204791809926; }
            else if (vp >  335 ){ A = 1.09301593869823e-04; M = 1.81096361579504; }
            else if (vp >    0 ){ A = 3.51963178524273e-05; M = 2.00477856801111; }
            break;
            
        case 6:
            if (vp > 3236 ) { A = 0.0455384883480781   ; M = 1.15997674041274; }
            else if (vp > 2065 ) { A = 7.167261849653769e-02; M = 1.10704436538885; }
            else if (vp > 1311 ) { A = 1.66676386084348e-03 ; M = 1.60085100195952; }
            else if (vp > 1144 ) { A = 1.01482730119215e-07 ; M = 2.9569674731838 ; }
            else if (vp > 1004 ) { A = 4.31542773103552e-18 ; M = 6.34106317069757; }
            else if (vp >  670 ) { A = 2.04835650496866e-05 ; M = 2.11688446325998; }
            else if (vp >    0 ) { A = 7.50912466084823e-05 ; M = 1.92031057847052; }
            break;
            
        case 7:
            if (vp > 4200 ) { A = 1.29081656775919e-09; M = 3.24121295355962; }
            else if (vp > 3000 ) { A = 0.0171422231434847  ; M = 1.27907168025204; }
            else if (vp > 1470 ) { A = 2.33355948302505e-03; M = 1.52693913274526; }
            else if (vp > 1260 ) { A = 7.97592111627665e-04; M = 1.67688974440324; }
            else if (vp > 1110 ) { A = 5.71086414289273e-12; M = 4.3212826264889 ; }
            else if (vp >  960 ) { A = 3.02865108244904e-17; M = 5.99074203776707; }
            else if (vp >  670 ) { A = 7.52285155782535e-06; M = 2.1738019851075 ; }
            else if (vp >  540 ) { A = 1.31766281225189e-05; M = 2.08774690257991; }
            else if (vp >    0 ) { A = 1.34504843776525e-05; M = 2.08702306738884; }
            break;
            
        case 8:
            if (vp > 3571 ) { A = 0.0112263766252305   ; M = 1.33207346655961; }
            else if (vp > 1841 ) { A = 0.0167252613732636   ; M = 1.28662041261785; }
            else if (vp > 1120 ) { A = 2.20172456619625e-03; M = 1.55636358091189; }
            else if (vp > 1088 ) { A = 2.0538037167098e-16 ; M = 5.80410776994789; }
            else if (vp >  976 ) { A = 5.92182174254121e-12; M = 4.29275576134191; }
            else if (vp >    0 ) { A = 4.3917343795117e-05 ; M = 1.99978116283334; }
            break;
            
        default:
            break;
        }
        
        if (A != -1 && M != -1 && vp>0 && vp<10000){
            val=A*pow(vp, M)/DragCoefficient
            return val
        }
        else{
            return -1
        }
        
    }
    
    /* Arguments:
     WindSpeed:  The wind velocity in mi/hr.
     Vi:  The initial velocity of the projectile (muzzle velocity).
     x:  The range at which you wish to determine windage, in feet.
     t:  The time it has taken the projectile to traverse the range x, in seconds.
     
     Return Value:
     Returns the amount of windage correction, in inches, required to achieve zero on a target at the given range.
     
     */
    // A function to compute the windage deflection for a given crosswind speed,
    // given flight time in a vacuum, and given flight time in real life.
    // Returns the windage correction needed in inches.
    // Source is in "_windage.c"
    func Windage(WindSpeed: Double, Vi: Double, xx: Double, t: Double) -> Double
    {
        let Vw = WindSpeed*17.60 //Convert to inches per second
        return (Vw*(t-xx/Vi))
    }
    
    /* Arguments:
     WindSpeed:  The wind velocity in mi/hr.
     Vi:  The initial velocity of the projectile (muzzle velocity).
     x:  The range at which you wish to determine windage, in feet.
     t:  The time it has taken the projectile to traverse the range x, in seconds.
     
     Return Value:
     Returns the amount of windage correction, in inches, required to achieve zero on a target at the given range.
     
     */
    // Functions to resolve any wind / angle combination into headwind and crosswind components.
    // Source is in "_windage.c"
    //Headwind is positive at windAngle=0
    func HeadWind(WindSpeed: Double, WindAngle: Double) ->
        Double
    {
        let Wangle = DegtoRad(deg: WindAngle)
        return (cos(Wangle)*WindSpeed)
    }
    
    
    /* Arguments:
     WindSpeed:  The wind velocity, in mi/hr.
     WindAngle:  The angle from which the wind is coming, in degrees.
     0 degrees is from straight ahead
     90 degrees is from right to left
     180 degrees is from directly behind
     270 or -90 degrees is from left to right.
     
     Return value:
     Returns the headwind or crosswind velocity component, in mi/hr.
     */
    // Positive is from Shooters Right to Left (Wind from 90 degree)
    func CrossWind(WindSpeed: Double, WindAngle: Double) -> Double
    {
        let Wangle = DegtoRad(deg: WindAngle)
        return (sin(Wangle)*WindSpeed)
    }
    
    /*  Arguments:
     DragFunction:  The drag function to use (G1, G2, G3, G5, G6, G7, G8)
     DragCoefficient:  The coefficient of drag for the projectile, for the supplied drag function.
     Vi:  The initial velocity of the projectile, in feet/s
     SightHeight:  The height of the sighting system above the bore centerline, in inches.
     Most scopes fall in the 1.6 to 2.0 inch range.
     ZeroRange:  The range in yards, at which you wish the projectile to intersect yIntercept.
     yIntercept:  The height, in inches, you wish for the projectile to be when it crosses ZeroRange yards.
     This is usually 0 for a target zero, but could be any number.  For example if you wish
     to sight your rifle in 1.5" high at 100 yds, then you would set yIntercept to 1.5, and ZeroRange to 100
     
     Return Value:
     Returns the angle of the bore relative to the sighting system, in degrees.
     */
    func ZeroAngle(DragFunction: Int, DragCoefficient: Double, Vi: Double,
                   SightHeight: Double, ZeroRange: Double, yIntercept: Double) -> Double
    {
        
        // Numerical Integration variables
        var t : Double = 0
        var dt = 1/Vi// The solution accuracy generally doesn't suffer if its within a foot for each second of time.
        var y = -(SightHeight/12)
        var x : Double = 0
        var da : Double // The change in the bore angle used to iterate in on the correct zero angle.
        
        //State variables for each integration loop.
        var v : Double = 0//Velocity
        var vx : Double = 0
        var vy : Double = 0
        
        var vx1 : Double = 0//Last Frames velocity, used for computing average velocity
        var vy1 : Double = 0
        
        var dv : Double = 0//Acceleration
        var dvx : Double = 0
        var dvy : Double = 0
        
        var Gx : Double = 0//Gravitational acceleration
        var Gy : Double = 0
        
        var angle : Double = 0//actual angle of the bore
        
        var quit : Int = 0 // We know to quit our successive approximation when this is 1
        
        // Start with a very coarse angular change, to quickly solve even large launch angle problems.
        da = DegtoRad(deg: 14)
        
        // The general idea here is to start at 0 degrees elevation, and increase the elevation by 14 degrees
        // until we are above the correct elevation.  Then reduce the angular change by half, and begin reducing
        // the angle.  Once we are again below the correct angle, reduce the angular change by half again, and go
        // back up.  This allows for a fast successive approximation of the correct elevation, usually within less
        // than 20 iterations
        
        //for (angle=0; quit == 0; angle=angle+da){
        angle = 0
        while(quit==0)
        {
            angle=angle+da
            
            vy=Vi*sin(angle);
            vx=Vi*cos(angle);
            Gx=GRAVITY*sin(angle);
            Gy=GRAVITY*cos(angle);
            
            //for (t=0,x=0,y = -(SightHeight/12); x<=ZeroRange*3; t=t+dt){
            t=0
            x=0
            y = -(SightHeight/12)
            while(x<ZeroRange*3)
            {
                t=t+dt
                
                vy1=vy;
                vx1=vx;
                v=pow((pow(vx,2)+pow(vy,2)),0.5);
                dt=1/v;
                
                dv = retard(DragFunction: DragFunction, DragCoefficient: DragCoefficient, Velocity: v);
                dvy = -(dv*vy/v*dt);
                dvx = -(dv*vx/v*dt);
                
                vx=vx+dvx;
                vy=vy+dvy;
                vy=vy+dt*Gy;
                vx=vx+dt*Gx;
                
                x=x+dt*(vx+vx1)/2;
                y=y+dt*(vy+vy1)/2;
                // Break early to save CPU time if we won't find a solution.
                if (vy<0 && y<yIntercept) {
                    break;
                }
                if (vy>3*vx) {
                    break;
                }
            }
            
            if (y>yIntercept && da>0){
                da = -(da/2);
            }
            
            if (y<yIntercept && da<0){
                da = -(da/2);
            }
            
            if (fabs(da) < MOAtoRad(moa: 0.01)){
                quit=1; // If our accuracy is sufficient, we can stop approximating.
                
            }
            if (angle > DegtoRad(deg: 45)){
                quit=1; // If we exceed the 45 degree launch angle, then the projectile just won't get there, so we stop trying.
            }
            
        }
        
        return RadtoDeg(rad: angle); // Convert to degrees for return value.
    }
    
    /* Arguments:
     DragFunction:  The drag function you wish to use for the solution (G1, G2, G3, G5, G6, G7, or G8)
     DragCoefficient:  The coefficient of drag for the projectile you wish to model.
     Vi:  The projectile initial velocity.
     SightHeight:  The height of the sighting system above the bore centerline.
     Most scopes are in the 1.5"-2.0" range.
     ShootingAngle:  The uphill or downhill shooting angle, in degrees.  Usually 0, but can be anything from
     90 (directly up), to -90 (directly down).
     ZeroAngle:  The angle of the sighting system relative to the bore, in degrees.  This can be easily computed
     using the ZeroAngle() function documented above.
     WindSpeed:  The wind velocity, in mi/hr
     WindAngle:  The angle at which the wind is approaching from, in degrees.
     0 degrees is a straight headwind
     90 degrees is from right to left
     180 degrees is a straight tailwind
     -90 or 270 degrees is from left to right.
     Solution:	A pointer provided for accessing the solution after it has been generated.
     Memory for this pointer is allocated in the function, so the user does not need
     to worry about it.  This solution can be passed to the retrieval functions to get
     useful data from the solution.
     Return Value:
     This function returns an integer representing the maximum valid range of the
     solution.  This also indicates the maximum number of rows in the solution matrix,
     and should not be exceeded in order to avoid a memory segmentation fault.
     
     */
    // A function to generate a ballistic solution table in 1 yard increments, up to __BCOMP_MAXRANGE__.
    // Source is in "_solve.c
    //The Solve-All Solution
    func SolveAll(DragFunction: Int, DragCoefficient: Double, Vi: Double, SightHeight: Double, projectileWeight: Int,
                  ShootingAngle: Double, ZAngle: Double, WindSpeed: Double, WindAngle: Double,
                  Start: Int, Stop: Int) -> [Double]{
        
        
        
        
        //A Pointer here Array
        var retArray : [Double] = []
        
        var t : Double = 0
        var dt : Double = 0.5/Vi
        var v : Double = 0
        var vx : Double = 0
        var vx1 : Double = 0
        var vy : Double = 0
        var vy1 : Double = 0
        var dv : Double = 0
        var dvx : Double = 0
        var dvy : Double = 0
        var x : Double = 0
        var y : Double = 0
        //var moa : Double = 0
        
        let headwind = HeadWind(WindSpeed: WindSpeed, WindAngle: WindAngle)
        let crosswind = CrossWind(WindSpeed: WindSpeed, WindAngle: WindAngle)
        
        let Gy=GRAVITY*(cos(DegtoRad(deg: (ShootingAngle + ZAngle))))
        let Gx=GRAVITY*(sin(DegtoRad(deg: (ShootingAngle + ZAngle))))
        
        vx = Vi*cos(DegtoRad(deg: ZAngle))
        vy = Vi*sin(DegtoRad(deg: ZAngle))
        
        y = -(SightHeight/12)
        
        var n : Int = Start
       // for (t=0;;t=t+dt)
        t=0
        while(true)
        {
            t = t+dt
            
            
            vx1=vx
            vy1=vy
            v=pow(pow(vx,2)+pow(vy,2),0.5)
            dt=0.5/v
            
            //Compute accelleration using the drag function retardation
            dv = retard(DragFunction: DragFunction, DragCoefficient: DragCoefficient, Velocity: v+headwind)
            dvx = -(vx/v)*dv
            dvy = -(vy/v)*dv
            
            vx = vx + dt*dvx + dt*Gx
            vy = vy + dt*dvy + dt*Gy
            
            if (Int(x/3) >= n){
                
                retArray.append(x/3)
                retArray.append(y*12)
                retArray.append(-RadtoMOA(rad: atan(y/x)))
                //moa = (-RadtoMOA(rad: atan(y/x)))
                retArray.append(t+dt)
                retArray.append(Windage(WindSpeed: crosswind,Vi: Vi,xx: x,t: t+dt))
                retArray.append(RadtoMOA(rad: atan(((
                    Windage(WindSpeed: crosswind,Vi: Vi,xx: x,t: t+dt))/12)/((x/3)*3))))
                retArray.append(v)
                retArray.append(vx)
                retArray.append(vy)
                
                n = n+1
                if(Start >= Stop){
                    break
                }
            }
            
            // Compute position based on average velocity.
            x=x+dt*(vx+vx1)/2;
            y=y+dt*(vy+vy1)/2;
            
            if (fabs(vy)>fabs(3*vx)){
                break;
            }
            if (n >= _BCOMP_MAXRANGE_+1){
                break;
            }
        }
        let weight = Double(projectileWeight)
        if(retArray != []){
            let velocity = Double(retArray[6])
        
        //Appending Energy of Bullet at element 10
        retArray.append(Double(weight*velocity*velocity)/450436)
        /*ptr[10*_BCOMP_MAXRANGE_+1]=(double)n;
         return retArray;
         *Solution = ptr;*/
        }
        else{
            retArray.append(0)
            retArray.append(0)
            retArray.append(0)
            retArray.append(0)
            retArray.append(0)
            retArray.append(0)
            retArray.append(0)
            retArray.append(0)
            retArray.append(0)
        }
        return retArray;
    }
    
    
    // Helpers
    //**************************************************************************
    
    var results : [Double] = []
    
    var zeroangle : Double = -1
    var altitude : Double = 0 //measured in feet
    var opposite : Double = 0
    var barometer : Double = 29.53 //measured in Hg
    var temperature : Double = 59 //measured in F
    var relativeHumidity : Double = 78/100 //measured in %
    var hypotenuse : Double = 0
    var distinMeters : Double = 0
    var distanceYds : Double = 0
    var projectileWeight : Int = 168
    
    var bc : Double = -1// The ballistic coefficient for the projectile.
    var v : Double = -1// Intial velocity, in ft/s
    var sh : Double = -1// The Sight height over bore, in inches.
    var angle : Double = -1// The shooting angle (uphill / downhill), in degrees.
    var zero : Double = -1// The zero range of the rifle, in yards.
    var windspeed : Double = -1 // The wind speed in miles per hour.
    var windangle : Double = -1// The wind angle (0=headwind, 90=right to left, 180=tailwind, 270/-90=left to right)
    var df : Int = 0
    var numRows : Int = 0
    var bearing : Double = 0
    var pressure : Double = 0
    var humidity : Double = 0

    var targetheight : Double = 0
    var shooterheight : Double = 0
    
    var windOn = true
    var environmentOn = true
    var altitudeOn = true
    
    //====================================================================
    func get_heading1(lat1: Double,lon1: Double,lat2: Double,lon2: Double)
        -> Double
    {
            
            //var diff_lat: Double = 0
            var diff_long: Double = 0
            var degree: Double = 0
            
            diff_long = DegtoRad(deg: (((lon2*1000000)-(lon1*1000000))/1000000))
            
            //diff_lat =  ballisticCalculation.DegtoRad((((lat2*1000000)-(lat1*1000000))/1000000))
            
            degree = RadtoDeg(rad: ((atan2(sin(diff_long)*cos( DegtoRad(deg: lat2)),cos( DegtoRad(deg: lat1))*sin( DegtoRad(deg: lat2))-sin( DegtoRad(deg: lat1))*cos( DegtoRad(deg: lat2))*cos(diff_long)))))
            
            if (degree >= 0)
            {
                return degree;
            }
            else
            {
                return 360+degree;
            }
    }
    
    //====================================================================
    func setBallistics(shooter: CLLocationCoordinate2D, target: CLLocationCoordinate2D)
    {
                //self.bc = GlobalSelectionModel.ballisticCoefficient
        
//                if(GlobalSelectionModel.chronograph != 0)
//                {
//                    self.v = Double(GlobalSelectionModel.chronograph)
//                }
//                else
//                {
//                    self.v = Double(GlobalSelectionModel.muzzleVelocity)
//                }
                //self.sh = GlobalSelectionModel.sightHeight
                //self.zero = Double(GlobalSelectionModel.zeroRange)
        
                //df is drag Function G1 - G8
                
                self.df = 4//GlobalSelectionModel.DragFunc
                
                
                //Set the Windage Factors
                if(windOn)
                {
                    var wAngle: Double = 0
                    var angle: Double = 0
                    windspeed = Double(WeatherData.GlobalData.windspeed)!
                    wAngle = Double(WeatherData.GlobalData.direction)!
                    
                    
                    let shotHeading = get_heading1(lat1: shooter.latitude, lon1: shooter.longitude, lat2: target.latitude, lon2: target.longitude)
                    
                    if(shotHeading > 180)
                    {
                        angle = 360 - shotHeading
                        windangle = (wAngle - 180) + angle
                    }
                    else
                    {
                        angle = 180 - shotHeading
                        windangle = (wAngle - 360) + angle
                    }
                    if(windangle < 0)
                    {
                        windangle = windangle + 360
                    }
                    
                }
                else
                {//Use Standard Temperature Pressure
                    windspeed = 0
                    windangle = 0
                }
                
                //Set the Environmental Factors
                if(environmentOn)
                {
                    altitude = Double(WeatherData.GlobalData.altitude)! //measured in feet
                    if(WeatherData.GlobalData.pressure != "NaN")
                    {
                        barometer = Double(WeatherData.GlobalData.pressure)! //measured in Hg
                    }
                    else
                    {
                        barometer = 29.53 //measured in Hg
                    }
                    if(WeatherData.GlobalData.temperatureF != "NaN")
                    {
                        temperature = Double(WeatherData.GlobalData.temperatureF)! //measured in F
                    }
                    else
                    {
                        temperature = 59 //measured in F
                    }
                    if(WeatherData.GlobalData.humidity != "NaN")
                    {
                        relativeHumidity = (Double(WeatherData.GlobalData.humidity)!/100) //measured in %
                    }
                    else
                    {
                        relativeHumidity = 78/100 //measured in %
                    }
                }
                else
                {
                    altitude = 0 //measured in feet
                    barometer = 29.53 //measured in Hg
                    temperature = 59 //measured in F
                    relativeHumidity = 78/100 //measured in %
                }
                
                
                bc = AtmCorrect(DragCoefficient: bc, Altitude: altitude,
                                                Barometer: barometer,
                                                Temperature: temperature,
                                                RelativeHumidity: relativeHumidity)
                
                
                // Find the zero angle of the bore relative to the sighting system.
                zeroangle = ZeroAngle(DragFunction: df, DragCoefficient: bc,
                                                      Vi: v, SightHeight: sh,
                                                      ZeroRange: zero,
                                                      yIntercept: 0)

                if(distanceYds > 0 && bc != -1 && v != -1 && sh != -1)
                {
                    if(altitudeOn)
                    {
                        
                        // shootingAngle.text = String(format: "%.0f", angle) + "\u{00B0}"
                        
                        self.results = SolveAll(DragFunction: df, DragCoefficient: bc, Vi: v, SightHeight: sh, projectileWeight: projectileWeight,
                                                                                ShootingAngle: angle, ZAngle: zeroangle, WindSpeed: windspeed, WindAngle: windangle,
                                                                                Start: Int(distanceYds), Stop: Int(distanceYds))
                        
                        //  MoA.text = String(format: "%.2lf \u{2195}", GlobalSelectionModel.Results[2])
                        // WMoA.text = String(format: "%.2lf \u{2194}", GlobalSelectionModel.Results[5])
                        
                        
                    }
                    else
                    {
                        //shootingAngle.text = "0.0" + "\u{00B0}"
                        
                        // Generate a solution using the GNU Ballistics library call.
                        self.results = SolveAll(DragFunction: df, DragCoefficient: bc, Vi: v, SightHeight: sh, projectileWeight: projectileWeight,
                                                                                ShootingAngle: 0, ZAngle: zeroangle, WindSpeed: windspeed, WindAngle: windangle,
                                                                                Start: Int(distanceYds), Stop: Int(distanceYds))
                        
                        //MoA.text = String(format: "%.2lf \u{2195}", GlobalSelectionModel.Results[2])
                        //WMoA.text = String(format: "%.2lf \u{2194}", GlobalSelectionModel.Results[5])
                    }

                }
    }
    
    func resetDistance()
    {
        if(GlobalSelectionModel.imperial)
        {
            distanceYds = (Double(distinMeters) * 1.09361)
        }
        else
        {
            distanceYds = (Double(distinMeters) * 1.09361)
        }
        if(altitudeOn)
        {
            angleset()
        }
    }
    
    func angleset()
    {
        if(altitudeOn)
        {
            shooterheight = Double(WeatherData.GlobalData.altitude)!
            if(targetheight > shooterheight){
                opposite = (targetheight - shooterheight)
                
                hypotenuse = sqrt(pow((Double(distinMeters) * 1.09361),2) + pow(opposite,2))
                
                if(hypotenuse > (Double(distinMeters) * 1.09361))
                {
                    
                    distanceYds = hypotenuse
                    angle = asin(opposite/distanceYds)
                    angle = RadtoDeg(rad: angle)
                    if(GlobalSelectionModel.imperial)
                    {
                        // distance.text = String(format: "%.2lf ",(hypotenuse) + distanceOffset) + " yds^"
                    }
                    else
                    {
                        //distance.text = String(format: "%.2lf ",(hypotenuse * 0.9144) + distanceOffset) + " m^"
                    }
                }
                else
                {
                    
                    distanceYds = (Double(distinMeters) * 1.09361)
                    angle = atan(opposite/distanceYds)
                    angle = RadtoDeg(rad: angle)
                    if(GlobalSelectionModel.imperial){
                        //distance.text = String(format: "%.2lf ",(Double(distinMeters) * 1.09361) + distanceOffset) + " yds"
                    }
                    else
                    {
                        //distance.text = String(format: "%.2lf ",(Double(distinMeters)) + distanceOffset) + " m"
                    }
                }
            }
            else
            {
                opposite = (shooterheight - targetheight)
                
                hypotenuse = sqrt(pow((Double(distinMeters) * 1.09361),2) + pow(opposite,2))
                
                if(hypotenuse > (Double(distinMeters) * 1.09361))
                {
                    
                    distanceYds = hypotenuse
                    angle = -(asin(opposite/distanceYds))
                    angle = RadtoDeg(rad: angle)
                    if(GlobalSelectionModel.imperial)
                    {
                        //distance.text = String(format: "%.2lf ",(hypotenuse) + distanceOffset) + " yds^"
                    }
                    else
                    {
                        //distance.text = String(format: "%.2lf ",(hypotenuse * 0.9144) + distanceOffset) + " m^"
                    }
                }
                else
                {
                    
                    distanceYds = (Double(distinMeters) * 1.09361)
                    angle = -(atan(opposite/distanceYds))
                    angle = RadtoDeg(rad: angle)
                    if(GlobalSelectionModel.imperial)
                    {
                        //distance.text = String(format: "%.2lf ",(Double(distinMeters) * 1.09361) + distanceOffset) + " yds"
                    }
                    else
                    {
                        //distance.text = String(format: "%.2lf ",(Double(distinMeters)) + distanceOffset) + " m"
                    }
                }
            }
        }
    }
    
    func saveCoreData()
    {
        let timestamp = NSDate().timeIntervalSince1970
        ballisticsEntity.setValue(timestamp, forKey: "date")
        do
        {
        try context.save()
            print("entity saved" + String(describing: ballisticsEntity))
        }
        catch
        {
        print("Failed saving")
        }
    }
    
    func setValue(type: String, variable: String)
    {
        switch type
        {
        case "USER_BEARING":
            self.bearing = Double(variable)!
        case "TARGET_DISTANCE":
            self.distanceYds = Double(variable)!
            self.distinMeters = distanceYds / 1.09361
            ballisticsEntity.setValue(self.distanceYds, forKey: "distanceYds")
        case "ZERO_RANGE":
            self.zero = Double(variable)!
            ballisticsEntity.setValue(self.zero, forKey: "zeroRange")
        case "SIGHT_HEIGHT":
            self.sh = Double(variable)!
            ballisticsEntity.setValue(self.sh, forKey: "sightHeight")
        case "BALLISTIC_COEFFICIENT":
            self.bc = Double(variable)!
            ballisticsEntity.setValue(self.bc, forKey: "ballisticCoefficient")
        case "PROJECTILE_WEIGHT":
            self.projectileWeight = Int(variable)!
            ballisticsEntity.setValue(self.projectileWeight, forKey: "weight")
        case "MUZZLE_VELOCITY":
            self.v = Double(variable)!
            ballisticsEntity.setValue(self.v, forKey: "muzzleVelocity")
        case "OUTSIDE_TEMPERATURE":
            self.temperature = Double(variable)!
        case "WIND_SPEED":
            self.windspeed = Double(variable)!
        case "WIND_DIRECTION":
            self.windangle = Double(variable)!
        case "ALTITUDE":
            self.altitude = Double(variable)!
        default:
            break
        }
        
        saveCoreData()
    }
}

