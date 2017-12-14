//
//  HPCalendarView.swift
//  HPToolKit
//
//  Created by Hu, Peng on 12/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class HPCalendarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var _dataSource: [HPMonth]?
    private var dataSource: [HPMonth] {
        get {
            if _dataSource == nil {
                _dataSource = [try! selectedMonth.preMonth() ,selectedMonth, try! selectedMonth.nextMonth()]
            }
           return _dataSource!
        }
    }
    private var selectedMonth: HPMonth = try! HPMonth.init()
    private var selectedIndex: Int = 1
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        
        scroll(to: selectedIndex + 1, animated: true)
        selectMonth(at: selectedIndex + 1, animated: true)
        
    }
    @IBAction func preBtnClicked(_ sender: Any) {
        scroll(to: selectedIndex - 1, animated: true)
        selectMonth(at: selectedIndex - 1, animated: true)
    }
   
    override func awakeFromNib() {
        let layout = HPCalendarHorizontalLayout.init(itemHeight: 40)
        collectionView.collectionViewLayout = layout
        let cell = UINib.init(nibName: "HPCalendarViewCell", bundle: nil)
        collectionView.register(cell, forCellWithReuseIdentifier: "cell")
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        perform(#selector(scrollToSelectedMonth(animated:)), with: self, afterDelay: 0.1)
        updateTitleLabel()
    }
    
    @objc
    private func scrollToSelectedMonth(animated: Bool = false) {
        scroll(to: selectedIndex, animated: animated)
    }
    
    private func scroll(to section: Int, animated: Bool) {
        collectionView.scrollToItem(at: IndexPath.init(item: 0, section: section), at: UICollectionViewScrollPosition.left, animated: animated)
    }
    
    private func selectMonth(at index: Int, animated: Bool = false) {
        
        selectedMonth = dataSource[index]
        print("current index is \(index)")
        do {
            if index < selectedIndex {
                
                if index == 0 {
                    try _dataSource!.insert(selectedMonth.preMonth(), at: 0)
                    collectionView.insertSections([0])
                    selectedIndex = 1
                    scrollToSelectedMonth(animated: animated)
                } else {
                    selectedIndex = index
                }
            } else {
                if index == dataSource.count - 1 {
                    try _dataSource!.append(selectedMonth.nextMonth())
                    collectionView.insertSections([dataSource.count - 1])
                }
                selectedIndex = index
            }
            
            print("data source count is \(dataSource.count)")
            updateTitleLabel()
            
        } catch HPCalendarError.invalidParameter {
            // alert...
        } catch {
            // ...
        }
    }
    
    private func updateTitleLabel() {
        titleLabel.text = selectedMonth.shortName
    }
    
    // MARK : - UICollectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].lengthIncludePadding
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let month = dataSource[indexPath.section]
        let cell: HPCalendarViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HPCalendarViewCell
        cell.titleLabel.text = month.days[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TBD...
        // add ur handler
    }
    
    // MARK : - UIScrollViewDelegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
        let currentIndex = Int(scrollView.contentOffset.x)/Int(collectionView.bounds.width)
        
        guard currentIndex != selectedIndex else {
            return
        }
        
        selectMonth(at: currentIndex)
        
    }
}
