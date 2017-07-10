//
//  MenuView.swift
//  PagingKit
//
//  Created by kahayash on 2017/07/10.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

public protocol PagingMenuViewDataSource: class {
    func numberOfItemForPagingMenuView() -> Int
    func pagingMenuView(view: PagingMenuView, viewForItemAt index: Int) -> UIView
}

public class PagingMenuView: UIScrollView {
    var visibleCell = [UIView]()
    var containerView = UIView()
    
    weak var dataSource: PagingMenuViewDataSource?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView.translatesAutoresizingMaskIntoConstraints = true
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
        containerView.frame = bounds
        containerView.frame = containerView.frame
        
        addSubview(containerView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        recenterIfNeeded()
        
        let visibleBounds = convert(bounds, to: containerView)
        tileCell(from: visibleBounds.minX, to: visibleBounds.maxX)
    }
    
    public func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        let numberOfItem = dataSource.numberOfItemForPagingMenuView()
        let containerWidth = bounds.width * CGFloat(numberOfItem)
        contentSize = CGSize(width: containerWidth * 2, height: bounds.height)
        let containerSize = CGSize(width: containerWidth, height: bounds.height)
        containerView.frame = CGRect(origin: .zero, size: containerSize)
    }
    
    private func recenterIfNeeded() {
        let currentOffset = contentOffset
        let contentWidth = contentSize.width
        let centerOffsetX = contentWidth - bounds.size.width / 2
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
    private func placeNewCellOnRight(with rightEdge: CGFloat) -> CGFloat {
        let view = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        view.text = "aaaaaaaaaaaaaaaa"
        containerView.addSubview(view)
        
        visibleCell.append(view)
        view.frame.origin.x = rightEdge
        view.frame.origin.y = containerView.bounds.size.height - view.frame.size.height
        return view.frame.maxX
    }
    
    private func placeNewCellOnLeft(with leftEdge: CGFloat) -> CGFloat {
        let view = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        view.text = "aaaaaaaaaaaaaaaa"
        containerView.addSubview(view)
        
        visibleCell.insert(view, at: 0)
        view.frame.origin.x = leftEdge - frame.size.width
        view.frame.origin.y = containerView.bounds.size.height - view.frame.size.height
        return view.frame.minX
    }
    
    private func tileCell(from minX: CGFloat, to maxX: CGFloat) {
        if visibleCell.isEmpty {
            placeNewCellOnRight(with: minX)
        }
        
        if let lastCell = visibleCell.last {
            var rightEdge = lastCell.frame.maxX
            while rightEdge > maxX {
                rightEdge = placeNewCellOnRight(with: rightEdge)
            }
        }
        
        if let firstCell = visibleCell.first {
            var leftEdge = firstCell.frame.minX
            while leftEdge > minX {
                leftEdge = placeNewCellOnLeft(with: leftEdge)
            }
        }
        
        var removeVisibleCell = visibleCell
        for (idx, cell) in visibleCell.enumerated() where cell.frame.minX > maxX {
            cell.removeFromSuperview()
            removeVisibleCell.remove(at: idx)
        }

        for (idx, cell) in visibleCell.enumerated() where cell.frame.maxX > minX {
            cell.removeFromSuperview()
            removeVisibleCell.remove(at: idx)
        }
    }
    
    
}
