//
//  SettingsViewController.swift
//  Abstore
//
//  Created by Abionics on 10/1/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var searchSegmentedControl: UISegmentedControl!
    
    let searchExpressions = [Storage.instance.basetag.name, Storage.instance.untagged.name]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let index = searchExpressions.firstIndex(of: Storage.instance.defaultSearchExpression);
        searchSegmentedControl.selectedSegmentIndex = index!
    }
    
    @IBAction func searchChange(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        Storage.instance.defaultSearchExpression = searchExpressions[index]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0): //import
            print("import")
        case (1, 1): //export
            print("export")
        default:
            print(indexPath)
        }
    }
}
