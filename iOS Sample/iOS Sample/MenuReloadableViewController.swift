//
//  DynamicSizeViewController.swift
//  iOS Sample
//
//  Copyright (c) 2018 Kazuhiro Hayashi
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

class MenuReloadableViewController: UIViewController {
    
    var menuViewController: PagingMenuViewController?
    var contentViewController: PagingContentViewController?
    
    static var sizingCell = TitleLabelMenuViewCell(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    
    let menus = ["Martinez", "Alfred", "Louis", "Justin", "Tim", "Deborah", "Michael", "Choi", "Hamilton", "Decker", "Johnson", "George"]
    var dataSource = [(menu: String, content: UIViewController)]() {
        didSet {
            menuViewController?.reloadData()
            contentViewController?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewController?.register(type: TitleLabelMenuViewCell.self, forCellWithReuseIdentifier: "identifier")
        menuViewController?.registerFocusView(view: UnderlineFocusView())
        
        dataSource = makeDataSource(menus: menus)
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
    
    @IBAction func reloadButtonDidTap(_ sender: UIBarButtonItem) {
        dataSource = makeDataSource(menus: menus)
    }
    
    
    func makeDataSource(menus: [String]) -> [(menu: String, content: UIViewController)] {
        var shuffledMenus = menus
        for i in (0..<shuffledMenus.count).reversed() {
            let j = Int(arc4random_uniform(UInt32(i + 1)))
            let tmp = shuffledMenus[i]
            shuffledMenus[i] = shuffledMenus[j]
            shuffledMenus[j] = tmp
        }
        
        return shuffledMenus.map {
            let title = $0
            let vc = UIStoryboard(name: "ContentTableViewController", bundle: nil).instantiateInitialViewController() as! ContentTableViewController
            return (menu: title, content: vc)
        }
    }
}

extension MenuReloadableViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! TitleLabelMenuViewCell
        cell.isSelected = (viewController.currentFocusedIndex == index)
        cell.titleLabel.text = dataSource[index].menu
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        DynamicSizeViewController.sizingCell.titleLabel.text = dataSource[index].menu
        var referenceSize = UILayoutFittingCompressedSize
        referenceSize.height = viewController.view.bounds.height
        let size = DynamicSizeViewController.sizingCell.systemLayoutSizeFitting(referenceSize)
        return size.width
    }
    
    
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
}

extension MenuReloadableViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt Index: Int) -> UIViewController {
        return dataSource[Index].content
    }
}

extension MenuReloadableViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        viewController.visibleCells.forEach { $0.isSelected = false }
        viewController.cellForItem(at: page)?.isSelected = true
        contentViewController?.scroll(to: page, animated: true)
    }
}

extension MenuReloadableViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        let isRightCellSelected = percent > 0.5
        menuViewController?.cellForItem(at: index)?.isSelected = !isRightCellSelected
        menuViewController?.cellForItem(at: index + 1)?.isSelected = isRightCellSelected
        menuViewController?.scroll(index: index, percent: percent, animated: false)
    }
}

