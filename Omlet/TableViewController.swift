//
//  TableViewController.swift
//  Omlet
//
//  Created by Sergey Libin on 25.07.17.
//  Copyright © 2017 Sergey Libin. All rights reserved.
//

import UIKit
import os.log
import RealmSwift

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var serchBar: UISearchBar!

    var dataSourse :  Results<MealRealm>!
    
    let realm = try! Realm()
    
    let defaultUrl = "http://www.recipepuppy.com/api/?i=onions,garlic&q=omelet&p=3"
    var searchUrl = String()
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if isInternetAvailable(){
            ClearBase()
            
            if searchBar.text == ""{
                
                downloadJsonWithURL(GetUrl: defaultUrl)

            } else {
                let keywords = searchBar.text
                
                let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")
                
                searchUrl = "http://www.recipepuppy.com/api/?q=\(finalKeywords!)"
                
                downloadJsonWithURL(GetUrl: searchUrl)
            }
        }
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isInternetAvailable() {
            
            ClearBase()
            
            downloadJsonWithURL(GetUrl: defaultUrl)

        }
        else{
            print("NO")
        }

        serchBar.enablesReturnKeyAutomatically = false;
        
        reloadTable()
        
    }
    
    func ClearBase(){
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func reloadTable(){
        do{
            dataSourse = realm.objects(MealRealm.self)
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourse.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let meal = dataSourse[indexPath.row]
        
        cell.titleLable.text = meal.name
        cell.ingredientsTextView.text = meal.ingredients
        
        if (meal.image != "" && isInternetAvailable()) {
            let imgURL = NSURL(string: meal.image)
            
            if imgURL != nil {
                let data = NSData(contentsOf: (imgURL as URL?)!)
                
                cell.photoImage.image = UIImage(data: data! as Data)
            }
        } else {
            cell.photoImage.image = #imageLiteral(resourceName: "defaultPhoto")
        }
        
        cell.photoImage.layer.cornerRadius = cell.photoImage.frame.size.width / 2
        cell.photoImage.clipsToBounds = true
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? WebController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? TableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = dataSourse[indexPath.row]
            mealDetailViewController.url = selectedMeal.href
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
    func downloadJsonWithURL(GetUrl: String) {
        
        let url = NSURL(string: GetUrl)
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let mealArray = jsonObj!.value(forKey: "results") as? NSArray {
                    for meal in mealArray{
                        if let mealDict = meal as? NSDictionary {
                            if let name = mealDict.value(forKey: "title") as? String,
                                let href = mealDict.value(forKey: "href") as? String,
                                let ingredients = mealDict.value(forKey: "ingredients") as? String,
                                let image = mealDict.value(forKey: "thumbnail") as? String {
                                
                                let item = MealRealm()
                                    item.name = name
                                    item.ingredients = ingredients
                                    item.image = image
                                    item.href = href
                                
                                do{
                                    let realm = try Realm()
                                    try realm.write({
                                        realm.add(item)
                                    })
                                }
                                catch{
                                    
                                }
                            }
                        }
                        
                    }
                }
                
            }
                OperationQueue.main.addOperation({
                    self.tableView.reloadData()
                })
        }).resume()
    }

}
