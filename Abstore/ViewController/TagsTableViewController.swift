//
//  TagsTableViewController.swift
//  Abstore
//
//  Created by Abionics on 9/9/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

class TagsTableViewController: UITableViewController {
    var keeper: TagsKeeper!
    var tags = [Tag]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tags = keeper.getAll()
        tags.remove(object: Storage.instance.basetag)
        tags.remove(object: Storage.instance.untagged)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tags.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags[section].aliases.count + 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let tag = tags[section]
        return tag.name
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let textField = UITextField()
//        textField.text
//
//        let header = UIView()
//        header.backgroundColor = UIColor.lightGray
//
//        return header
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagsTableCell", for: indexPath) as! TagsTableViewCell

        let section = indexPath.section
        let tag = tags[section]
        let count = tags[section].aliases.count + 2
        switch indexPath.row {
        case 0:                     //title
            cell.setup(tag: tag, type: .name, text: tag.name)
        case count - 1:   //add new
            cell.setup(tag: tag, type: .new, text: "")
        default:                    //aliases
            cell.setup(tag: tag, type: .alias, text: tag.aliases[indexPath.row - 1])
        }

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let count = tags[section].aliases.count + 2
        return (indexPath.row != 0) && (indexPath.row != count - 1)
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let tag = tags[section]
        
        if editingStyle == .delete {
            Storage.instance.removeAlias(tag: tag, alias: tag.aliases[indexPath.row - 1])
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
