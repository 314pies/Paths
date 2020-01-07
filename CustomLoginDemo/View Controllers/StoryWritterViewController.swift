import UIKit
import Firebase
import CoreLocation
import FirebaseFirestore

class StoryWritterViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        TakePicture()
        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var PictureView: UIImageView!
    @IBOutlet weak var ContentTexts: UITextView!
    
    @IBAction func Submit(_ sender: Any) {
        let db = Firestore.firestore()
        
        let storageRef = Storage.storage().reference()
        
        
        let fileReference = Storage.storage().reference().child(UUID().uuidString + ".jpg")
              
              
        if let data = PictureView.image?.jpegData(compressionQuality: 0.9) {
          fileReference.putData(data, metadata: nil) { (_, error) in
              guard error == nil else {
                  print("upload error")
                  return
              }
            print("Upload done")
//              fileReference.downloadURL { (url, error) in
//                  //completion(url)
//              }
          }
        }
        
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

extension StoryWritterViewController: UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    
    
    func TakePicture() {
        let image = UIImagePickerController()
        image.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            image.sourceType = .camera
        }
        else{
            image.sourceType = .savedPhotosAlbum
        }
        image.allowsEditing = true
        self.present(image,animated: true){
            //After is complete
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            PictureView.image = image
        }else{
           //Error
        }
        self.dismiss(animated: true, completion:nil)
    }
}
