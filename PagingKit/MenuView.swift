//
//  MenuView.swift
//  PagingKit
//
//  Created by Kazuhiro Hayashi on 2017/07/11.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

open class PagingMenuCell: UIView {
    open var isSelected: Bool = false
    public internal(set) var identifier: String!
    public internal(set) var index: Int!
}

public protocol PagingMenuViewDataSource: class {
    func numberOfItemForPagingMenuView() -> Int
    func pagingMenuView(pagingMenuView: PagingMenuView, cellForItemAt index: Int) -> PagingMenuCell
    func pagingMenuView(pagingMenuView: PagingMenuView, widthForItemAt index: Int) -> CGFloat
}

public protocol PagingMenuViewDelegate: UIScrollViewDelegate {
    func pagingMenuView(pagingMenuView: PagingMenuView, didSelectItemAt index: Int)
}

public class PagingMenuView: UIScrollView {
    var queue = [String: [PagingMenuCell]]()
    var nibs = [String: UINib]()
    var frameQueue = [CGRect]()
    var visibleCell = [PagingMenuCell]()
    var containerView = UIView()
    
    
    public weak var dataSource: PagingMenuViewDataSource?
    
    private weak var _delegate: PagingMenuViewDelegate?
    public override var delegate: UIScrollViewDelegate? {
        didSet {
            _delegate = delegate as? PagingMenuViewDelegate
        }
    }
    
    public var isInfinity = false {
        didSet {
            showsHorizontalScrollIndicator = !isInfinity
        }
    }
    
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
        
        if isInfinity {
            recenterIfNeeded()
        }
        
        if numberOfItem != 0 {
            let visibleBounds = convert(bounds, to: containerView)
            tileCell(from: max(0, visibleBounds.minX * 0.75), to: min(contentSize.width, visibleBounds.maxX * 1.5))
        }
    }
    
    var numberOfItem: Int = 0
    
    public func indexForItem(at point: CGPoint) -> Int? {
        return frameQueue.enumerated().filter { $1.contains(point) }.flatMap{ $0.offset }.first
    }
    
    
    public func cellForItem(at index: Int) -> PagingMenuCell? {
        return visibleCell.filter { $0.index == index }.first
    }
    
    public func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        visibleCell.forEach { $0.removeFromSuperview() }
        visibleCell = []
        
        numberOfItem = dataSource.numberOfItemForPagingMenuView()
        
        frameQueue = []
        var containerWidth: CGFloat = 0
        (0..<numberOfItem).forEach { (index) in
            let width = dataSource.pagingMenuView(pagingMenuView: self, widthForItemAt: index)
            frameQueue.append(CGRect(x: containerWidth, y: 0, width: width, height: bounds.height))
            containerWidth += width
        }
        contentSize = CGSize(width: containerWidth, height: bounds.height)
        containerView.frame = CGRect(origin: .zero, size: contentSize)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    public func register(nib: UINib?, with identifier: String) {
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
    
    public func rectForItem(at index: Int) -> CGRect? {
        guard index < frameQueue.count else {
            let lastFrame = frameQueue.last
            let rightEdge = lastFrame.flatMap { CGRect(x: $0.maxX, y: 0, width: 0, height: 0) }
            return rightEdge
        }
        
        let x = (0..<index).reduce(0) { (sum, idx) in
            return sum + frameQueue[idx].width
        }
        return CGRect(x: x, y: 0, width: frameQueue[index].width, height: bounds.height)
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
    
    private func align() {
        visibleCell.forEach { (cell) in
            let leftEdge = (0..<cell.index).reduce(CGFloat(0)) { (sum, idx) in sum + frameQueue[idx].width }
            cell.frame.origin.x = leftEdge
        }
    }
    
    @discardableResult
    private func placeNewCellOnRight(with rightEdge: CGFloat, index: Int, dataSource: PagingMenuViewDataSource) -> CGFloat {
        let nextIndex = (index + 1) % numberOfItem
        let cell = dataSource.pagingMenuView(pagingMenuView: self, cellForItemAt: nextIndex)
        cell.index = nextIndex
        containerView.addSubview(cell)
        
        visibleCell.append(cell)
        cell.frame.origin = CGPoint(x: rightEdge, y: 0)
        cell.frame.size = CGSize(width: frameQueue[nextIndex].width, height: bounds.height)

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
        cell.frame.size = CGSize(width: frameQueue[nextIndex].width, height: bounds.height)
        cell.frame.origin = CGPoint(x: leftEdge - frameQueue[nextIndex].width, y: 0)
        return cell.frame.minX
    }
    
    private func tileCell(from minX: CGFloat, to maxX: CGFloat) {
        guard let dataSource = dataSource else {
            return
        }
        
        if visibleCell.isEmpty {
            placeNewCellOnRight(with: minX, index: numberOfItem - 1, dataSource: dataSource)
        }
        
        if var lastCell = visibleCell.last  {
            var rightEdge = lastCell.frame.maxX
            while rightEdge < maxX, (0..<numberOfItem) ~= lastCell.index + 1 {
                rightEdge = placeNewCellOnRight(with: rightEdge, index: lastCell.index, dataSource: dataSource)
                lastCell = visibleCell.last!
            }
        }
        
        if var firstCell = visibleCell.first {
            var leftEdge = firstCell.frame.minX
            while leftEdge > minX, (0..<numberOfItem) ~= firstCell.index - 1 {
                leftEdge = placeNewCellOnLeft(with: leftEdge, index: firstCell.index, dataSource: dataSource)
                firstCell = visibleCell.first!
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
    
    private func tileCellInfinity(from minX: CGFloat, to maxX: CGFloat) {
        guard let dataSource = dataSource else {
            return
        }
        
        if visibleCell.isEmpty {
            placeNewCellOnRight(with: minX, index: numberOfItem - 1, dataSource: dataSource)
        }
        
        if var lastCell = visibleCell.last {
            var rightEdge = lastCell.frame.maxX
            while rightEdge < maxX {
                rightEdge = placeNewCellOnRight(with: rightEdge, index: lastCell.index, dataSource: dataSource)
                lastCell = visibleCell.last!
            }
        }
        
        if var firstCell = visibleCell.first {
            var leftEdge = firstCell.frame.minX
            while leftEdge > minX {
                leftEdge = placeNewCellOnLeft(with: leftEdge, index: firstCell.index, dataSource: dataSource)
                firstCell = visibleCell.first!
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
    
    
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let selectedCell = touches.first.flatMap { $0.location(in: self) }.flatMap { hitTest($0, with: event) as? PagingMenuCell }
        if let index = selectedCell?.index {
            _delegate?.pagingMenuView(pagingMenuView: self, didSelectItemAt: index)
        }
    }
}
