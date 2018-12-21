//
//  Cell.swift
//  practice_1203
//
//  Created by 李书康 on 2018/12/11.
//  Copyright © 2018 com.li.www. All rights reserved.
//

import Foundation
import UIKit
import FSPagerView
import WebKit

typealias TapCover = ((Int) -> (Void))

// MARK: banner
class RecommendBannerCell: UICollectionViewCell,FSPagerViewDelegate, FSPagerViewDataSource {
    
    var tapCover:TapCover?
    
    lazy var pagerView = FSPagerView()
    lazy var pageControl = FSPageControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setUpUI() {
        self.pagerView.dataSource = self
        self.pagerView.delegate = self
        self.pagerView.automaticSlidingInterval =  3
        self.pagerView.isInfinite = !pagerView.isInfinite
        self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        self.addSubview(self.pagerView)
        self.pagerView.snp.makeConstraints { (make) in
            make.width.equalTo(self)
            make.height.equalTo(Screen().width / 2.0)
            make.left.equalTo(0)
            make.top.equalTo(0)
        }
        
        self.pageControl.numberOfPages = 5
        self.pageControl.contentHorizontalAlignment = .center
        self.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.height.equalTo(20)
            make.bottom.equalTo(0)
            make.right.equalTo(0)
        }
    }
    
    // MARK:- FSPagerView Delegate
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.galleryItems.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if self.galleryItems.count >= index + 1 {
            cell.imageView?.sk_Image(url: self.galleryItems[index].cover ?? "_")
        }
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        if let tap = self.tapCover {
            tap(index)
        }
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
    var galleryItems = [GalleryItem]() {
        didSet {
            self.setUpUI()
        }
    }
}

// MARK: 组头

class CollectionHeader: UICollectionReusableView {
    
    lazy var title: UILabel = {
        let title = UILabel()
        return title
    }()
    
    lazy var more: UILabel = {
        let more = UILabel()
        more.font = UIFont.systemFont(ofSize: 15.0)
        more.textAlignment = .right
        more.text = "更多"
        return more
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(title)
        self.addSubview(more)
        more.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.bottom.equalTo(0)
            make.width.equalTo(50)
        }
        title.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.bottom.equalTo(0)
            make.right.equalTo(more.snp_leftMargin).offset(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: 强力推荐和人气推荐
class CategoryCell: UICollectionViewCell {
    
    lazy var logo: UIImageView = {
        let logo = UIImageView.init()
        return logo
    }()
    
    lazy var name: UILabel = {
        let name = UILabel.init()
        name.textAlignment = .center
        return name
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(name)
        name.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(30)
        }
        self.addSubview(logo)
        logo.snp.makeConstraints({ (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(10)
            make.bottom.equalTo(-30)
        })
    }
    
    var comic: Comic? {
        didSet {
            logo.sk_Image(url: comic?.cover ?? "")
            name.text = comic?.name ?? ""
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class RecommendCell: UICollectionViewCell {
    
    lazy var cover: UIImageView = {
        let cover = UIImageView()
        return cover
    }()
    
    lazy var title: UILabel = {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 15.0)
        title.textAlignment = .left
        return title
    }()
    
    lazy var tags: UILabel = {
        let tags = UILabel()
        tags.font = UIFont.systemFont(ofSize: 12.0)
        tags.textColor = UIColor.gray
        tags.textAlignment = .left
        return tags
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(cover)
        self.addSubview(title)
        self.addSubview(tags)
        
        tags.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(25)
        }
        
        title.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(tags.snp_topMargin)
            make.height.equalTo(35)
        }
        
        cover.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(title.snp_topMargin)
        }
    }
    
    var comic: Comic? {
        didSet {
            cover.sk_Image(url: comic?.cover ?? "")
            title.text = comic?.name ?? ""
            var tagText: String = ""
            for item in (comic?.tags ?? []) {
                tagText += "\(item as String ) "
            }
            tags.text = tagText
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: 专题
class SpecialCell: UICollectionViewCell {
    
    lazy var cover: UIImageView = {
        let cover = UIImageView()
        return cover
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(cover)
        cover.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(0)
        }
    }
    
    var comic: Comic? {
        didSet {
            cover.sk_Image(url: comic?.cover ?? "--")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: 今日更新
class TodayCell: UICollectionViewCell {
    
    lazy var cover: UIImageView = {
        let cover = UIImageView()
        return cover
    }()
    
    lazy var title: UILabel = {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 15.0)
        title.textAlignment = .left
        return title
    }()
    
    lazy var tags: UILabel = {
        let tags = UILabel()
        tags.font = UIFont.systemFont(ofSize: 12.0)
        tags.textColor = UIColor.gray
        tags.textAlignment = .left
        return tags
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(cover)
        self.addSubview(title)
        self.addSubview(tags)
        
        tags.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(25)
        }
        
        title.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(tags.snp_topMargin)
            make.height.equalTo(35)
        }
        
        cover.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(title.snp_topMargin)
        }
    }
    
    var comic: Comic? {
        didSet {
            cover.sk_Image(url: comic?.cover ?? "")
            title.text = comic?.name ?? ""
            var tagText: String = ""
            for item in (comic?.tags ?? []) {
                tagText += "\(item as String ) "
            }
            tags.text = tagText
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//MARK: page
class PageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData(url: url ?? "__")
    }
    
    var url: String?
    
    lazy var wkWebView: WKWebView = {
        let web = WKWebView()
        return web
    }()
    
    func loadData(url: String) -> Void {
        
    }
    
}

//MARK: webVC
class U17WebViewController: UIViewController {
    
    lazy var wkWebView : WKWebView = {
        let web = WKWebView()
        return web
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.wkWebView)
        self.wkWebView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    
    convenience init(url: String?) {
        self.init()
        self.wkWebView.load(URLRequest.init(url: URL(string: url ?? "")!))
    }
    
}



