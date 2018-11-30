//
//  CatalogCollectionView.swift
//  omuni
//
//  Created by Neha Dhiman on 25/07/18.
//  Copyright © 2018 Neha Dhiman. All rights reserved.
//

import UIKit

open class CatalogCollectionView: UICollectionView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    public weak var catalogDelegate : CatalogCollectionViewCellProtocol? = nil
    public let catalogDataSource = CatalogDataSource()
    
    public func updateView(imageUrlArray: [URL?],catalogDelegate:CatalogCollectionViewCellProtocol? = nil){
        
        if imageUrlArray.isEmpty {
            fatalError("Empty Array")
        }
        else{
            catalogDataSource.update(catalogCollectionView: self, imageUrlArray: imageUrlArray)
            self.catalogDelegate = catalogDelegate
        }
    }
}

@objc public protocol CatalogCollectionViewCellProtocol:class{
    func indexUpdate(index:Int)
    func updateImageForUrl(url : URL?,imageView : UIImageView)
    @objc optional func tapImage(index : Int)
}


public class CatalogDataSource: UIView{
    
    public var imageUrlArray = [URL?]()
    weak public var catalogCollectionView : CatalogCollectionView?
    public func update(catalogCollectionView:CatalogCollectionView,imageUrlArray: [URL?]){
        self.catalogCollectionView = catalogCollectionView
        registerCellCollectionView()
        self.catalogCollectionView?.dataSource = self
        //2.make size of ech image to collectionview size itself
        self.catalogCollectionView?.delegate = self
        
        //3.set scroll direction to be horizontal
        if let layout = self.catalogCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing=0
        }
        
        
        //4. make interitem spacing to zero
        
        
        //5. enable pagination
        catalogCollectionView.isPagingEnabled = true
        
        //6.implement a delegate to give call back which gives index update event
        
        
        //7.removing the horizontal scroller
        catalogCollectionView.showsHorizontalScrollIndicator = false
        self.imageUrlArray = imageUrlArray
        self.catalogCollectionView?.reloadData()
    }
    
    public func registerCellCollectionView(){
        catalogCollectionView?.register(UINib(nibName:"CatalogCollectionViewCell",bundle:Bundle(identifier: "com.arvind.CatalogCollectionView")), forCellWithReuseIdentifier: "catalogCell")
    }
    
    
    
}

extension CatalogDataSource : UICollectionViewDataSource{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageUrlArray.count
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catalogCell", for: indexPath) as? CatalogCollectionViewCell{
            catalogCollectionView?.catalogDelegate?.updateImageForUrl(url: imageUrlArray[indexPath.row],imageView: cell.catalogImageView)
            return cell
        }
        return UICollectionViewCell()
        
    }
    
    
}

//2.make size of ech image to collectionview size itself

extension CatalogDataSource : UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return (catalogCollectionView?.frame.size) ?? CGSize.zero
    }
}

extension CatalogDataSource : UICollectionViewDelegate{
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = (catalogCollectionView?.contentOffset)!
        visibleRect.size = (catalogCollectionView?.bounds.size)!
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = catalogCollectionView?.indexPathForItem(at: visiblePoint) else { return }
        
        catalogCollectionView?.catalogDelegate?.indexUpdate(index: indexPath.row )
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        catalogCollectionView?.catalogDelegate?.tapImage?(index: indexPath.row)
    }
    
}
