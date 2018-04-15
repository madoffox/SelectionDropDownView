//
//  layout.swift
//  SelectionDropDown
//
//  Created by Admin on 26.03.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation
import UIKit

protocol DropDownLayoutDelegate: class {
    // 1. Method to ask the delegate for the height of the image
    func collectionView(_ collectionView:UICollectionView, sizeForDropDownItemAtIndexPath indexPath:IndexPath) -> CGSize
    func collectionView(_ collectionView:UICollectionView, defaultCellHeight height:CGFloat) -> CGFloat
    func collectionView(_ collectionView:UICollectionView, defaultCollectionViewFrame frame:CGRect) -> CGRect
    func collectionView(_ collectionView:UICollectionView, updatedCollectionViewWithFrame frame:CGRect)
       
    
}


class DropDownLayout:UICollectionViewLayout {
    weak var delegate: DropDownLayoutDelegate!
    
    private var defaultCellHeight:CGFloat = 50
    
    var defaultFrame = CGRect()
    
    private var countOfRows:Int = 1
    
    private var numberOfElements:Int = 0
    
    private var cellPadding: CGFloat = 5
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    private var contentHeight: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.height - (insets.top + insets.bottom)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    
    override func prepare() {
        // 1. Only calculate once
        if cache.isEmpty != true {
            cache.removeAll()
            countOfRows = 1
        }
        var tempCache = [UICollectionViewLayoutAttributes]()
        
        let collectionView = self.collectionView!
        
        numberOfElements = (collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0))!
        defaultFrame = delegate.collectionView(collectionView, defaultCollectionViewFrame: CGRect())
        defaultCellHeight = delegate.collectionView(collectionView, defaultCellHeight: 10)
        
        var cellWidth:CGFloat = 120
        var cellHeight:CGFloat = 120
        
        var xOffset:CGFloat = cellPadding
        var yOffset:CGFloat = cellPadding
        
        
        
        
        for item in 0..<numberOfElements{
            let indexPath = IndexPath(item: item, section: 0)
            
            cellWidth = delegate.collectionView(collectionView, sizeForDropDownItemAtIndexPath: indexPath).width
            cellHeight = defaultCellHeight
            
            if(item != 0) {
                if(xOffset + (cellWidth + cellPadding) < contentWidth) {
                    //xOffset += (cellWidth + cellPadding)
                }
                else{
                    yOffset += cellHeight + cellPadding
                    xOffset = cellPadding
                    countOfRows += 1
                }
            }
            
            
           
            
            let frame = CGRect(x: xOffset, y: yOffset, width: cellWidth, height: cellHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            tempCache.append(attributes)

            
            
            if(item != 0) {
                if(xOffset + (cellWidth + cellPadding) < contentWidth) {
                    xOffset += (cellWidth + cellPadding)
                    
                }
                
                
            }
            else{
                xOffset += cellWidth + cellPadding
            }
        }
        let newCollectionViewHeight = CGFloat(countOfRows) * (cellPadding + defaultCellHeight) + cellPadding
        if(newCollectionViewHeight <= collectionView.frame.height) {
            cache = tempCache
            let frame = CGRect(x: collectionView.frame.minX, y: collectionView.frame.minY, width: collectionView.frame.width, height: newCollectionViewHeight)
            delegate.collectionView(collectionView, updatedCollectionViewWithFrame: frame)
        }
        else{
            if(newCollectionViewHeight > collectionView.frame.height && newCollectionViewHeight < defaultFrame.height){
                let frame = CGRect(x: collectionView.frame.minX, y: collectionView.frame.minY, width: collectionView.frame.width, height: newCollectionViewHeight)
                delegate.collectionView(collectionView, updatedCollectionViewWithFrame: frame)
                cache = tempCache
            }
            else{
                xOffset = cellPadding
                yOffset = cellPadding
                for item in 0..<numberOfElements{
                    let indexPath = IndexPath(item: item, section: 0)
                    
                    cellWidth = delegate.collectionView(collectionView, sizeForDropDownItemAtIndexPath: indexPath).width
                    cellHeight = (defaultFrame.height - CGFloat(countOfRows + 1)*(cellPadding))/CGFloat(countOfRows)
                    
                    if(item != 0) {
                        if(xOffset + (cellWidth + cellPadding) < contentWidth) {
                            //xOffset += (cellWidth + cellPadding)
                        }
                        else{
                            yOffset += cellHeight + cellPadding
                            xOffset = cellPadding
                            
                        }
                    }
                    
                    
                    
                    
                    let frame = CGRect(x: xOffset, y: yOffset, width: cellWidth, height: cellHeight)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = frame
                    cache.append(attributes)
                    
                    
                    
                    if(item != 0) {
                        if(xOffset + (cellWidth + cellPadding) < contentWidth) {
                            xOffset += (cellWidth + cellPadding)
                        }
                        
                    }
                    else{
                        xOffset += cellWidth + cellPadding
                    }
                }
                let frame = defaultFrame
                delegate.collectionView(collectionView, updatedCollectionViewWithFrame: frame)
            }
        }
        
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
}

