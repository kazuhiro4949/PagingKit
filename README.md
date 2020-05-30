![img](https://user-images.githubusercontent.com/18320004/31583441-eb6ff894-b1d6-11e7-943a-675d6460919a.png)


[![Platform](https://img.shields.io/cocoapods/p/PagingKit.svg?style=flat)](http://cocoapods.org/pods/PagingKit)
![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg)
[![License](https://img.shields.io/cocoapods/l/PagingKit.svg?style=flat)](http://cocoapods.org/pods/PagingKit)
[![Version](https://img.shields.io/cocoapods/v/PagingKit.svg?style=flat)](http://cocoapods.org/pods/PagingKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)

PagingKit provides customizable menu & content UI. It has more flexible layout and design than the other libraries.

# What's this?
There are many libraries providing "Paging UI" which have menu and content area.
They are convenient but not customizable because your app has to be made compatible with the libraries' layout and view components.
When a UI desgin in your app doesn't fit the libraries, you need to fork them or find another one. 

PagingKit has more flexible layout and design than the other libraries.
You can construct "Menu" and "Content" UI, and they work together. That's all features this library provides.
You can fit any design to your apps as you like.

![paging_sample](https://user-images.githubusercontent.com/18320004/31575892-35860ae2-b12b-11e7-9525-1825c69b094f.gif)

## Customized layout 
You can align views as you like.

| changing position | placing a view between content and menu | added floating button on right-side | on navigation bar | 
|:------------:|:------------:|:------------:|:------------:|
| ![sample_5](https://user-images.githubusercontent.com/18320004/31857631-08683bf4-b71e-11e7-83c4-ee4e942b5ea1.gif) | ![sample_4](https://user-images.githubusercontent.com/18320004/31857630-075948c0-b71e-11e7-9ea7-3d490c733b7f.gif) | ![sample6](https://user-images.githubusercontent.com/18320004/33793722-f9806f46-dcff-11e7-9909-a9f87e9ef4a0.gif) | <img width="320" alt="2018-12-04 10 00 51" src="https://user-images.githubusercontent.com/18320004/49411286-aa187d00-f7ab-11e8-9672-094e10853778.png"> |

## Customized menu design
You can customize menu as you like.

| tag like menu | text highlighted menu | underscore menu | App Store app like indicator | 
|:------------:|:------------:|:------------:|:------------:|
| ![sample_3](https://user-images.githubusercontent.com/18320004/31857535-d8b6965a-b71b-11e7-928d-46375c2cfb7b.gif) | <img src="https://user-images.githubusercontent.com/18320004/49323491-a42e5c00-f55f-11e8-9690-295acc2c3341.gif" width=280>  | ![sample_1](https://user-images.githubusercontent.com/18320004/31857533-d69720ba-b71b-11e7-9401-534596dbb76d.gif) | ![indicator](https://user-images.githubusercontent.com/18320004/32141748-3e6c4fc6-bccb-11e7-8a6a-0286982f938b.gif) |


# Feature
- [x] easy to construct Paging UI
- [x] customizable layout and design
- [x] UIKit like API
- [x] Supporting iPhone, iPad and iPhone X

# Requirements
+ iOS 9.0+
+ Xcode 11.0+
+ Swift 5.1

# Installation

## Swift Package Manager
open Swift Packages (which is next to Build Settings). You can add and remove packages from this tab.

See [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

## CocoaPods
+ Install CocoaPods
```
> gem install cocoapods
> pod setup
```
+ Create Podfile
```
> pod init
```
+ Edit Podfile
```ruby
target 'YourProject' do
  use_frameworks!

  pod "PagingKit" # add

  target 'YourProject' do
    inherit! :search_paths
  end

  target 'YourProject' do
    inherit! :search_paths
  end

end
```

+ Install

```
> pod install
```
open .xcworkspace

## Carthage
+ Install Carthage from Homebrew
```
> ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
> brew update
> brew install carthage
```
+ Move your project dir and create Cartfile
```
> touch Cartfile
```
+ add the following line to Cartfile
```
github "kazuhiro4949/PagingKit"
```
+ Create framework
```
> carthage update --platform iOS
```

+ In Xcode, move to "Genera > Build Phase > Linked Frameworks and Library"
+ Add the framework to your project
+ Add a new run script and put the following code
```
/usr/local/bin/carthage copy-frameworks
```
+ Click "+" at Input file and Add the framework path
```
$(SRCROOT)/Carthage/Build/iOS/PagingKit.framework
```
+ Write Import statement on your source file
```
import PagingKit
```

# Getting Started

There are some samples in this library.

https://github.com/kazuhiro4949/PagingKit/tree/master/iOS%20Sample/iOS%20Sample

You can fit PagingKit into your project as the samples do. Check out this repository and open the workspace.

PagingKit has two essential classes.
- PagingMenuViewController
- PagingContentViewController

PagingMenuViewController provides interactive menu for each content. PagingContentViewController provides the contents on a scrollview.

If you make a new project which contains PagingKit, follow the steps.

1. Add PagingMenuViewController & PagingContentViewController
2. Assign them to properties
3. Create menu UI
4. display data
5. Synchronize Menu and Content view controllers

## 1. Add PagingMenuViewController & PagingContentViewController
First, add PagingMenuViewController & PagingContentViewController on container view with Stroyboard.

### 1. Put container views on Storyboard
Put container views on stroyboard for each the view controllers.

<img width="1417" alt="2017-08-25 16 33 51" src="https://user-images.githubusercontent.com/18320004/29704102-491f0e72-89b3-11e7-9d69-7988969ef18e.png">

### 2. Change class names

input PagingMenuViewController on custom class setting.
<img width="1418" alt="2017-08-25 16 36 36" src="https://user-images.githubusercontent.com/18320004/29704183-a59ab390-89b3-11e7-9e72-e98ee1e9abc0.png">

input PagingContentViewController on custom class setting.

<img width="1415" alt="2017-08-25 16 36 54" src="https://user-images.githubusercontent.com/18320004/29704184-a669f344-89b3-11e7-91b6-90669fa2190f.png">

## 2. Assign them to properties

Assign them on code of the container view controller.

### 1. Declare properties for the view controllers 
Declare properties in container view controller.
```swift
class ViewController: UIViewController {
    
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
```

### 2. override prepare(segue:sender:) and assign the view controllers
Assigin view controllers to each the property on ```prepare(segue:sender:)```.

```swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
        }
    }
```

### 3. Build App
Change menu color.
<img width="1097" alt="2017-08-25 17 47 58" src="https://user-images.githubusercontent.com/18320004/29706662-922732ac-89bd-11e7-8969-bd6fbe394a8a.png">

Build and check the current state.

<img width="487" alt="2017-08-25 17 47 29" src="https://user-images.githubusercontent.com/18320004/29706651-84749258-89bd-11e7-9239-6919a0175a17.png">

It shows a container view controller that has PagingMenuViewController and PagingContentViewController.

## 3. Create menu UI

Next, you needs to prepare the menu elements.

### 1. Inherite PagingMenuViewCell and create custom cell

PagingKit has PagingMenuViewCell. PagingMenuViewController uses it to construct each menu element.

```swift
import UIKit
import PagingKit

class MenuCell: PagingMenuViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
```

<img width="1414" alt="2017-08-25 16 56 56" src="https://user-images.githubusercontent.com/18320004/29704850-7b877cd4-89b6-11e7-98c9-48eb94646291.png">


### 2. Inherite PagingFocusView and create custom view

PagingKit has PagingFocusView. PagingMenuViewController uses it to point the current focusted menu.

<img width="1420" alt="2017-08-25 16 59 07" src="https://user-images.githubusercontent.com/18320004/29704919-bd3d8f06-89b6-11e7-88dc-c8546979dbde.png">


### 3. register the above views to PagingMenuViewController

```swift
class ViewController: UIViewController {
    
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewController.register(nib: UINib(nibName: "MenuCell", bundle: nil), forCellWithReuseIdentifier: "MenuCell")
        menuViewController.registerFocusView(nib: UINib(nibName: "FocusView", bundle: nil))
    }
```

## 4. display data

Then, implement the data sources to display contents. They are a similar to UITableViewDataSource.

### 1. prepare data

```swift
class ViewController: UIViewController {
    static var viewController: (UIColor) -> UIViewController = { (color) in
       let vc = UIViewController()
        vc.view.backgroundColor = color
        return vc
    }
    
    var dataSource = [(menuTitle: "test1", vc: viewController(.red)), (menuTitle: "test2", vc: viewController(.blue)), (menuTitle: "test3", vc: viewController(.yellow))]
```

### 2. set menu data source

Return number of menus, menu widthes and PagingMenuViewCell objects.

```swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self // <- set menu data source
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
        }
    }
}

extension ViewController: PagingMenuViewControllerDataSource {
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return 100
    }
    
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: index) as! MenuCell
        cell.titleLabel.text = dataSource[index].menuTitle
        return cell
    }
}
```

### 3. configure content data source

Return the number of contents and view controllers.

```swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController.dataSource = self // <- set content data source
        }
    }
}

extension ViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].vc
    }
}
```

### 4. load UI

Call reloadData() methods with starting point.

```swift
    override func viewDidLoad() {
        super.viewDidLoad()
        //...
        //...
        menuViewController.reloadData()
        contentViewController.reloadData()
    }
```

Build and display data source.

<img width="487" alt="2017-08-25 17 54 30" src="https://user-images.githubusercontent.com/18320004/29706950-7e1b41a8-89be-11e7-8bb2-fc90afbe11f7.png">

## 5. Synchronize Menu and Content view controllers

Last, synchronize user interactions between Menu and Content.

### 1. set menu delegate

```swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self
            menuViewController.delegate = self // <- set menu delegate
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController.dataSource = self
        }
    }
}
```

Implement menu delegate to handle the event. It is a similar to UITableViewDelegate. You need to implement scroll method of PagingContentViewController in the delegate method.

```swift

extension ViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
}
```

### 2. set content delegate

```swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self
            menuViewController.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController.dataSource = self
            contentViewController.delegate = self // <- set content delegate
        }
    }
}
```

Implement content delegate to handle the event. It is similar to UIScrollViewDelegate. You need to implement the scroll event of PagingMenuViewController. "percent" is distance from "index" argument to the right-side page index.

```swift
extension ViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController.scroll(index: index, percent: percent, animated: false)
    }
}
```

That's it.

# Tips
- [Build-in UI components](https://github.com/kazuhiro4949/PagingKit/blob/master/Documentation/Tips.md#build-in-ui-components)
- [Focused Cell Style](https://github.com/kazuhiro4949/PagingKit/blob/master/Documentation/Tips.md#focused-cell-style)
- [Cell Alignment](https://github.com/kazuhiro4949/PagingKit/blob/master/Documentation/Tips.md#cell-alignment)
- [Underline to have the same width as each title label](https://github.com/kazuhiro4949/PagingKit/blob/master/Documentation/Tips.md#underline-to-have-the-same-width-as-each-title-label)
- [Controlling PagingContentViewController's scroll](https://github.com/kazuhiro4949/PagingKit/blob/master/Documentation/Tips.md#controlling-pagingcontentviewcontrollers-scroll)
- [Initializing without Storyboard](https://github.com/kazuhiro4949/PagingKit/blob/master/Documentation/Tips.md#initializing-without-storyboard)
- [Put menu on UINavigationBar](https://github.com/kazuhiro4949/PagingKit/blob/master/Documentation/Tips.md#put-menu-on-uinavigationbar)
- [Animating alongside PagingMenuFocusView](https://github.com/kazuhiro4949/PagingKit/blob/master/Documentation/Tips.md#animating-alongside-pagingmenufocusview)
- [RTL Support](https://github.com/kazuhiro4949/PagingKit/blob/master/Documentation/Tips.md#rtl-support)
- [Code Snippets](https://github.com/kazuhiro4949/PagingKit/blob/master/Documentation/Tips.md#code-snippets)

# Class Design
There are some design policy in this library.

- The behavior needs to be specified by the library.
- The layout should be left to developers.
- Arrangement of the internal components must be left to developers.

Because of that, PagingKit has responsiblity for the behavior. But it doesn't specify a structure of the components.
PagingKit favours composition over inheritance. This figure describes overview of the class diagram.

<img src="https://user-images.githubusercontent.com/18320004/38431789-628100e8-3a00-11e8-8ae2-30cd6122ec9a.png" width="500" />

# Work with RxSwift

PagingKit goes well with RxSwift.

https://github.com/kazuhiro4949/RxPagingKit

```swift
    let items = PublishSubject<[(menu: String, width: CGFloat, content: UIViewController)]>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewController?.register(type: TitleLabelMenuViewCell.self, forCellWithReuseIdentifier: "identifier")
        menuViewController?.registerFocusView(view: UnderlineFocusView())
        
        // PagingMenuViewControllerDataSource
        items.asObserver()
            .map { items in items.map({ ($0.menu, $0.width) }) }
            .bind(to: menuViewController.rx.items(
                cellIdentifier: "identifier",
                cellType: TitleLabelMenuViewCell.self)
            ) { _, model, cell in
                cell.titleLabel.text = model
            }
            .disposed(by: disposeBug)
        
        // PagingContentViewControllerDataSource
        items.asObserver()
            .map { items in items.map({ $0.content }) }
            .bind(to: contentViewController.rx.viewControllers())
            .disposed(by: disposeBug)
        
        // PagingMenuViewControllerDelegate
        menuViewController.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] (page, prev) in
            self?.contentViewController.scroll(to: page, animated: true)
        }).disposed(by: disposeBug)
        
        // PagingContentViewControllerDelegate
        contentViewController.rx.didManualScroll.asObservable().subscribe(onNext: { [weak self] (index, percent) in
            self?.menuViewController.scroll(index: index, percent: percent, animated: false)
        }).disposed(by: disposeBug)
    }
```



# License

Copyright (c) 2017 Kazuhiro Hayashi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
