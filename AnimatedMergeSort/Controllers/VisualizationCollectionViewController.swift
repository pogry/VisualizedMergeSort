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
    
    let animationSpeed = Float(0.2)
    let animationDelay = 0.2

    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = collectionView?.collectionViewLayout as! MergeSortCollectionViewLayout
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
    
    func mergeSort() {
        splitMerged {
            self.merge()
        }
    }
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
            if self.needToMerge.count == 0 {
                if self.merged.count == 1 {
                    // array is sorted
                } else {
                    self.swapMergedAndUnmerged {
                        self.merge()
                    }
                }
            } else if self.needToMerge.count == 1 {
                // odd number of arrays, just move an array to merged
                self.collectionView?.performBatchUpdates({
                    let mergedItemCount = self.collectionView!.numberOfItems(inSection: 1)
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
                var leftArray = self.needToMerge[0]
                let rightArray = self.needToMerge[1]
                let leftArrayCount = leftArray.count
                let totalCount = leftArray.count + rightArray.count
                // save the transform to perform animation
                var transform = [Int]()
                for i in 0..<totalCount {
                    transform.append(i)
                }
                
                
                for i in 0..<rightArray.count {
                    var inserted = false
                    for j in 0..<leftArray.count {
                        if rightArray[i] < leftArray[j] {
                            leftArray.insert(rightArray[i], at: j)
                            inserted = true
                            
                            // adjust transform
                            for k in 0..<transform.count {
                                if transform[k] >= j {
                                    transform[k] += 1
                                }
                            }
                            transform[leftArrayCount + i] = j
                            
                            
                            
                            break
                        }
                    }
                    if !inserted {
                        leftArray.append(rightArray[i])
                        // adjust transform
                        for k in 0..<transform.count {
                            if transform[k] >= leftArray.count - 1 {
                                transform[k] += 1
                            }
                        }
                        transform[leftArrayCount + i] = leftArray.count - 1
                    }
                    
                }
                
                self.collectionView?.performBatchUpdates({
                    let mergedItemCount = self.collectionView!.numberOfItems(inSection: 1)
                    for i in 0..<totalCount {
                        self.collectionView?.moveItem(at: IndexPath(item: i, section: 0), to: IndexPath(item: mergedItemCount + transform[i], section: 1))
                    }
                    self.needToMerge.remove(at: 1)
                    self.needToMerge.remove(at: 0)
                    self.merged.append(leftArray)
                    
                    self.layout.merged = self.merged
                    self.layout.needToMerge = self.needToMerge
                }, completion: { (success) in
                    if success {
                        self.merge()
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            var needToMergeCount = 0
            for array in needToMerge {
                needToMergeCount += array.count
            }
            return needToMergeCount
        case 1:
            var mergedCount = 0
            for array in merged {
                mergedCount += array.count
            }
            return mergedCount
        default:
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NumberCollectionViewCell
    
        var element = 0
        var items = 0
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

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
