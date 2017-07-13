//
//  MenuView.swift
//  PagingKit
//
//  Created by kahayash on 2017/07/10.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

public class PagingMenuCell: UIView {
    var identifier: String!
    var index: Int?
}

public protocol PagingMenuViewDataSource: class {
    func numberOfItemForPagingMenuView() -> Int
    func pagingMenuView(pagingMenuView: PagingMenuView, cellForItemAt index: Int) -> PagingMenuCell
    func pagingMenuView(pagingMenuView: PagingMenuView, widthForItemAt index: Int) -> CGFloat
}

public class PagingMenuView: UIScrollView {
    var queue = [String: [PagingMenuCell]]()
    var nibs = [String: UINib]()
    var widthQueue = [CGFloat]()
    var visibleCell = [PagingMenuCell]()
    var containerView = UIView()
    
    
    weak var dataSource: PagingMenuViewDataSource?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        containerView.frame = bounds
        containerView.center = center
        
        addSubview(containerView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        containerView.frame = bounds
        containerView.center = center
        
        addSubview(containerView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        recenterIfNeeded()
        
        let visibleBounds = convert(bounds, to: containerView)
        tileCell(from: visibleBounds.minX * 0.75, to: visibleBounds.maxX * 1.5)
    }
    
    var numberOfItem: Int = 0
    
    public func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        numberOfItem = dataSource.numberOfItemForPagingMenuView()
        
        widthQueue = []
        var containerWidth: CGFloat = 0
        (0..<numberOfItem).forEach { (index) in
            let width = dataSource.pagingMenuView(pagingMenuView: self, widthForItemAt: index)
            containerWidth += width
            widthQueue.append(width)
        }
        contentSize = CGSize(width: containerWidth, height: bounds.height)
        containerView.frame = CGRect(origin: .zero, size: contentSize)
        containerView.center = CGPoint(x: contentSize.width/2, y: contentSize.height/2)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    public func register(nib: UINib, with identifier: String) {
        nibs[identifier] = nib
    }
    
    public func dequeue(with identifier: String) -> PagingMenuCell {
        if var cells = queue[identifier], !cells.isEmpty {
            let cell = cells.removeFirst()
            queue[identifier] = cells
            cell.identifier = identifier
            return cell
        }
        
        if let nib = nibs[identifier] {
            let cell = nib.instantiate(withOwner: self, options: nil).first as! PagingMenuCell
            cell.identifier = identifier
            return cell
        }
        
        fatalError()
    }
    
    private func recenterIfNeeded() {
        let currentOffset = contentOffset
        let contentWidth = contentSize.width
        let centerOffsetX = (contentWidth - bounds.size.width) / 2
        let distanceFromCenter = fabs(currentOffset.x - centerOffsetX)
        
        if distanceFromCenter > (contentWidth - bounds.size.width) / 4 {
            contentOffset = CGPoint(x: centerOffsetX, y: currentOffset.y)
            
            for cell in visibleCell {
                var center = containerView.convert(cell.center, to: self)
                center.x += centerOffsetX - currentOffset.x
                cell.center = convert(center, to: containerView)
            }
        }
    }
    
    @discardableResult
    private func placeNewCellOnRight(with rightEdge: CGFloat, index: Int, dataSource: PagingMenuViewDataSource) -> CGFloat {
        let nextIndex = (index + 1) % numberOfItem
        let cell = dataSource.pagingMenuView(pagingMenuView: self, cellForItemAt: nextIndex)
        cell.index = nextIndex
        containerView.addSubview(cell)
        
        visibleCell.append(cell)
        cell.frame.origin.x = rightEdge
        cell.frame.origin.y = containerView.bounds.size.height - cell.frame.size.height
        cell.frame.size = CGSize(width: widthQueue[index], height: bounds.height)
        return cell.frame.maxX
    }
    
    private func placeNewCellOnLeft(with leftEdge: CGFloat, index: Int, dataSource: PagingMenuViewDataSource) -> CGFloat {
        let nextIndex: Int
        if index == 0 {
            nextIndex = numberOfItem - 1
        } else {
            nextIndex = (index - 1) % numberOfItem
        }
        let cell = dataSource.pagingMenuView(pagingMenuView: self, cellForItemAt: nextIndex)
        cell.index = nextIndex
        
        containerView.addSubview(cell)
        
        visibleCell.insert(cell, at: 0)
        cell.frame.origin.x = leftEdge - cell.frame.size.width
        cell.frame.origin.y = containerView.bounds.size.height - cell.frame.size.height
        cell.frame.size = CGSize(width: widthQueue[index], height: bounds.height)
        return cell.frame.minX
    }
    
    private func tileCell(from minX: CGFloat, to maxX: CGFloat) {
        guard let dataSource = dataSource else {
            return
        }
        
        if visibleCell.isEmpty {
            placeNewCellOnRight(with: minX, index: numberOfItem - 1, dataSource: dataSource)
        }
        
        if let lastCell = visibleCell.last {
            var rightEdge = lastCell.frame.maxX
            while rightEdge < maxX {
                rightEdge = placeNewCellOnRight(with: rightEdge, index: lastCell.index!, dataSource: dataSource)
            }
        }
        
        if let firstCell = visibleCell.first {
            var leftEdge = firstCell.frame.minX
            while leftEdge > minX {
                leftEdge = placeNewCellOnLeft(with: leftEdge, index: firstCell.index!, dataSource: dataSource)
            }
        }
        
        var lastCell = visibleCell.last!
        while lastCell.frame.minX > maxX {
            lastCell.removeFromSuperview()
            let recycleCell = visibleCell.removeLast()
            
            // enqueue
            if let cells = queue[recycleCell.identifier] {
                queue[recycleCell.identifier] = cells + [recycleCell]
            } else {
                queue[recycleCell.identifier] = [recycleCell]
            }
            
            lastCell = visibleCell.last!
        }
        
        var firstCell = visibleCell.first!
        while firstCell.frame.maxX < minX {
            firstCell.removeFromSuperview()
            let recycleCell = visibleCell.removeFirst()
            
            // enqueue
            if let cells = queue[recycleCell.identifier] {
                queue[recycleCell.identifier] = cells + [recycleCell]
            } else {
                queue[recycleCell.identifier] = [recycleCell]
            }
            
            firstCell = visibleCell.first!
        }
    }
}
