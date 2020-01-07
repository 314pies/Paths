import MapKit
import UIKit
import CoreLocation
import Firebase

class HomeViewController: UIViewController {

    
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeter:Double = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationService()
        // Do any additional setup after loading the view.
        
        let db = Firestore.firestore()
        db.collection("stories").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let lat : Double? = document.data()["lat"] as? Double
                    let lon : Double? = document.data()["long"] as? Double
                    let imgPath : String? = document.data()["img"] as? String
                    
                    if lat != nil && lon != nil{
                        let annotation = CustomPointAnnotation()
                        annotation.imagePath = imgPath
                        annotation.coordinate = CLLocationCoordinate2D(latitude:lat!,longitude: lon!)
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
    
    func setUpLocatinManager()  {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation()  {
        print("Centering view on user location")
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location,latitudinalMeters: regionInMeter,longitudinalMeters: regionInMeter)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationService()  {
        if CLLocationManager.locationServicesEnabled(){
            setUpLocatinManager()
            checkLocationAuthentication()
        }else{
            
        }
    }
    
    func checkLocationAuthentication(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
           // mapView.showsUserLocation = true
            centerViewOnUserLocation()
            self.mapView.delegate = self
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        default:
            break
        }
        
    }
    
    @IBAction func StartWritingStory(_ sender: Any) {
        
        let storyWritterViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.storyWritterViewController) as? StoryWritterViewController
         self.view.window?.rootViewController = storyWritterViewController
         self.view.window?.makeKeyAndVisible()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did update called")
        guard let location = locations.last else{return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center,latitudinalMeters: regionInMeter,longitudinalMeters: regionInMeter)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthentication()
    }
}

extension HomeViewController : MKMapViewDelegate{
    class CustomPointAnnotation: MKPointAnnotation {
        var imagePath: String!
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }

        let reuseId = "test"

        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.canShowCallout = true
        }
        else {
            anView?.annotation = annotation as! CustomPointAnnotation
        }

        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...

        let cpa = annotation as! CustomPointAnnotation
        print("cpa img: ",cpa.imagePath)
       
        let a =  UIImage(named:"StoryMaps")
        anView?.image = Utilities.resizeImage(image: a!, targetSize: CGSize(width: 30,height: 30))
        //anView?.image = UIImage(named:"StoryMaps")
        
        return anView
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let cpa = view.annotation as! CustomPointAnnotation
        print("cpa img2: ",cpa.imagePath)
    }
}
