//
//  RootViewController.swift
//  practice_1203
//
//  Created by 李书康 on 2018/12/3.
//  Copyright © 2018 com.li.www. All rights reserved.
//

import Foundation
import UIKit
import HandyJSON
import Moya

class RootViewController: UIViewController {
    
    private var galleryItems = [GalleryItem]()
    private var comicLists = [ComicList]()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()

        let collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: Screen().width, height: Screen().height - Screen().status_nav_h), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(RecommendBannerCell.self, forCellWithReuseIdentifier: "RecommendBannerCell")
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        collectionView.register(RecommendCell.self, forCellWithReuseIdentifier: "RecommendCell")
        collectionView.register(SpecialCell.self, forCellWithReuseIdentifier: "SpecialCell")
        collectionView.register(TodayCell.self, forCellWithReuseIdentifier: "TodayCell")
        
        collectionView.register(CollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionHeader")
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.collectionView)
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension RootViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func loadData() {
        NetWorkRequest(.boutiqueList(sexType: 1), completion: { (json) -> (Void) in
            let recommend = codableFromJSON(json: json["data"]["returnData"], codable: Recommend.self)
            //print(JSONFromCodable(codable: recommend))
            self.galleryItems = recommend?.galleryItems ?? []
            self.comicLists = recommend?.comicLists ?? []
            self.collectionView.reloadData()
        }) { (message) -> (Void) in
            print(message)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //print(JSONFromCodable(codable: self.comicLists))
        
        if (indexPath.section == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendBannerCell", for: indexPath) as! RecommendBannerCell
            cell.tapCover = { (index) -> (Void) in
                print("点击\(index)")
            }
            cell.galleryItems = self.galleryItems
            return cell
        }
        if (indexPath.section == 1) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            guard self.comicLists.count > 0 else {
                return cell
            }
            let comlicList = self.comicLists[indexPath.section - 1]
            let comics = comlicList.comics
            cell.comic = comics?[indexPath.row]
            return cell
        }
        if (indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 6) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendCell", for: indexPath) as! RecommendCell
            guard self.comicLists.count > 0 else {
                return cell
            }
            let comlicList = self.comicLists[indexPath.section - 1]
            let comics = comlicList.comics
            cell.comic = comics?[indexPath.row]
            return cell
        }
        if (indexPath.section == 4) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpecialCell", for: indexPath) as! SpecialCell
            guard self.comicLists.count > 0 else {
                return cell
            }
            let comlicList = self.comicLists[indexPath.section - 1]
            let comics = comlicList.comics
            //print(JSONFromCodable(codable: comics) ?? "")
            cell.comic = comics?[indexPath.row]
            return cell
        }
        if (indexPath.section == 5 || indexPath.section == 7 ) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodayCell", for: indexPath) as! TodayCell
            guard self.comicLists.count > 0 else {
                return cell
            }
            let comlicList = self.comicLists[indexPath.section - 1]
            let comics = comlicList.comics
            cell.comic = comics?[indexPath.row]
            return cell
        }
        if (indexPath.section == 8) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendCell", for: indexPath) as! RecommendCell
            guard self.comicLists.count > 0 else {
                return cell
            }
            let comlicList = self.comicLists[1]
            //print(JSONFromCodable(codable: comlicList))
            let comics = comlicList.comics
            cell.comic = comics?[indexPath.row]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.randomColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionHeader", for: indexPath) as! CollectionHeader
            if (comicLists.count > indexPath.section + 1) {
                let comicList = comicLists[indexPath.section - 1]
                sectionHeader.title.text = comicList.itemTitle ?? "列表"
            }
            return sectionHeader
        } else if kind == UICollectionView.elementKindSectionFooter {
            
        }
        
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section == 0 || indexPath.section == 1) {
            return
        }
    }
    
    //每个分区的内边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 { return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //最小 item 间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6;
    }
    
    //最小行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return 4
        case 2:
            return 4
        case 3:
            return 4
        case 4:
            return 4
        case 5:
            return 3
        case 6:
            return 2
        case 7:
            return 3
        case 8:
            return 2
        default:
            return 3
        }
    }
    
    //item 的尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if  indexPath.section == 0 {
            return CGSize.init(width:Screen().width, height:Screen().width / 2.0)
        }
        if indexPath.section == 1 {
            return CGSize(width: (Screen().width - 40) / 4.0, height: (Screen().width - 40) / 4.0)
        }
        if indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 6 || indexPath.section == 8 {
            return CGSize(width: Screen().width / 2.0 - 3, height: Screen().width / 2.0 * 0.8)
        }
        if indexPath.section == 4 {
            return CGSize(width: (Screen().width - 6) / 2.0, height: (Screen().width - 6) / 2.0 * 0.6)
        }
        if indexPath.section == 5 || indexPath.section == 7 {
            return CGSize(width: (Screen().width - 12.0) / 3.0, height: (Screen().width - 12.0) / 3.0 * 1.5)
        }
        return CGSize.init(width:(Screen().width - 24) / 3.0, height:(Screen().width - 24) / 3.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 || section == 1 {
            return CGSize.zero
        }else {
            return CGSize.init(width: Screen().width, height:40)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize.init(width: Screen().width, height: 10.0)
//    }
    
}

// MARK: 数据模型
struct Recommend : Codable {
    let comicLists : [ComicList]?
    let editTime : String?
    let galleryItems : [GalleryItem]?
    let textItems : [String]?
}

struct GalleryItem : Codable {
    let content : String?
    let cover : String?
    let ext : [Ext]?
    let id : Int?
    let linkType : Int?
    let title : String?
}

struct Ext : Codable {
    let key : String?
    let val : String?
}

struct ComicList : Codable {
    let argName : String?
    let argType : Int?
    let argValue : Int?
    let canedit : Int?
    let comicType : Int?
    let comics : [Comic]?
    let descriptionField : String?
    let itemTitle : String?
    let newTitleIconUrl : String?
    let sortId : String?
    let titleIconUrl : String?
}

struct Comic : Codable {
    let authorName : String?
    let comicId : Int?
    let cornerInfo : String?
    let cover : String?
    let descriptionField : String?
    let isVip : Int?
    let name : String?
    let shortDescription : String?
    let subTitle : String?
    let tags : [String]?
}
