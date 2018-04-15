//
//  SelectedItemsCollectionCell.swift
//  SelectionDropDown
//
//  Created by Admin on 25.03.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation
import UIKit

class DropDownCollectionViewCell:UICollectionViewCell{
    
    open var nameLabel: UILabel = {
        
        let label = UILabel()
        label.text = "Sample Item"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        
        
        return label
        
    }()
    open var deleteButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        deleteButton.addTarget(self, action: #selector(deleteCell), for: .touchUpInside)
        
        addSubview(nameLabel)
        addSubview(deleteButton)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-0-[v1(40)]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel, "v1": deleteButton]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": deleteButton]))

    }
    
    public func makeBeautifulEffect() {
        
        let defaultFrame = self.frame
        self.frame = CGRect(x: defaultFrame.minX, y: defaultFrame.minY, width: defaultFrame.height, height: defaultFrame.height)
        self.nameLabel.alpha = 0
        self.deleteButton.alpha = 0
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (success:Bool) in
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                self.transform = CGAffineTransform.identity
            }, completion: { (success:Bool) in
                UIView.animate(withDuration: 0.2, animations: {
                    self.frame = defaultFrame
                    self.deleteButton.alpha = 1
                    self.nameLabel.alpha = 1
                })
            })
        }
    }
    
    @objc private func deleteCell() {
        var view: SelectionDropDownView? {
            var parentResponder: UIResponder? = self
            while parentResponder != nil {
                parentResponder = parentResponder!.next
                if let view = parentResponder as? SelectionDropDownView {
                    return view
                }
            }
            return nil
        }
        guard let indexPath = view?.collectionView.indexPath(for: self) else {return}
        if(view?.shouldReturnDeletedItemsToList)! {
            view?.listOfItems.append((view?.listOfSelectedItems[indexPath.row])!)
        }
        view?.listOfSelectedItems.remove(at: (indexPath.row))
        view?.collectionView.deleteItems(at: [indexPath])
        view?.tableView.reloadData()
        
        
    }
}
