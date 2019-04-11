//
//  EntryViewController.swift
//  TravelogueFinal
//
//  Created by Zachary Pierucci on 4/11/19.
//  Copyright © 2019 Zachary Pierucci. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var entryTableView: UITableView!
    
    var trip: Trip?
    var entries = [Entry]()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = trip?.name ?? ""
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        entryTableView.dataSource = self
        entryTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateEntriesArray()
        entryTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateEntriesArray() {
        entries = trip?.entries?.sortedArray(using: [NSSortDescriptor(key: "title", ascending: true)]) as? [Entry] ?? [Entry]()
    }
    
    func deleteEntry(at indexPath: IndexPath) {
        let entry = entries[indexPath.row]
        
        if let managedObjectContext = entry.managedObjectContext {
            managedObjectContext.delete(entry)
            
            do {
                try managedObjectContext.save()
                self.entries.remove(at: indexPath.row)
                entryTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                alertNotifyUser(message: "Delete failed.")
                entryTableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        
        if let cell = cell as? EntryTableViewCell {
            let entry = entries[indexPath.row]
            cell.tripImageView.image = entry.imageModified
            cell.titleLabel.text = entry.title
            if let modifiedDate = entry.modifiedDate {
                cell.dateLabel.text = dateFormatter.string(from: modifiedDate)
            } else {
                cell.dateLabel.text = "unknown"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") {
            action, index in
            self.deleteEntry(at: indexPath)
        }
        
        return [delete]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NewEntryViewController,
            let segueIdentifier = segue.identifier {
            destination.trip = trip
            if (segueIdentifier == "existingEntry") {
                if let row = entryTableView.indexPathForSelectedRow?.row {
                    destination.entry = entries[row]
                }
            }
        }
    }

}
