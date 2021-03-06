//
//  TrackerCollectionViewController.swift
//  habit tracker
//
//  Created by Maks on 16.08.2020.
//  Copyright © 2020 Maxim. All rights reserved.
//

import UIKit
import CoreData

class TrackerCollectionViewController: UICollectionViewController {
    
    var habit: Habit!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayoutSettings()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {  }
    
    @IBAction func resetButton(_ sender: UIBarButtonItem) {
        habit.daysCheck = Array(repeating: false, count: 30)
        collectionView.reloadData()
    }
    
    private func setLayoutSettings(){
        let itemPerRow: CGFloat = 5
        let sectionInserts = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let paddingWidth = sectionInserts.left * (itemPerRow + 1)
        let availableSpace = collectionView.frame.width - paddingWidth
        let widthPerItem = availableSpace / itemPerRow
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: widthPerItem, height: widthPerItem)
        layout.sectionInset = sectionInserts
        layout.minimumLineSpacing = sectionInserts.left
        layout.minimumInteritemSpacing = sectionInserts.left
    }
    
    
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return habit.daysCheck?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath) as! TrackerCollectionViewCell
        
        guard let cellHabit = habit else { return cell }
        if ((cellHabit.daysCheck?[indexPath.row]) == true) {
            cell.dayImageView.image = UIImage(systemName: String(indexPath.row + 1) + ".circle.fill")
        }
        else {
            cell.dayImageView.image = UIImage(systemName: String(indexPath.row + 1) + ".circle")
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        habit.daysCheck?[indexPath.row] = !(habit.daysCheck?[indexPath.row] ?? true)
        collectionView.reloadData() 
    }
}
