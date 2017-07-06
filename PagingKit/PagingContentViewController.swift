//
//  PagingContentViewController.swift
//  PagingViewController
//
//  Created by Kazuhiro Hayashi on 7/2/17.
//  Copyright © 2017 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

public protocol PagingContentViewControllerDelegate: class {
    func contentViewController(viewController: PagingContentViewController, willBeginManualScrollOn index: Int)
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat)
    func contentViewController(viewController: PagingContentViewController, didEndManualScrollOn index: Int)
}

extension PagingContentViewControllerDelegate {
    public func contentViewController(viewController: PagingContentViewController, willBeginManualScrollOn index: Int) {}
    public func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {}
    public func contentViewController(viewController: PagingContentViewController, didEndManualScrollOn index: Int) {}
}

public protocol PagingContentViewControllerDataSource: class {
    func numberOfItemForContentViewController(viewController: PagingContentViewController) -> Int
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController
}

public class PagingContentViewController: UIViewController {
    
    private var cachedViewControllers = [UIViewController?]()
    
    public weak var delegate: PagingContentViewControllerDelegate?
    public weak var dataSource: PagingContentViewControllerDataSource?

    public var isEnabledPreloadContent = true
    
    public var contentOffsetRatio: CGFloat {
        return scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.bounds.width)
    }

    public var pagingPercent: CGFloat {
        return scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width) / scrollView.bounds.width
    }
    
    public var currentPageIndex: Int {
        return Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    public func reloadData(with page: Int = 0) {
        initialLoad(with: page)
        scroll(to: page, animated: false)
    }
    
    public func scroll(to page: Int, animated: Bool) {
        let offsetX = scrollView.bounds.width * CGFloat(page)
        let offset = CGPoint(x: offsetX, y: 0)
        loadPagesIfNeeded(page: page)
        scrollView.setContentOffset(offset, animated: animated)
    }
    
    fileprivate var numberOfPages: Int = 0
    
    fileprivate var lastContentOffset = CGPoint.zero
    fileprivate var leftSidePageIndex = 0
    fileprivate var isExplicityScrolling = false
    
    fileprivate let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        view.backgroundColor = .clear
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if cachedViewControllers.isEmpty {
            initialLoad(with: 0)
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: view.bounds.size.width * CGFloat(numberOfPages), height: view.bounds.size.height)
        cachedViewControllers.enumerated().forEach { (offset, vc) in
            vc?.view.frame = scrollView.bounds
            vc?.view.frame.origin.x = scrollView.bounds.width * CGFloat(offset)
        }
        let offsetX = scrollView.bounds.width * CGFloat(leftSidePageIndex)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        
        layoutHandler?()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var layoutHandler: (() -> Void)?
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let _leftSidePageIndex = leftSidePageIndex
        layoutHandler = { [weak self] in
            guard let _self = self else { return }
            _self.initialLoad(with: _leftSidePageIndex)
            
            let point = CGPoint(x: _self.scrollView.bounds.width * CGFloat(_leftSidePageIndex), y: 0)
            _self.scrollView.setContentOffset(point, animated: false)
            _self.layoutHandler = nil
        }
    }
    
    fileprivate func initialLoad(with page: Int) {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        childViewControllers.forEach { $0.removeFromParentViewController() }
        
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
        delegate?.contentViewController(viewController: self, willBeginScrollFrom: leftSidePageIndex)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset
        leftSidePageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        if isExplicityScrolling {
            let leftSideContentOffset = CGFloat(leftSidePageIndex) * scrollView.bounds.width
            let percent = (scrollView.contentOffset.x - leftSideContentOffset) / scrollView.bounds.width
            let normalizedPercent = min(max(0, percent), 1)
            
            delegate?.contentViewController(viewController: self, didScrollOn: leftSidePageIndex, percent: normalizedPercent)
        }
    }
    
    public func preLoadContentIfNeeded(with scrollingPercent: CGFloat) {
        guard isEnabledPreloadContent else { return }
        
        if scrollingPercent > 0.5 {
            loadPagesIfNeeded(page: currentPageIndex + 1)
        } else{
            loadPagesIfNeeded()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isExplicityScrolling {
            delegate?.contentViewController(viewController: self, didEndManualScrollOn: leftSidePageIndex)
        }
        isExplicityScrolling = false
        loadPagesIfNeeded()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        
        if isExplicityScrolling {
            delegate?.contentViewController(viewController: self, didEndManualScrollOn: leftSidePageIndex)
        }
        isExplicityScrolling = false
        loadPagesIfNeeded()
    }
    
    fileprivate func loadPagesIfNeeded(page: Int? = nil) {
        let loadingPage = page ?? currentPageIndex
        loadScrollView(with: loadingPage - 1)
        loadScrollView(with: loadingPage)
        loadScrollView(with: loadingPage + 1)
    }
}
