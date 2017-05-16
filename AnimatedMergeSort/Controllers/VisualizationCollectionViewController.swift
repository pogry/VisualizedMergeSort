//
//  VisualizationCollectionViewController.swift
//  AnimatedMergeSort
//
//  Created by Yury Pogrebnyak on 5/16/17.
//  Copyright © 2017 KEYPR. All rights reserved.
//

import UIKit
import QuartzCore

private let reuseIdentifier = "NumberCell"

class VisualizationCollectionViewController: UICollectionViewController {
    
    var inputArray: [Int]!
    var merged = [[Int]]()
    var needToMerge = [[Int]]()
    
    var layout: MergeSortCollectionViewLayout!
    
    let animationSpeed = Float(0.25)
    let animationDelay = 0.15

    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = collectionView?.collectionViewLayout as! MergeSortCollectionViewLayout
        // adjust animation speed
        collectionView?.forFirstBaselineLayout.layer.speed = animationSpeed
        collectionView?.forLastBaselineLayout.layer.speed = animationSpeed
        
        // initial state
        merged = [inputArray]
        layout.merged = merged
        layout.needToMerge = needToMerge
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mergeSort()
    }
    
    // MARK: - sort
    // begin sort
    func mergeSort() {
        splitMerged {
            self.merge()
        }
    }
    
    // Split an array into 1-element arrays. Only used at the start of sort algorithm
    func splitMerged(completion:@escaping () -> Void) {
        needToMerge = []
        for array in merged {
            for item in array {
                needToMerge.append([item])
            }
        }
        merged = []
        
        layout.merged = merged
        layout.needToMerge = needToMerge
        
        collectionView?.performBatchUpdates({
            for i in 0..<self.needToMerge.count {
                self.collectionView?.moveItem(at: IndexPath(item: i, section: 1), to: IndexPath(item: i, section: 0))
            }
        }, completion: { (success) in
            if success {
                completion()
            }
        })
    }
    
    // Swap merged and unmerged arrays. Needed at each step (represented as vertical level) of merge sort
    func swapMergedAndUnmerged(completion:@escaping () -> Void) {
        needToMerge = merged
        merged = []
        
        layout.merged = merged
        layout.needToMerge = needToMerge
        
        var totalCount = 0
        for array in needToMerge {
            totalCount += array.count
        }
        
        collectionView?.performBatchUpdates({
            for i in 0..<totalCount {
                self.collectionView?.moveItem(at: IndexPath(item: i, section: 1), to: IndexPath(item: i, section: 0))
            }
        }, completion: { (success) in
            if success {
                completion()
            }
        })
    }
    
    func merge() {
        // delay between each merge needed for better visual experience
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
            if self.needToMerge.count == 0 {
                if self.merged.count == 1 {
                    // array is sorted
                } else {
                    // array isn't sorted yet, swap merged & unmerged and continue
                    self.swapMergedAndUnmerged {
                        self.merge()
                    }
                }
            } else if self.needToMerge.count == 1 {
                // odd number of arrays, just move an array to merged
                self.collectionView?.performBatchUpdates({
                    let mergedItemCount = self.collectionView!.numberOfItems(inSection: 1)
                    // move all items from 0 section into 1st and adjusting indexes
                    for i in 0..<self.needToMerge[0].count {
                        self.collectionView?.moveItem(at: IndexPath(item: i, section: 0), to: IndexPath(item: mergedItemCount + i, section: 1))
                    }
                    
                    self.merged.append(self.needToMerge[0])
                    self.needToMerge = []
                    
                    self.layout.merged = self.merged
                    self.layout.needToMerge = self.needToMerge
                }, completion: { (success) in
                    if success {
                        self.merge()
                    }
                })
            } else {
                // merge two arrays into one, move to merged arrays
                
                var leftArray = self.needToMerge[0]
                
                let mergedItemCount = self.collectionView!.numberOfItems(inSection: 1)
                
                // start merging process - move left array down
                self.collectionView?.performBatchUpdates({
                    for i in 0..<leftArray.count {
                        self.collectionView?.moveItem(at: IndexPath(item: i, section: 0), to: IndexPath(item: mergedItemCount + i, section: 1))
                    }
                    self.needToMerge.remove(at: 0)
                    self.merged.append(leftArray)
                    
                    self.layout.merged = self.merged
                    self.layout.needToMerge = self.needToMerge
                }, completion: { (success) in
                    if success {
                        // merge each item from right array
                        var itemMerge: (() -> Void)!
                        // placeholder trick for recursive call inside a closure
                        let placeholder: () -> Void = { () in
                            // insert item into merged array
                            let performInsert: (_ index: Int) -> Void = { (index) in
                                var shouldMoveToNextLevel = false
                                leftArray.insert(self.needToMerge[0][0], at: index)
                                self.needToMerge[0].remove(at: 0)
                                if self.needToMerge[0].isEmpty {
                                    self.needToMerge.remove(at: 0)
                                    shouldMoveToNextLevel = true
                                }
                                self.collectionView?.performBatchUpdates({ 
                                    // move inserted item
                                    self.collectionView?.moveItem(at: IndexPath(item: 0, section: 0), to: IndexPath(item: mergedItemCount + index, section: 1))
                                    // adjust existing items
                                    for j in index..<leftArray.count-1 {
                                        self.collectionView?.moveItem(at: IndexPath(item: mergedItemCount + j, section: 1), to: IndexPath(item: mergedItemCount + j + 1, section: 1))
                                    }
                                    self.merged[self.merged.count - 1] = leftArray
                                    
                                    self.layout.merged = self.merged
                                    self.layout.needToMerge = self.needToMerge
                                    
                                }, completion: { (success) in
                                    if success {
                                        if shouldMoveToNextLevel {
                                            self.merge()
                                        } else {
                                            itemMerge()
                                        }
                                    }
                                })
                            }
                            
                            var inserted = false
                            for i in 0..<leftArray.count {
                                if self.needToMerge[0][0] < leftArray[i] {
                                    inserted = true
                                    performInsert(i)
                                    break
                                }
                            }
                            if !inserted {
                                performInsert(leftArray.count)
                            }
                        }
                        itemMerge = placeholder
                        itemMerge()
                    }
                })
                
                
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            // count items in 2-dim array
            return needToMerge.reduce(0, {$0 + $1.count})
        case 1:
            return merged.reduce(0, {$0 + $1.count})
        default:
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NumberCollectionViewCell
    
        var element = 0
        var items = 0
        // find the corresponding element (since array is 2-dim)
        for array in [needToMerge, merged][indexPath.section] {
            if indexPath.item < items + array.count {
                element = array[indexPath.item - items]
                break
            }
            items += array.count
        }
        cell.numberLabel.text = "\(element)"
        
        return cell
    }

}
