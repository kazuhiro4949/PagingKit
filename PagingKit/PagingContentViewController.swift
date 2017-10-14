//
//  PagingContentViewController.swift
//  PagingKit
//
//  Copyright (c) 2017 Kazuhiro Hayashi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

/// this represents the display and behaviour of the cells.
public protocol PagingContentViewControllerDelegate: class {
    
    /// Tells the delegate when the user is abount to start scroll the content within the receiver.
    ///
    /// - Parameters:
    ///   - viewController: The view controller object that is about to scroll the content view.
    ///   - index: The index where the view controller is about to scroll from.
    func contentViewController(viewController: PagingContentViewController, willBeginManualScrollOn index: Int)
    
    /// Tells the delegate when the user scrolls the content view within the receiver.
    ///
    /// - Parameters:
    ///   - viewController: The view controller object in which the scrolling occurred.
    ///   - index: The left side content index where view controller is showing now.
    ///   - percent: The rate that the view controller is showing the right side content.
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat)
    
    /// Tells the delegate when the user finished to scroll the content within the receiver.
    ///
    /// - Parameters:
    ///   - viewController: The view controller object in which the scrolling occurred.
    ///   - index: The index where the view controller is showing.
    func contentViewController(viewController: PagingContentViewController, didEndManualScrollOn index: Int)
}

extension PagingContentViewControllerDelegate {
    public func contentViewController(viewController: PagingContentViewController, willBeginManualScrollOn index: Int) {}
    public func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {}
    public func contentViewController(viewController: PagingContentViewController, didEndManualScrollOn index: Int) {}
}

/// The data source provides the paging content view controller object with the information it needs to construct and modify the contents.
public protocol PagingContentViewControllerDataSource: class {
    
    /// Tells the data source to return the number of item in a paging scrollview of the view controller.
    ///
    /// - Parameter viewController: The content view controller object requesting this information.
    /// - Returns: The number of item.
    func numberOfItemForContentViewController(viewController: PagingContentViewController) -> Int
    
    /// Asks the data source for a cell to insert in a particular location of the scroll view of content view controller.
    ///
    /// - Parameters:
    ///   - viewController: A content view controller object requesting the cell.
    ///   - index: An index locating a items in content view controller.
    /// - Returns: An object inheriting from UIViewController that the content view controller can use for the specified item.
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController
}

public class PagingContentViewController: UIViewController {
    
    fileprivate var cachedViewControllers = [UIViewController?]()
    fileprivate var leftSidePageIndex = 0
    fileprivate var numberOfPages: Int = 0
    fileprivate var isExplicityScrolling = false
    
    public weak var delegate: PagingContentViewControllerDelegate?
    public weak var dataSource: PagingContentViewControllerDataSource?

    public var isEnabledPreloadContent = true
    
    public var contentOffsetRatio: CGFloat {
        return scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.bounds.width)
    }

    public var pagingPercent: CGFloat {
        return scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width) / scrollView.bounds.width
    }
    
    @available(*, deprecated)
    public var currentPageIndex: Int {
        return leftSidePageIndex
    }
    
    public func reloadData(with page: Int = 0) {
        removeAll()
        
        UIView.animate(
            withDuration: 0,
            animations: { [weak self] in
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            },
            completion: { [weak self] (finish) in
                self?.initialLoad(with: page)
                self?.scroll(to: page, animated: false)
            }
        )
    }
    
    public func scroll(to page: Int, animated: Bool) {
        let offsetX = scrollView.bounds.width * CGFloat(page)
        loadPagesIfNeeded(page: page)
        leftSidePageIndex = page
        if animated {
            performSystemAnimation({ [weak self] in
                self?.scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
            })
        } else {
            scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
        }
    }
    
    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        view.addSubview(scrollView)
        view.addConstraints([.top, .bottom, .leading, .trailing].map {
            NSLayoutConstraint(item: scrollView, attribute: $0, relatedBy: .equal, toItem: view, attribute: $0, multiplier: 1, constant: 0)
        })
        
        view.backgroundColor = .clear
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(
            width: scrollView.bounds.size.width * CGFloat(numberOfPages),
            height: scrollView.bounds.size.height
        )
        
        scrollView.contentOffset = CGPoint(x: scrollView.bounds.width * CGFloat(leftSidePageIndex), y: 0)
        
        cachedViewControllers.enumerated().forEach { (offset, vc) in
            vc?.view.frame = scrollView.bounds
            vc?.view.frame.origin.x = scrollView.bounds.width * CGFloat(offset)
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        removeAll()
        initialLoad(with: leftSidePageIndex)
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            guard let _self = self else { return }
            _self.scroll(to: _self.leftSidePageIndex, animated: false)
        }, completion: nil)
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    fileprivate func removeAll() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        childViewControllers.forEach { $0.removeFromParentViewController() }
    }
    
    fileprivate func initialLoad(with page: Int) {
        numberOfPages = dataSource?.numberOfItemForContentViewController(viewController: self) ?? 0
        cachedViewControllers = Array(repeating: nil, count: numberOfPages)
        
        loadScrollView(with: page - 1)
        loadScrollView(with: page)
        loadScrollView(with: page + 1)
    }
    
    fileprivate func loadScrollView(with page: Int) {
        guard (0..<cachedViewControllers.count) ~= page else { return }
        
        if case nil = cachedViewControllers[page], let dataSource = dataSource {
            let vc = dataSource.contentViewController(viewController: self, viewControllerAt: page)
            vc.willMove(toParentViewController: self)
            addChildViewController(vc)
            vc.view.frame = scrollView.bounds
            vc.view.frame.origin.x = scrollView.bounds.width * CGFloat(page)
            scrollView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
            cachedViewControllers[page] = vc
        }
    }
}

extension PagingContentViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isExplicityScrolling = true
        leftSidePageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        delegate?.contentViewController(viewController: self, willBeginManualScrollOn: leftSidePageIndex)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isExplicityScrolling {
            leftSidePageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            let leftSideContentOffset = CGFloat(leftSidePageIndex) * scrollView.bounds.width
            let percent = (scrollView.contentOffset.x - leftSideContentOffset) / scrollView.bounds.width
            let normalizedPercent = min(max(0, percent), 1)
            delegate?.contentViewController(viewController: self, didManualScrollOn: leftSidePageIndex, percent: normalizedPercent)
        }
    }
    
    public func preLoadContentIfNeeded(with scrollingPercent: CGFloat) {
        guard isEnabledPreloadContent else { return }
        
        if scrollingPercent > 0.5 {
            loadPagesIfNeeded(page: leftSidePageIndex + 1)
        } else{
            loadPagesIfNeeded()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isExplicityScrolling {
            leftSidePageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            delegate?.contentViewController(viewController: self, didEndManualScrollOn: leftSidePageIndex)
        }
        isExplicityScrolling = false
        loadPagesIfNeeded()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        
        if isExplicityScrolling {
            leftSidePageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            delegate?.contentViewController(viewController: self, didEndManualScrollOn: leftSidePageIndex)
        }
        isExplicityScrolling = false
        loadPagesIfNeeded()
    }
    
    fileprivate func loadPagesIfNeeded(page: Int? = nil) {
        let loadingPage = page ?? leftSidePageIndex
        loadScrollView(with: loadingPage - 1)
        loadScrollView(with: loadingPage)
        loadScrollView(with: loadingPage + 1)
    }
}

private func performSystemAnimation(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
    UIView.perform(
        .delete,
        on: [],
        options: UIViewAnimationOptions(rawValue: 0),
        animations: animations,
        completion: completion
    )
}
