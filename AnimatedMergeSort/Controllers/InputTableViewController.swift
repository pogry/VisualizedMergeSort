//
//  InputTableViewController.swift
//  AnimatedMergeSort
//
//  Created by Yury Pogrebnyak on 5/16/17.
//  Copyright © 2017 KEYPR. All rights reserved.
//

import UIKit

class InputTableViewController: UITableViewController, InputTableViewCellDelegate {
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    // limit of elements for visualisation
    let MAX_ELEMENTS = 16
    var inputArray = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isEditing = true
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // start editing first cell after view appears
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            cell.becomeFirstResponder()
        }
        
        let label = tableView.headerView(forSection: 0)?.textLabel
        label?.minimumScaleFactor = 0.5
        label?.adjustsFontSizeToFitWidth = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - InputTableViewCellDelegate
    func inputCompleted(cell: InputTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        // insert new number into array, or replace existing one
        let text = cell.inputTextField.text ?? ""
        if let number = Int(text) {
            if indexPath.row < inputArray.count {
                inputArray[indexPath.row] = number
            } else {
                inputArray.append(number)
            }
        }
        invalidateSortButton()
        tableView.reloadData()
        
        // move to the next cell if appropriate
        if let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section)) {
            cell.becomeFirstResponder()
        }
    }
    
    func inputChanged(cell: InputTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let text = cell.inputTextField.text ?? ""
        // delete row if user cleared text
        if text.isEmpty && indexPath.row < inputArray.count {
            deleteRow(at: indexPath)
            
            // Move to the last cell
            if let cell = tableView.cellForRow(at: IndexPath(row: tableView.numberOfRows(inSection: indexPath.section) - 1, section: indexPath.section)) {
                cell.becomeFirstResponder()
            }
        }
    }
    
    // MARK: - helper methods
    func deleteRow(at indexPath: IndexPath) {
        inputArray.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        // insert empty row if was at max elements
        if inputArray.count == MAX_ELEMENTS - 1 {
            tableView.insertRows(at: [IndexPath(row: MAX_ELEMENTS - 1, section: indexPath.section)], with: .fade)
        }
        tableView.endUpdates()
        updateHeaderText()
        invalidateSortButton()
    }
    
    // Update header text w/o the need to reload whole data and to re-assign first responder
    func updateHeaderText() {
        tableView.headerView(forSection: 0)?.textLabel?.text = headerTitle()
    }
    
    // Show an array in header title
    func headerTitle() -> String? {
        var title = "Array: ["
        for element in inputArray {
            title += ", \(element)"
        }
        // remove first comma
        title = title.replacingOccurrences(of: "[, ", with: "[")
        title += "]"
        return title
    }
    
    // enable sort button if array has at least two elements
    func invalidateSortButton() {
        sortButton.isEnabled = inputArray.count > 1
    }
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(inputArray.count + 1, MAX_ELEMENTS)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath) as! InputTableViewCell
        
        cell.delegate = self
        cell.inputTextField.text = indexPath.row < inputArray.count ? "\(inputArray[indexPath.row])" : nil
        cell.nextBarButton.isEnabled = indexPath.row < inputArray.count

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle()
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < inputArray.count
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteRow(at: indexPath)
        }
    }

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        (inputArray[fromIndexPath.row], inputArray[to.row]) = (inputArray[to.row], inputArray[fromIndexPath.row])
        updateHeaderText()
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < inputArray.count
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
