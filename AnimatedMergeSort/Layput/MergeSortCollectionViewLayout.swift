//
//  MergeSortCollectionViewLayout.swift
//  AnimatedMergeSort
//
//  Created by Yury Pogrebnyak on 5/16/17.
//  Copyright © 2017 KEYPR. All rights reserved.
//

import UIKit

class MergeSortCollectionViewLayout: UICollectionViewLayout {
    // input arrays
    var merged = [[Int]]()
    var needToMerge = [[Int]]()
    // item counts (array is 2-dimentional)
    var totalItemCount = 0
    var mergedItemCount = 0
    var needToMergeItemCount = 0
    // vertical levels & offsets
    var verticalLevels = 0
    var topLevelHorizontalOffset = CGFloat(10)
    var verticalOffset = CGFloat(0)
    var needToMergeLevel = 0
    var mergedLevel = 0
    var needToMergeOffset = CGFloat(0)
    var mergedOffset = CGFloat(0)
    // sizes & frames
    var itemSize = CGFloat(0)
    var rects = [[CGRect]]()
    
    override func prepare() {
        mergedItemCount = merged.reduce(0, {$0 + $1.count})
        needToMergeItemCount = needToMerge.reduce(0, {$0 + $1.count})
        totalItemCount = mergedItemCount + needToMergeItemCount
        // each loop of merge is visualized on a different vertical level
        verticalLevels = Int(ceil(log2(Float(totalItemCount)))) + 1
        
        
        // Identify current level
        // blocks at the start of merge loop
        var countAtStartOfLevelMerge = 0
        if merged.count == 0 {
            countAtStartOfLevelMerge = needToMerge.count
        } else if needToMerge.count > 0 {
            countAtStartOfLevelMerge = needToMerge.count + 2 * merged.count
        }
        
        if countAtStartOfLevelMerge > 0 {
            needToMergeLevel = verticalLevels - Int(ceil(log2(Float(countAtStartOfLevelMerge)))) - 1
            mergedLevel = needToMergeLevel + 1
        } else {
            mergedLevel = verticalLevels - Int(ceil(log2(Float(merged.count)))) - 1
            needToMergeLevel = mergedLevel - 1
        }
        
        // adjust sizes & offsets to feet the screen
        let width = collectionView!.bounds.width
        itemSize = min(100, (width - CGFloat(totalItemCount + 1) * topLevelHorizontalOffset) / CGFloat(totalItemCount))
        verticalOffset = (collectionView!.bounds.height - CGFloat(verticalLevels + 1) * itemSize) / CGFloat(verticalLevels)
        
        needToMergeOffset = (width - CGFloat(needToMergeItemCount) * itemSize) / CGFloat(needToMerge.count + 1)
        mergedOffset = (width - CGFloat(mergedItemCount) * itemSize) / CGFloat(merged.count + 1)
        
        
        // build frames accroding to horizontal & vertical offsets & sizes
        var needToMergeRects = [CGRect]()
        var y = CGFloat(needToMergeLevel) * itemSize + CGFloat(needToMergeLevel + 1) * verticalOffset
        var x = needToMergeOffset
        for array in needToMerge {
            for _ in array {
                needToMergeRects.append(CGRect(x: x, y: y, width: itemSize, height: itemSize))
                x += itemSize
            }
            x += needToMergeOffset
        }
        
        var mergedRects = [CGRect]()
        y = CGFloat(mergedLevel) * itemSize + CGFloat(mergedLevel + 1) * verticalOffset
        x = mergedOffset
        for array in merged {
            for _ in array {
                mergedRects.append(CGRect(x: x, y: y, width: itemSize, height: itemSize))
                x += itemSize
            }
            x += mergedOffset
        }
        
        rects = [needToMergeRects, mergedRects]
    }
    
    override var collectionViewContentSize: CGSize {
        return collectionView!.bounds.size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes : [UICollectionViewLayoutAttributes] = []
        
        for section in 0..<rects.count {
            for item in 0..<rects[section].count {
                if rect.intersects(rects[section][item]) {
                    attributes.append(layoutAttributesForItem(at: IndexPath(item: item, section: section))!)
                }
            }
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = rects[indexPath.section][indexPath.item]
        return attributes
    }

}
