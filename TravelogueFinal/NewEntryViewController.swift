//
//  NewEntryViewController.swift
//  TravelogueFinal
//
//  Created by Zachary Pierucci on 4/11/19.
//  Copyright © 2019 Zachary Pierucci. All rights reserved.
//

import UIKit

class NewEntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var entryDatePicker: UIDatePicker!
    
    var entry: Entry?
    var trip: Trip?
    var image: UIImage?
    var date: Date?
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        contentTextView.layer.cornerRadius = 6.0
        
        if let entry = entry {
            let name = entry.title
            titleTextField.text = name
            contentTextView.text = entry.content
            title = name
            entryDatePicker.date = entry.modifiedDate!
            image = entry.imageModified
            entryImageView.image = image
        } else {
            titleTextField.text = ""
            contentTextView.text = ""
            entryImageView.image = nil
        }
        
        date = entryDatePicker.date
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectImageSource() {
        let alert = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            (alertAction) in
            self.takePhotoUsingCamera()
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            (alertAction) in
            self.selectPhotoFromLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func takePhotoUsingCamera() {
        if (!UIImagePickerController.isSourceTypeAvailable(.camera)) {
            alertNotifyUser(message: "This device has no camera.")
            return
        }
        
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    func selectPhotoFromLibrary() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            imagePickerController.dismiss(animated: true, completion: nil)
        }
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        image = selectedImage
        entryImageView.image = image
        if let entry = entry {
            entry.imageModified = selectedImage
        }
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let name = titleTextField.text else {
            alertNotifyUser(message: "Entry not saved.\nThe name is not accessible.")
            return
        }
        
        let entryName = name.trimmingCharacters(in: .whitespaces)
        if (entryName == "") {
            alertNotifyUser(message: "Entry not saved.\nA name is required.")
            return
        }
        
        let content = contentTextView.text
        
        if entry == nil {
            if let trip = trip {
                entry = Entry(title: entryName, content: content, date: date ?? Date(timeIntervalSinceNow: 0), image: image, trip: trip)
            }
        } else {
            if let trip = trip {
                entry?.update(title: entryName, content: content, date: date!, image: image, trip: trip)
            }
        }
        
        if let entry = entry {
            do {
                let managedContext = entry.managedObjectContext
                try managedContext?.save()
            } catch {
                alertNotifyUser(message: "Entry not saved.\nAn error occured saving context.")
            }
        } else {
            alertNotifyUser(message: "Entry not saved.\nAn entry entity could not be created.")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        title = titleTextField.text
    }
    
    @IBAction func selectImage(_ sender: Any) {
        selectImageSource()
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        date = entryDatePicker.date
    }
    
}
