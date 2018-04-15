//
//  SelectionDropDownView.swift
//  SelectionDropDown
//
//  Created by Admin on 24.03.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol SelectionDropDownViewDelegate:class {
    func selectionView(_ selectionView: SelectionDropDownView, didAppendItem item:String, toList list: [String])
}

class SelectionDropDownView: UIView, UIGestureRecognizerDelegate {
    
    //MARK: General properties
    weak var delegate:SelectionDropDownViewDelegate!
    
    open var listOfItems:[String] = [String](){
        didSet{
            for item in listOfItems{
                if(item.count > maximumCharCountInList){
                    maximumCharCountInList = item.count
                }
                if(item.count < minimumCharCountInList){
                    minimumCharCountInList = item.count
                }
            }
        }
    }
    open var listOfSelectedItems:[String] = [String]()
    private var isReduced:Bool = true
    open var spaceBetweenView:CGFloat = 8
    private var defaultFrame:CGRect!
    private var shadowViewForCollectionAndButton = UIView()
    private var minimumCharCountInList = 100
    private var maximumCharCountInList = 0
    open var cornerRadius:CGFloat = 12
    open var shouldReturnDeletedItemsToList:Bool = false
    open var mainColor:UIColor = .purple {
        didSet{
            reduceButton.tintColor = mainColor
            tableView.reloadData()
            collectionView.reloadData()
        }
    }
    
    
    //MARK: Collection properties
    var collectionView: UICollectionView!
    private let collectionViewDefaultHeight:CGFloat = 60
    private var collectionCellHeight:CGFloat = 50


    
    //MARK: Table propperties
    var tableView: UITableView = UITableView()
    private let tableViewDefaultHeight:CGFloat = 210
    
    
    //MARK: StartButton properties
    private var reduceButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("▲", for: .normal)
        button.tintColor = .purple
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        //button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    private let reduceButtonHeight:CGFloat = 50
    private let reduceButtonWidth:CGFloat = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()

    }
    
    private func xibSetup() {
         defaultFrame = self.frame
      
        shadowViewForCollectionAndButton.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.width, height: self.collectionViewDefaultHeight)
        shadowViewForCollectionAndButton.backgroundColor = .white
        shadowViewForCollectionAndButton.layer.cornerRadius = cornerRadius
        /*
        shadowViewForCollectionAndButton.layer.masksToBounds = false
        shadowViewForCollectionAndButton.layer.shadowColor = UIColor.black.cgColor
        shadowViewForCollectionAndButton.layer.shadowOpacity = 0.8
        shadowViewForCollectionAndButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowViewForCollectionAndButton.layer.shadowRadius = 4
        */
        self.addSubview(shadowViewForCollectionAndButton)
        
        
        
        self.backgroundColor = .clear
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width - self.reduceButtonWidth, height: collectionViewDefaultHeight), collectionViewLayout: DropDownLayout())
        collectionView.backgroundColor = .white
        collectionView.layer.cornerRadius = cornerRadius
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DropDownCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        if let layout = collectionView.collectionViewLayout as? DropDownLayout {
            layout.delegate = self
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(reduceButtonClicked))
        tap.delegate = self
        collectionView.addGestureRecognizer(tap)
        self.addSubview(self.collectionView)
        
        
        
        tableView.frame = CGRect(x: 0, y: self.collectionView.frame.maxY + self.spaceBetweenView, width: self.frame.width, height: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = cornerRadius
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alpha = 0
        tableView.register(DropDownTableViewCell.self, forCellReuseIdentifier: "myCell")
        self.addSubview(self.tableView)
        
        
        
        reduceButton.frame = CGRect(x: self.collectionView.frame.maxX, y: self.collectionView.center.y - reduceButtonHeight/2, width: reduceButtonWidth, height: reduceButtonHeight)
        reduceButton.layer.cornerRadius = reduceButtonWidth/2
        reduceButton.addTarget(self, action: #selector(reduceButtonClicked), for: .touchUpInside)
        self.addSubview(reduceButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    @objc private func reduceButtonClicked() {
        
        
        if(isReduced){
            for cell in (self.tableView.visibleCells as! [DropDownTableViewCell]) {
                cell.alpha = 0
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                self.reduceButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                
                self.unwrapTableView()
                
                
            }, completion:{(success:Bool) -> () in
                self.isReduced = false
                self.tableView.alpha = 1
                for cell in (self.tableView.visibleCells as! [DropDownTableViewCell]) {
                    let indexPath = self.tableView.indexPath(for: cell)!
                    cell.makeBeautifulEffect(indexPath: indexPath)
                }
            })
            
        }
        else{
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                self.wrapTableView()
                self.reduceButton.transform = CGAffineTransform.identity

                //self.reduceButton.setTitle("", for: .normal)
            }, completion:{(success:Bool) -> () in
                self.isReduced = true
            })
        }
    }
}

extension SelectionDropDownView: UICollectionViewDelegate, UICollectionViewDataSource, DropDownLayoutDelegate{
    func collectionView(_ collectionView: UICollectionView, updatedCollectionViewWithFrame frame: CGRect) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.collectionView.frame = frame
            
            self.reduceButton.frame = CGRect(x: frame.maxX, y: self.collectionView.center.y - self.reduceButtonHeight/2, width: self.reduceButtonWidth, height: self.reduceButtonHeight)
            self.shadowViewForCollectionAndButton.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width+self.reduceButtonWidth, height: frame.height)
            
            if(!self.isReduced) {
                self.unwrapTableView()
            }
        }, completion:nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, defaultCellHeight height: CGFloat) -> CGFloat {
        return collectionCellHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, defaultCollectionViewFrame frame: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: defaultFrame.width - reduceButtonWidth, height: defaultFrame.height)
    }
    
        
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfSelectedItems.count + 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! DropDownCollectionViewCell
        if(indexPath.row < listOfSelectedItems.count) {
            cell.isUserInteractionEnabled = true
            cell.nameLabel.text = listOfSelectedItems[indexPath.row]
            cell.backgroundColor = .white
            cell.layer.cornerRadius = cornerRadius/2
            cell.layer.borderColor = mainColor.cgColor
            cell.layer.borderWidth = 2
            cell.nameLabel.textColor = .black
            cell.deleteButton.isHidden = false
            if(indexPath.row == listOfSelectedItems.count - 1) {
                cell.makeBeautifulEffect()
            }
        }else{
            cell.nameLabel.text = "Add Items"
            cell.nameLabel.textColor = UIColor.init(white: 0.8, alpha: 1)
            cell.layer.borderWidth = 0
            cell.backgroundColor = .clear
            cell.deleteButton.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, sizeForDropDownItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if(indexPath.row < listOfSelectedItems.count){
            return createSizeForDropDownCell(countOfChars: listOfSelectedItems[indexPath.row].count)
        }
        else{
            return CGSize(width: collectionView.frame.width/1.7, height: collectionCellHeight)
        }
    }
    
    private func createSizeForDropDownCell(countOfChars:Int) -> CGSize {
        let halfOfCellWidth = (self.collectionView.frame.width - 10)/3
        let cellWidth = halfOfCellWidth + halfOfCellWidth*(CGFloat(countOfChars - minimumCharCountInList)/CGFloat(maximumCharCountInList-minimumCharCountInList))
        
        let cellHeight = collectionCellHeight
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}

extension SelectionDropDownView: UITableViewDelegate, UITableViewDataSource, DropDownTableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listOfItems.count
    }
   
    func tableView(_ tableView: UITableView, didSelectDropDownCellAtIndexPath indexPath: IndexPath) {
        let item = listOfItems[indexPath.row]
        listOfSelectedItems.append(item)
        delegate.selectionView(self, didAppendItem: item, toList: listOfSelectedItems)
        collectionView.reloadData()
        (collectionView.collectionViewLayout as! DropDownLayout).invalidateLayout()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:DropDownTableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath as IndexPath) as! DropDownTableViewCell
        cell.tableView = tableView
        cell.nameLabel.text = listOfItems[indexPath.row]
        cell.delegate = self
        cell.layer.masksToBounds = true
        cell.isUserInteractionEnabled = true
        cell.backgroundColor = .white
        cell.nameLabel.alpha = 1
        cell.rippleColor = mainColor
        
        
        if(indexPath.row == 0) {
            cell.layer.roundCorners(corners: [.topLeft,.topRight], radius: cornerRadius, viewBounds: cell.bounds)
        }
        else if(indexPath.row == listOfItems.count-1) {
            cell.layer.roundCorners(corners: [.bottomLeft,.bottomRight], radius: cornerRadius, viewBounds: cell.bounds)
        }
        else if(listOfItems.count - 1 == 0){
            cell.layer.roundCorners(corners: [.bottomLeft,.bottomRight,.topLeft,.topRight], radius: cornerRadius, viewBounds: cell.bounds)
        }
        else {
            cell.layer.roundCorners(corners: [.bottomLeft,.bottomRight,.topLeft,.topRight], radius: 0, viewBounds: cell.bounds)
        }
        
        
        return cell
    }
    
    
    @objc private func unwrapTableView() {
        
        let height = (self.superview?.frame.height)! - (self.collectionView.frame.height + self.defaultFrame.minY) - self.spaceBetweenView
        if(CGFloat(70 * self.listOfItems.count) > height) {
            self.frame = CGRect(x: self.defaultFrame.minX, y: self.defaultFrame.minY, width: self.defaultFrame.width, height: self.collectionView.frame.maxY + height)
            self.tableView.frame = CGRect(x: 0, y: collectionView.frame.maxY + spaceBetweenView, width: self.defaultFrame.width, height: height)
        }
        else{
            self.frame = CGRect(x: self.defaultFrame.minX, y: self.defaultFrame.minY, width: self.defaultFrame.width, height: self.collectionView.frame.maxY + CGFloat(70 * self.listOfItems.count))
            self.tableView.frame = CGRect(x: 0, y: collectionView.frame.maxY + spaceBetweenView, width: self.defaultFrame.width, height: CGFloat(70 * self.listOfItems.count))
            
        }
    }
    
    private func wrapTableView() {
        self.tableView.alpha = 0
        self.frame = CGRect(x: self.defaultFrame.minX, y: self.defaultFrame.minY, width: self.defaultFrame.width, height: self.defaultFrame.height)
        self.tableView.frame = CGRect(x: 0, y: self.collectionView.frame.maxY + self.spaceBetweenView, width: self.frame.width, height: 0)
        
    }
}
extension CALayer {
func roundCorners(corners: UIRectCorner, radius: CGFloat, viewBounds: CGRect) {
    
    let maskPath = UIBezierPath(roundedRect: viewBounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
    
    let shape = CAShapeLayer()
    shape.path = maskPath.cgPath
    mask = shape
    }
}
