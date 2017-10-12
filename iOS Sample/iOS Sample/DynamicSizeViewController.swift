//
//  DynamicSizeViewController.swift
//  iOS Sample
//
//  Created by kahayash on 2017/09/03.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
import PagingKit

class DynamicSizeViewController: UIViewController {
    
    var menuViewController: PagingMenuViewController?
    var contentViewController: PagingContentViewController?
    
    
    let dataSource: [(menu: String, content: UIViewController)] = ["Martinez", "Alfred", "Louis", "Justin", "Tim", "Deborah", "Michael", "Choi", "Hamilton", "Decker", "Johnson", "George"].map {
        let title = $0
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
        vc.number = title
        return (menu: title, content: vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewController?.register(nib: UINib(nibName: "MenuCell", bundle: nil), forCellWithReuseIdentifier: "identifier")
        menuViewController?.registerFocusView(nib: UINib(nibName: "FocusView", bundle: nil))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let _self = self else { return }
            _self.menuViewController?.reloadData(with: _self.dataSource.count - 1)
            _self.contentViewController?.reloadData(with: _self.dataSource.count - 1)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController?.dataSource = self
            menuViewController?.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController?.delegate = self
            contentViewController?.dataSource = self
        }
    }
    
    @IBAction func updateSizeButtonDidTap(_ sender: UIBarButtonItem) {
        let size = UIScreen.main.bounds.size
        let width =  size.width * CGFloat(arc4random_uniform(100)) / 100
        let height = size.height * CGFloat(arc4random_uniform(100)) / 100
        
        let updateSize = height <= 108 ? .zero : CGSize(width: width, height: height)
        UIView.perform(.delete, on: [], options: UIViewAnimationOptions(rawValue: 0), animations: { [weak self] in
            self?.view.frame.size = updateSize
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        }, completion: { (finish) in })
    }
    
}

extension DynamicSizeViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! MenuCell
        cell.titleLabel.text = dataSource[index].menu
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        MenuCell.sizingCell.titleLabel.text = dataSource[index].menu
        var referenceSize = UILayoutFittingCompressedSize
        referenceSize.height = viewController.view.bounds.height
        let size = MenuCell.sizingCell.systemLayoutSizeFitting(referenceSize)
        return size.width
    }
    
    
    func numberOfItemForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
}

extension DynamicSizeViewController: PagingContentViewControllerDataSource {
    func numberOfItemForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt Index: Int) -> UIViewController {
        return dataSource[Index].content
    }
}

extension DynamicSizeViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController?.scroll(to: page, animated: true)
    }
}

extension DynamicSizeViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController?.scroll(index: index, percent: percent, animated: false)
    }
}
