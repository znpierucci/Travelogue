//
//  TripViewController.swift
//  TravelogueFinal
//
//  Created by Zachary Pierucci on 4/11/19.
//  Copyright © 2019 Zachary Pierucci. All rights reserved.
//

import UIKit
import CoreData

class TripViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tripTableView: UITableView!
    
    var trips = [Trip]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Trips"
        
        tripTableView.dataSource = self
        tripTableView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchTrips(searchString: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func add(_ sender: Any) {
        let alert = UIAlertController(title: "Add Trip", message: "Enter new trip name.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertAction.Style.default, handler: {
            (alertAction) -> Void in
            if let textField = alert.textFields?[0], let name = textField.text {
                let tripName = name.trimmingCharacters(in: .whitespaces)
                if (tripName == "") {
                    self.alertNotifyUser(message: "Trip not created.\nThe name must contain a value.")
                    return
                }
                self.addTrip(name: tripName)
            } else {
                self.alertNotifyUser(message: "Trip not created.\nThe name is not accessible.")
                return
            }
            
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "trip name"
            textField.isSecureTextEntry = false
            
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func edit(at indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        let alert = UIAlertController(title: "Edit Trip", message: "Enter new trip name.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertAction.Style.default, handler: {
            (alertAction) -> Void in
            if let textField = alert.textFields?[0], let name = textField.text {
                let tripName = name.trimmingCharacters(in: .whitespaces)
                if (tripName == "") {
                    self.alertNotifyUser(message: "Trip name not changed.\nA name is required.")
                    return
                }
                
                if (tripName == trip.name) {
                    return
                }
                
                if (self.tripExists(name: tripName)) {
                    self.alertNotifyUser(message: "Trip name not changed.\n\(tripName) already exists.")
                    return
                }
                
                self.updateTrip(at: indexPath, name: tripName)
            } else {
                self.alertNotifyUser(message: "Trip name not changed.\nThe name is not accessible.")
                return
            }
            
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "trip name"
            textField.isSecureTextEntry = false
            textField.text = trip.name
            
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addTrip(name: String) {
        if (tripExists(name: name)) {
            alertNotifyUser(message: "Trip \(name) already exists.")
            return
        }
        
        let trip = Trip(name: name)
        
        if let trip = trip {
            do {
                let managedObjectContext = trip.managedObjectContext
                try managedObjectContext?.save()
            } catch {
                print("Trip could not be saved.")
            }
        } else {
            print("Trip could not be created.")
        }
        
        fetchTrips(searchString: "")
    }
    
    func fetchTrips(searchString: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            if (searchString != "") {
                fetchRequest.predicate = NSPredicate(format: "name contains[c] %@", searchString)
            }
            trips = try managedContext.fetch(fetchRequest)
            tripTableView.reloadData()
        } catch {
            print("Fetch could not be performed")
        }
    }
    
    func tripExists(name: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, name != "" else {
            return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        do {
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
            let results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func confirmDeleteTrip(at indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        
        if let entrySet = trip.entries, entrySet.count > 0 {
            // confirm deletion
            let name = trip.name ?? "Trip"
            let alert = UIAlertController(title: "Delete Trip", message: "\(name) contains entries. Do you want to delete it?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
                (alertAction) -> Void in
                // handle cancellation of deletion
                self.tripTableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: {
                (alertAction) -> Void in
                // handle deletion here
                self.deleteTrip(at: indexPath)
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            deleteTrip(at: indexPath)
        }
    }
    
    func deleteTrip(at indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        
        if let managedObjectContext = trip.managedObjectContext {
            managedObjectContext.delete(trip)
            
            do {
                try managedObjectContext.save()
                self.trips.remove(at: indexPath.row)
                tripTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Delete failed: \(error).")
                tripTableView.reloadData()
            }
        }
    }
    
    func updateTrip(at indexPath: IndexPath, name: String) {
        let trip = trips[indexPath.row]
        trip.name = name
        
        if let managedObjectContext = trip.managedObjectContext {
            do {
                try managedObjectContext.save()
                fetchTrips(searchString: "")
            } catch {
                print("Update failed.")
                tripTableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath)
        
        let trip = trips[indexPath.row]
        cell.textLabel?.text = trip.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") {
            action, index in
            self.confirmDeleteTrip(at: indexPath)
        }
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") {
            action, index in
            self.edit(at: indexPath)
        }
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EntryViewController,
            let row = tripTableView.indexPathForSelectedRow?.row {
            destination.trip = trips[row]
        }
    }

}
