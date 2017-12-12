//
//  HPCalHorizontalLayout.swift
//  HPToolKit
//
//  Created by Hu, Peng on 12/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class HPCalendarHorizontalLayout: UICollectionViewLayout {
    
    private var contentSize: CGSize?
    private var itemSize: CGSize
//    private var preloadSectionCount: Int = 2
    private var w: CGFloat = 0
    private var h: CGFloat = 0
//
    init(itemHeight: Int, preloadSectionCount: Int = 2) {
        self.itemSize = CGSize.init(width: 0, height: CGFloat(itemHeight))
//        self.preloadSectionCount = preloadSectionCount
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.itemSize = aDecoder.value(forKey: "itemSize") as! CGSize
//        self.preloadSectionCount = aDecoder.value(forKey: "preloadSectionCount") as! Int
        super.init(coder: aDecoder)
    }
    
    override func prepare() {
        super.prepare()
        
        guard let unwrappedView = self.collectionView else {
            return
        }
        w = unwrappedView.bounds.width
        h = unwrappedView.bounds.height
        let sectionCount = unwrappedView.numberOfSections
        
        let itemWidth = w/7
        itemSize.width = itemWidth
        let contentWidth = w * CGFloat(sectionCount)
        
        contentSize = CGSize.init(width: contentWidth, height: h)
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize!
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attrs = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        let section = indexPath.section
        let item = indexPath.item
        let row: Int = item/7
        let column: Int = item%7
        let offsetX = CGFloat(section) * w + CGFloat(column) * itemSize.width
        let offsetY = CGFloat(row) * itemSize.height
        
        attrs.frame = CGRect.init(x: offsetX, y: offsetY, width: itemSize.width, height: itemSize.height)
        return attrs
    }
}
