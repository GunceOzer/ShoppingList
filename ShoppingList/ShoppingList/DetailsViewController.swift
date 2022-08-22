//
//  DetailsViewController.swift
//  ShoppingList
//
//  Created by Günce Özer on 18.08.2022.
//
import CoreData
import UIKit

class DetailsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var chosenProductName = ""
    var chosenProductId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(closeKeyboard) )
        view.addGestureRecognizer(gestureRecognizer)
        
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        view.addGestureRecognizer(imageGestureRecognizer)
        
        if chosenProductName != ""{
            
            saveButton.isHidden = true
            
            if let uuidString = chosenProductId?.uuidString
            {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0
                    {
                        
                        for result in results as! [NSManagedObject]{
                            if let name = result.value(forKey: "name") as? String{
                                nameTextField.text = name
                            }
                            if let price = result.value(forKey: "price") as? Int{
                                priceTextField.text = String(price)
                            }
                            if let size = result.value(forKey: "size") as? String{
                                sizeTextField.text = size
                            }
                            if let imageData = result.value(forKey: "image") as? Data{
                                let image = UIImage(data: imageData)
                                imageView.image = image
                            }
                        }
                        
                    }
                }catch{
                    print("An error occurred")
                }
            }
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameTextField.text = ""
            priceTextField.text = ""
            sizeTextField.text = ""
        }

        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func chooseImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        
    }
    
    @objc func closeKeyboard(){
        view.endEditing(true)
    }
    

    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let _shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        
        _shopping.setValue(nameTextField.text!, forKey: "name")
        _shopping.setValue(sizeTextField.text!, forKey: "size")
        
        if let price = Int(priceTextField.text!){
            _shopping.setValue(price, forKey: "price")
        }
        
        _shopping.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        _shopping.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("SAVED")
        }catch{
            print("An error occured")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataEntered"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
}
