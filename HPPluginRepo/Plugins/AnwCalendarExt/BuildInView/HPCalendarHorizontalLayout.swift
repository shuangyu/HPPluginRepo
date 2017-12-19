//
//  HPCalHorizontalLayout.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 12/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class HPCalendarHorizontalLayout: UICollectionViewLayout {
    
    private var contentSize: CGSize?
    private var itemSize: CGSize?
    private var w: CGFloat = 0
    private var h: CGFloat = 0

    init(itemHeight: Int) {
        self.itemSize = CGSize(width: 0, height: CGFloat(itemHeight))
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        itemSize!.width = itemWidth
        let contentWidth = w * CGFloat(sectionCount)
        
        contentSize = CGSize(width: contentWidth, height: h)
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize!
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let section = indexPath.section
        let item = indexPath.item
        let row: Int = item/7
        let column: Int = item%7
        let offsetX = CGFloat(section) * w + CGFloat(column) * itemSize!.width
        let offsetY = CGFloat(row) * itemSize!.height
        
        attrs.frame = CGRect(x: offsetX, y: offsetY, width: itemSize!.width, height: itemSize!.height)
        return attrs
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let a: Int = Int(rect.minX/w)
        let b: Int = Int(rect.maxX/w)
        
        var attrs: [UICollectionViewLayoutAttributes] = []
        
        for section in a...b {
            
            if section < 0 {
                continue
            }
            
            guard section < self.collectionView!.numberOfSections else {
                return attrs
            }
            
            let itemsCount = self.collectionView!.numberOfItems(inSection: section)
            for item in 0..<itemsCount {
                let attr = layoutAttributesForItem(at: IndexPath(item: item, section: section))
                attrs.append(attr!)
            }
        }
        return attrs
    }
}
