//
//  DataStaticTableViewController.swift
//  Trashify
//
//  Created by Alex Lai on 18/4/2022.
//

import UIKit

class DataStaticTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    let cells = [["ClearData"]]
    @IBOutlet weak var labelClearData: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return cells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cells[section].count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == [0, 0]{
            let data = [[String]]()
            defaults.set(data, forKey: "ClassifyResult")
            let imageData = [NSData]()
            defaults.set(imageData, forKey: "ClassifyPicture")
        }
    }

}
