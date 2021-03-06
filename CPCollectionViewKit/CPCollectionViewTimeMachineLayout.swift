//
//  CPCollectionViewTimeMachineLayout.swift
//  CPCollectionViewKit
//
//  Created by Parsifal on 2017/2/13.
//  Copyright © 2017年 Parsifal. All rights reserved.
//

import Foundation

open class CPTimeMachineLayoutConfiguration: CPLayoutConfiguration {
    
    public var visibleCount:Int = 1
    public var minCellSize = CGSize(width: 50, height: 50)
    public var scaleFactor: CGFloat = 0.5//(0, 1)
    public var spacingX: CGFloat = 20
    public var spacingY: CGFloat = 0
    override public var spacing: CGFloat {
        didSet {
            spacingX = spacing
            spacingY = spacing
        }
    }
    public var reversed: Bool = false
    
}

open class CPCollectionViewTimeMachineLayout: CPCollectionViewLayout {
    
    public var configuration: CPTimeMachineLayoutConfiguration
    
    public init(withConfiguration configuration: CPTimeMachineLayoutConfiguration) {
        self.configuration = configuration
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.configuration =  CPTimeMachineLayoutConfiguration(withCellSize: CGSize(width: 100, height: 100))
        super.init(coder: aDecoder)
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)!
        guard let collectionView = collectionView else { return  attributes}
        
        let item = CGFloat(indexPath.item)
        let width = collectionView.bounds.size.width
        let height = collectionView.bounds.size.height
        let cellSize = configuration.cellSize
        let cellHeight = cellSize.height
        var visibleCount = CGFloat(min(configuration.visibleCount, cellCount))
        visibleCount = max(1, visibleCount)
        var centerX: CGFloat = 0.0
        var centerY: CGFloat = 0.0

        //update attributes
        var topItemIndex: CGFloat
        var itemOffset: CGFloat
        
        if configuration.reversed {
            topItemIndex = CGFloat(cellCount-1)-collectionView.contentOffset.y/cellHeight
            itemOffset = topItemIndex-item
            attributes.zIndex = indexPath.item
        } else {
            topItemIndex = collectionView.contentOffset.y/cellHeight
            itemOffset =  item-topItemIndex
            attributes.zIndex = -indexPath.item
        }
        attributes.size = cellSize
        
        var transform = CGAffineTransform.identity
        
        if itemOffset<visibleCount+1 && itemOffset >= -1 {
            centerX = width/2+itemOffset*configuration.spacingX
            centerY = height/2+collectionView.contentOffset.y+itemOffset*configuration.spacingY
            
            let scaleFactor = 1-itemOffset/CGFloat(visibleCount)*configuration.scaleFactor
            let scaleTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            transform = scaleTransform
            
            attributes.isHidden = false
            attributes.alpha = itemOffset+1
        } else {
            centerX = -width/2
            centerY = -height/2
            
            attributes.isHidden = true
        }

        attributes.center = CGPoint(x: centerX+configuration.offsetX,
                                    y: centerY+configuration.offsetY)
        attributes.transform = transform
//        print("item:\(item) itemOffset:\(itemOffset)")
        return attributes
    }
 
    open override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return super.collectionViewContentSize }
        let cellHeight = configuration.cellSize.height
        let height = CGFloat(cellCount-1)*cellHeight+collectionView.bounds.height
        return CGSize(width: collectionView.bounds.width, height: height)
    }
}
