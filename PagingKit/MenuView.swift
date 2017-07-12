//
//  MenuView.swift
//  PagingKit
//
//  Created by kahayash on 2017/07/10.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

public class PagingMenuCell: UIView {
    var index: Int?
}

public protocol PagingMenuViewDataSource: class {
    func numberOfItemForPagingMenuView() -> Int
    func pagingMenuView(view: PagingMenuView, viewForItemAt index: Int) -> UIView
}

public class PagingMenuView: UIScrollView {
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
        tileCell(from: visibleBounds.minX, to: visibleBounds.maxX)
    }
    
    var numberOfItem: Int = 0
    
    public func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        numberOfItem = dataSource.numberOfItemForPagingMenuView()
        let containerWidth = bounds.width * CGFloat(numberOfItem)
        contentSize = CGSize(width: containerWidth, height: bounds.height)
        containerView.frame = CGRect(origin: .zero, size: contentSize)
        containerView.center = CGPoint(x: contentSize.width/2, y: contentSize.height/2)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func recenterIfNeeded() {
        let currentOffset = contentOffset
        let contentWidth = contentSize.width
        let centerOffsetX = (contentWidth - bounds.size.width) / 2
        let distanceFromCenter = fabs(currentOffset.x - centerOffsetX)
        
        if distanceFromCenter > contentWidth / 4 {
            contentOffset = CGPoint(x: centerOffsetX, y: currentOffset.y)
            
            for cell in visibleCell {
                var center = containerView.convert(cell.center, to: self)
                center.x += centerOffsetX - currentOffset.x
                cell.center = convert(center, to: containerView)
            }
        }
    }
    
    @discardableResult
    private func placeNewCellOnRight(with rightEdge: CGFloat, index: Int) -> CGFloat {
        let view = PagingMenuCell(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        view.index = (index + 1) % numberOfItem
        containerView.addSubview(view)
        
        visibleCell.append(view)
        view.frame.origin.x = rightEdge
        view.frame.origin.y = containerView.bounds.size.height - view.frame.size.height
        return view.frame.maxX
    }
    
    private func placeNewCellOnLeft(with leftEdge: CGFloat, index: Int) -> CGFloat {
        let view = PagingMenuCell(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        if index == 0 {
            view.index = numberOfItem - 1
        } else {
            view.index = (index - 1) % numberOfItem
        }
        containerView.addSubview(view)
        
        visibleCell.insert(view, at: 0)
        view.frame.origin.x = leftEdge - view.frame.size.width
        view.frame.origin.y = containerView.bounds.size.height - view.frame.size.height
        return view.frame.minX
    }
    
    private func tileCell(from minX: CGFloat, to maxX: CGFloat) {
        if visibleCell.isEmpty {
            placeNewCellOnRight(with: minX, index: numberOfItem - 1)
        }
        
        if let lastCell = visibleCell.last {
            var rightEdge = lastCell.frame.maxX
            while rightEdge < maxX {
                rightEdge = placeNewCellOnRight(with: rightEdge, index: lastCell.index!)
            }
        }
        
        if let firstCell = visibleCell.first {
            var leftEdge = firstCell.frame.minX
            while leftEdge > minX {
                leftEdge = placeNewCellOnLeft(with: leftEdge, index: firstCell.index!)
            }
        }
        
        var lastCell = visibleCell.last!
        while lastCell.frame.minX > maxX {
            lastCell.removeFromSuperview()
            visibleCell.removeLast()
            lastCell = visibleCell.last!
        }
        
        var firstCell = visibleCell.first!
        while firstCell.frame.maxX < minX {
            firstCell.removeFromSuperview()
            visibleCell.removeFirst()
            firstCell = visibleCell.first!
        }
    }
}
