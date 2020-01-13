import MapKit
import UIKit
import CoreLocation
import Firebase
import SwiftUI
import CoreData
import QuickLook

protocol StoryWriterDatasourceDelegate {
    var IsViewMode: Bool { get set }
    var Title : String {get set}
    var Content : String {get set}
    var imagePath: String{get set}
}

class HomeViewController: UIViewController, StoryWriterDatasourceDelegate {
    //StoryWriterDatasourceDelegate protocal
    var Content: String = ""
    var Title: String = ""
    var IsViewMode: Bool = false
    var imagePath: String = ""
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeter:Double = 1000
    
    func SaveLocToCoreData(title:String,content:String){
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let student =
            NSEntityDescription.insertNewObject(
                forEntityName: "Location", into: moc)
          as! Location

        student.title = title
        student.content = content
        
        do {
            try moc.save()
            print("Core Data ",content," saved")
        } catch {
            fatalError("\(error)")
        }
        
    }
    @IBAction func ViewRecommendScene(_ sender: Any) {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationService()
        // Do any additional setup after loading the view.
        IsViewMode = false
        
        let db = Firestore.firestore()
        db.collection("stories").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let title : String? = document.data()["Title"] as? String
                    let content : String? = document.data()["content"] as? String
                    let lat : Double? = document.data()["lat"] as? Double
                    let lon : Double? = document.data()["long"] as? Double
                    let imgPath : String? = document.data()["img"] as? String
                    
                    self.SaveLocToCoreData(title: title ?? "",content: content ?? "")
                    
                    if lat != nil && lon != nil{
                        let annotation = CustomPointAnnotation()
                        
                        annotation.title = title
                        annotation.subtitle = title
                        
                        annotation.Title = title
                        annotation.Content = content
                        annotation.imagePath = imgPath
                        annotation.coordinate = CLLocationCoordinate2D(latitude:lat!,longitude: lon!)
                        
                        self.mapView.addAnnotation(annotation)
                        
                    }
                }
                self.centerViewOnUserLocation()
            }
        }
    }
    
    @IBAction func ViewLocation(_ sender: Any) {
        let locationView = LocationsView()
        let host = UIHostingController(rootView: locationView)
        self.view.window?.rootViewController = host
        self.view.window?.makeKeyAndVisible()
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
            
            var latiText: String = "\(location.latitude)"
            var longText: String = "\(location.longitude)"
            FlickrSearch.fetchData(lat: latiText,lon: longText)
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
        
        IsViewMode = false
        let storyWritterViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.storyWritterViewController) as? StoryWritterViewController
        storyWritterViewController?.delegate = self
         self.view.window?.rootViewController = storyWritterViewController
         self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func OnProfileClicked(_ sender: Any) {
        let profileView = ProfileView()
        let host = UIHostingController(rootView: profileView)
        self.view.window?.rootViewController = host
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

extension HomeViewController : QLPreviewControllerDataSource{
    
    
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return FlickrSearch.filePathes.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        print(index)
        return URL(fileURLWithPath: FlickrSearch.filePathes[index]) as QLPreviewItem
//         URL(fileURLWithPath: preItemArr[index] as? String ?? "")
//        return URL(fileURLWithPath: "https://i.stack.imgur.com/G8uj5.png") as QLPreviewItem
        //return "https://i.stack.imgur.com/G8uj5.png"! as QLPreviewItem
    }
    
//    func asd()  {
//
//        NetworkUtility.downloadImage(url: cell.imageURL) { (image) in
//           if cell.imageURL == photo.imageUrl, let image = image  {
//               DispatchQueue.main.async {
//                   cell.photoImageView.image = image
//               }
//           }
//        }
//    }
    
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
        var IsViewMode: Bool!
        var Title : String!
        var Content : String!
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
        if view.annotation is CustomPointAnnotation{
            let cpa = view.annotation as! CustomPointAnnotation
            
            //Set current viewing annotation info
            Title = cpa.title ?? ""
            Content = cpa.Content ?? ""
          
            imagePath = cpa.imagePath ?? ""
            print("annotion clocked: ",Title)
            IsViewMode = true
            //print("cpa img2: ",cpa.imagePath)
            
            let storyWriterController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.storyWritterViewController) as? StoryWritterViewController
            storyWriterController?.delegate = self
            
            self.view.window?.rootViewController = storyWriterController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    
    
}
