//
//  TagViewController.swift
//  iOS Sample
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
import PagingKit

class TagViewController: UIViewController {
    var contentViewController: PagingContentViewController!
    var menuViewController: PagingMenuViewController!
    
    let dataSource: [(menu: (title: String, color: UIColor), content: UIViewController)] = ["Martinez", "Alfred", "Louis", "Justin", "Tim", "Deborah", "Michael", "Choi", "Hamilton", "Decker", "Johnson", "George"].map {
        let title = $0
        let vc = UIStoryboard(name: "ContentTableViewController", bundle: nil).instantiateInitialViewController() as! ContentTableViewController
        let color = UIColor(
            red: (CGFloat(arc4random_uniform(255)) + 1) / 255,
            green: (CGFloat(arc4random_uniform(255)) + 1) / 255,
            blue: (CGFloat(arc4random_uniform(255)) + 1) / 255,
            alpha: 1
        )
        return (menu: (title: title, color: color), content: vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menuViewController?.register(nib: UINib(nibName: "TagMenuCell", bundle: nil), forCellWithReuseIdentifier: "identifier")
        menuViewController?.reloadData(with: 4) { [weak self] _ in
            let cell = self?.menuViewController.currentFocusedCell as! TagMenuCell
            cell.focus(percent: 1)
        }
        contentViewController?.reloadData(with: 4)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController?.delegate = self
            contentViewController?.dataSource = self
        } else if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController?.dataSource = self
            menuViewController?.delegate = self
        }
    }
}

extension TagViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

extension TagViewController: PagingMenuViewControllerDataSource {
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        TagMenuCell.sizingCell.titieLabel.text = dataSource[index].menu.title
        var referenceSize = UILayoutFittingCompressedSize
        referenceSize.height = viewController.view.bounds.height
        let size = TagMenuCell.sizingCell.systemLayoutSizeFitting(referenceSize)
        return size.width
    }
    
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! TagMenuCell
        cell.titieLabel.text = dataSource[index].menu.title
        cell.contentView.backgroundColor = dataSource[index].menu.color
        let percent: CGFloat = viewController.currentFocusedIndex == index ? 1 : 0
        cell.focus(percent: percent)
        return cell
    }
}


extension TagViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        let nextCell = viewController.cellForItem(at: page) as? TagMenuCell
        let prevCell = viewController.cellForItem(at: previousPage) as? TagMenuCell

        nextCell?.focus(percent: 1, animated: true)
        prevCell?.focus(percent: 0, animated: true)
        
        contentViewController?.scroll(to: page, animated: true)
    }
}

extension TagViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        let leftCell = menuViewController.cellForItem(at: index) as? TagMenuCell
        let rightCell = menuViewController.cellForItem(at: index + 1) as? TagMenuCell
        
        leftCell?.focus(percent: (1 - percent))
        rightCell?.focus(percent: percent)

        menuViewController?.scroll(index: index, percent: percent, animated: false)
    }
}
