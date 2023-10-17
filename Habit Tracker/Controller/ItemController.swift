//
//  ItemController.swift
//  Habit Tracker
//
//  Created by Dennis Münchow on 14.10.23.
//

import UIKit
import CoreData

class ItemController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    let date: Date = Date(timeIntervalSinceReferenceDate: 625_000)
    
    var selectedCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedCategory
        
        loadItems()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemsCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        // TERNARY OPERATOR:
        // value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, dd, YYYY"
        
        cell.detailTextLabel?.text = formatter.string(from: date)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selectedArray[indexPath.row].done = !selectedArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add New Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "goToAddItem", sender: self)

        
      //  var textField = UITextField()
      //  let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
      //
      //  alert.addTextField { (alertTextField) in
      //      alertTextField.placeholder = "Create a new item"
      //      textField = alertTextField
      //  }
      //
      //  let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
      //      let newItem = Item(context: self.context)
      //      newItem.title = textField.text!
      //      newItem.done = false
      //      newItem.category = self.selectedCategory
      //
      //      self.itemArray.append(newItem)
      //      self.saveItems()
      //      print(newItem.category)
      //  }
      //
      //  alert.addAction(action)
      //  self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model Mamipulation Methods
    
    func saveItems () {
        do {
            try context.save()
        } catch {
            print("Error saving contect \(error)")
        }
        tableView.reloadData()
    }
    
    
    
    // Funktion mit zwei Parametern: 01: request , 02: predicate
    // 01 vom Typ Fetch-Request-Objeckt vom Typ NSFetchRequest<HealthItem>, Standardwert = Healthitem.fetchRequest()
    // 02 vom Typ optionales NSPredicate, Standardwert = nil
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
 
        // Filterung: Name der parentCategory MIT Name der selectedCategory
        request.predicate = NSPredicate(format: "category MATCHES %@", selectedCategory!)
 
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}



// MARK: - UISearchBar

extension ItemController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // erstellt ein Request
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        // Filter-Query: %@ = searchBar.text, suche nach Item dessen Titel %@ enthält
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // Request + Filter-Query
        request.predicate = predicate
        
        // Sortierung nach title
        request.sortDescriptors  = [NSSortDescriptor(key: "title", ascending: true)]
        
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    // Verhalten, wenn SearchBar cleared wird
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
