//
//  ViewController.swift
//  SelectionDropDown
//
//  Created by Admin on 24.03.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
    var selectionDropDownView = SelectionDropDownView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.magenta
        
        selectionDropDownView = SelectionDropDownView(frame: CGRect(x: 10, y: 40, width: self.view.frame.width-20, height: self.view.frame.height/3 ))
        selectionDropDownView.cornerRadius = 12
        selectionDropDownView.listOfItems = ["abc", "abcd", "abcde","abcdef","abcdefg"]
        selectionDropDownView.delegate = self
        selectionDropDownView.shouldReturnDeletedItemsToList = true
        selectionDropDownView.mainColor = .red
        self.view.addSubview(selectionDropDownView)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func changeColor(_ sender: UIButton) {
        selectionDropDownView.mainColor = sender.backgroundColor!
    }
    
    @IBAction func shouldReturnChanged(_ sender: UISwitch) {
        selectionDropDownView.shouldReturnDeletedItemsToList = sender.isOn
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: SelectionDropDownViewDelegate {
    func selectionView(_ selectionView: SelectionDropDownView, didAppendItem item: String, toList list: [String]) {
        print("item:","\n", item)
        print("---------------")
        print("list:","\n",list)
    }
    
    
}
