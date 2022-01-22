//
//  HistoryViewController.swift
//  Trashify
//
//  Created by Alex Lai on 22/1/2022.
//

import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet var historyTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        historyTable.delegate = self
        historyTable.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableDetailScene(_:)), name: Notification.Name("HistoryDetails"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedItem = sender as? Int else{
            return
        }
        if segue.identifier == "HistoryDetailsSegue"{
            guard let destinationVC = segue.destination as? HistoryDetailsViewController else{
                return
            }
            destinationVC.index = selectedItem
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        historyTable.reloadData()
        historyTable.refreshControl?.endRefreshing()
    }
    
    private func isKeyPresentInUserDefaults(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    @objc func enableDetailScene(_ notification: Notification){
        if(isEditing == false){
            let index = notification.object as? Int ?? 0
            self.performSegue(withIdentifier: "HistoryDetailsSegue", sender: index)
            
        }
    }
}
extension HistoryViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: Notification.Name("HistoryDetails"), object: indexPath.item)
        historyTable.deselectRow(at: indexPath, animated: true)
    }
}

extension HistoryViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.isKeyPresentInUserDefaults(key: "ClassifyResult")){
            let data = UserDefaults.standard.object(forKey: "ClassifyResult") as! [String]
            return data.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataLabel = UserDefaults.standard.object(forKey: "ClassifyResult") as! [String]
        let cell  = historyTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataLabel[indexPath.item]
        return cell
    }
    
}
