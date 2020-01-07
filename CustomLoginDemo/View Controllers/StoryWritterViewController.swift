import UIKit
import Firebase
import CoreLocation
import FirebaseFirestore

class StoryWritterViewController: UIViewController {
    
    var delegate: StoryWriterDatasourceDelegate?
    
    var fireStoreImagePath:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireStoreImagePath = ""
        PictureView.image = nil
        if delegate!.IsViewMode{
            //ContentTexts.text = delegate!.Title + "\n"
            ContentTexts.text += delegate!.Content
            fireStoreImagePath = delegate!.imagePath
            

            // Create a storage reference from our storage service
            let storageRef =  Storage.storage().reference()
            let islandRef = storageRef.child(fireStoreImagePath)

            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            islandRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
              if let error = error {
                // Uh-oh, an error occurred!
                print("getData failed: ",error)
              } else {
                  print("getData sucess: ")
                // Data for image is returned
                let image = UIImage(data: data!)
                self.PictureView.image = image
              }
            }
            
        }else{
             TakePicture()
        }
        ContentTexts.isEditable =  !delegate!.IsViewMode
        SubmitButton.isHidden = delegate!.IsViewMode
        BackButton.isHidden = !delegate!.IsViewMode
        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var PictureView: UIImageView!
    @IBOutlet weak var ContentTexts: UITextView!
    
    
    @IBAction func Submit(_ sender: Any) {
        let db = Firestore.firestore()
        
        let storageRef = Storage.storage().reference()
        
        fireStoreImagePath = UUID().uuidString + ".jpg"
        let fileReference = Storage.storage().reference().child(fireStoreImagePath)
        
            
              
        if let data = PictureView.image?.jpegData(compressionQuality: 0.9) {
          fileReference.putData(data, metadata: nil) { (_, error) in
              guard error == nil else {
                  print("upload error")
                  return
              }
            var title = ""
            
            if self.ContentTexts.text.lines.count > 0{
                title = self.ContentTexts.text.lines[0]
            }
            
            print("Upload done")
            let locationManager = CLLocationManager()
                           let location = locationManager.location?.coordinate
                           let lat = location?.latitude
                           let lon = location?.longitude
            db.collection("stories").addDocument(data: ["Title":title,"content": self.ContentTexts.text,"lat":lat,"long":lon,"img":self.fireStoreImagePath]){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added ")
                    self.goToHome()
                }
            }
            
//              fileReference.downloadURL { (url, error) in
//                print("url: ", url!)
//
//                let locationManager = CLLocationManager()
//                let location = locationManager.location?.coordinate
//                let lat = location?.latitude
//                let lon = location?.longitude
//                db.collection("stories").addDocument(data: ["Title":title,"content": self.ContentTexts.text,"lat":lat,"long":lon,"img":imagePathg])
//                self.goToHome()
              //}
          }
        }
        
        
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
    
    @IBAction func BacktoHome(_ sender: Any) {
        goToHome()
    }
    
    
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
