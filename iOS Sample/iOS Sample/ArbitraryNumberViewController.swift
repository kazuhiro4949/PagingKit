//
//  ArbitraryNumberViewController.swift
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

class ArbitraryNumberViewController: UIViewController {
    var contentViewController: PagingContentViewController!
    var menuViewController: PagingMenuViewController!
    
    private static var sizingCell = TitleLabelMenuViewCell(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    
    var dataSource = [(menu: String, content: UIViewController)]()
    
    var startPosition = 0
    var isSegmentedMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertController = makeAlertController()
        present(alertController, animated: true, completion: nil)
        
        menuViewController?.register(type: TitleLabelMenuViewCell.self, forCellWithReuseIdentifier: "identifier")
        menuViewController?.registerFocusView(view: UnderlineFocusView())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self
            menuViewController.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController.delegate = self
            contentViewController.dataSource = self
        }
    }
}

// MARK:- PagingMenuViewControllerDataSource

extension ArbitraryNumberViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! TitleLabelMenuViewCell
        cell.titleLabel.text = dataSource[index].menu
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        if isSegmentedMenu {
            return UIScreen.main.bounds.width / CGFloat(dataSource.count)
        } else {
            ArbitraryNumberViewController.sizingCell.titleLabel.text = dataSource[index].menu
            var referenceSize = UILayoutFittingCompressedSize
            referenceSize.height = viewController.view.bounds.height
            let size = ArbitraryNumberViewController.sizingCell.systemLayoutSizeFitting(referenceSize)
            return size.width
        }
    }
    
    
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
}

// MARK:- PagingContentViewControllerDataSource

extension ArbitraryNumberViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

// MARK:- PagingMenuViewControllerDelegate

extension ArbitraryNumberViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController?.scroll(to: page, animated: true)
    }
}

// MARK:- PagingContentViewControllerDelegate

extension ArbitraryNumberViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController?.scroll(index: index, percent: percent, animated: false)
    }
}

// MARK:- UITextFieldDelegate

extension ArbitraryNumberViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let number = textField.text.flatMap({ UInt($0) }) else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        if textField.tag == 0 {
            dataSource = (0..<number).map {
                let vc = UIStoryboard(name: "ContentTableViewController", bundle: nil).instantiateInitialViewController() as! ContentTableViewController
                return (menu: "\($0)", content: vc)
            }
        } else if textField.tag == 1 {
            startPosition = Int(number)
        }
    }
}

// MARK:- fileprivate

extension ArbitraryNumberViewController {
    fileprivate func makeAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: "Input number of pages", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Create Scroll Menu", style: .`default`, handler: { [weak self] _ in
            guard let _self = self else { return }
            _self.isSegmentedMenu = false
            _self.menuViewController.reloadData(with: _self.startPosition)
            _self.contentViewController.reloadData(with: _self.startPosition)
        }))
        alertController.addAction(UIAlertAction(title: "Create Segmentation", style: .`default`, handler: { [weak self] _ in
            guard let _self = self else { return }
            _self.isSegmentedMenu = true
            _self.menuViewController.reloadData(with: _self.startPosition)
            _self.contentViewController.reloadData(with: _self.startPosition)
        }))
        alertController.addTextField { (textField) in
            textField.placeholder = "number of pages"
            textField.tag = 0
            textField.delegate = self
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "start index"
            textField.tag = 1
            textField.delegate = self
        }
        return alertController
    }
}
