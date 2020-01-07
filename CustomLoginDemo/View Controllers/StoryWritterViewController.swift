import UIKit
import Firebase
import CoreLocation

class StoryWritterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var ContentTexts: UITextView!
    
    @IBAction func Submit(_ sender: Any) {
        let db = Firestore.firestore()
        
        
        let locationManager = CLLocationManager()
        let location = locationManager.location?.coordinate
        let lat = location?.latitude
        let lon = location?.longitude
        db.collection("stories").addDocument(data: ["Title":"testTitle","content": ContentTexts.text,"lat":lat,"long":lon])
        goToHome()
    }
    
    func goToHome()  {
        let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
                              
                              self.view.window?.rootViewController = homeViewController
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
