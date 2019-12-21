# Tips
## Build-in UI components
```TitleLabelMenuViewCell``` and ```UnderlineFocusView``` are build-in UI components. You don't need to make custom PagingMenuViewCell and PagingFoucsView, when your App require simple UI. 

[SimpleViewController](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/SimpleViewController.swift) in this repository helps you to understand usege. 

## Creating your custom UI components
PagingKit expects you to create a menu cell and foucs view. You can create and register them like UITableViewCell.

1. Inherite PagingMenuViewCell and create custom cell
2. Inherite PagingFocusView and create custom view
3. Register the above views to PagingMenuViewController

Read [this section](https://github.com/kazuhiro4949/PagingKit#3-create-menu-ui) or some sample code.

- [TagMenuCell](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/TagMenuCell.swift) and [TagMenuViewController](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/TagViewController.swift)
- [OverlayMenuCell](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/OverlayMenuCell.swift),  [OverlayFocusView](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/OverlayFocusView.swift) and [OverlayViewController](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/OverlayViewController.swift)

## Focused Cell Style
```PagingMenuViewCell``` has ```isSelected``` property. ```PagingMenuView``` updates the property if the focusing cell is changed. You can change the style　ｂｙ overriding the property.

```swift
class CustomCell: PagingMenuViewCell {
    override public var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = focusColor
            } else {
                titleLabel.textColor = normalColor
            }
        }
    }
}
```

## Cell Alignment
```PagingMenuViewController``` has an utility method to align cellls. 

https://github.com/kazuhiro4949/PagingKit/blob/master/PagingKit/PagingMenuViewController.swift#L110

If you want to align cells on the center, the following code will help you.

```swift
pagingMenuViewController.cellAligenment = .center
```

## Underline to have the same width as each title label
TitleLabelMenuViewCell supports this feature.

See SimpleViewController in the repository.


## Controlling PagingContentViewController's scroll

PagingContentViewController uses UIScrollView to scroll the contents.

You can disable the pan gesture as follows.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // contentViewController is a PagingContentViewController's object.
    // ...
    pagingContentView.scrollView.isScrollEnabled = false
}
```

Set false to “delaysContentTouches” in the scroll view when you have some controls (e.g. UISlider) in your contents.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // contentViewController is a PagingContentViewController's object.
    // ...
    contentViewController.scrollView.delaysContentTouches = false
}
```

## Initializing without Storyboard
Each class in PagingKit is kind of UIViewController or UIView.

So you can initialize them as you initialize UIViewController or UIView.

Sample Project has this case. see [InitializeWithoutStoryboardViewController](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/InitializingWithoutStoryboardViewController.swift)

## Put menu on UINavigationBar
Initialize PagingMenuView directly and set it to container view controller's navigationTitme.titleView
The following is part of the code. You can check the sample view controller. See [NavigationBarViewController](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/NavigationBarViewController.swift)

```swift
class NavigationBarViewController: UIViewController {
    
    
    lazy var menuView: PagingMenuView = {
        let menuView = PagingMenuView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        menuView.dataSource = self
        menuView.menuDelegate = self
        menuView.cellAlignment = .center
        
        menuView.register(type: TitleLabelMenuViewCell.self, with: "identifier")
        menuView.registerFocusView(view: UnderlineFocusView())
        return menuView
    }()
    var contentViewController: PagingContentViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.reloadData()
        contentViewController?.reloadData()

        navigationItem.titleView = menuView
    }
```

<img width="200" alt="2018-12-03 22 41 26" src="https://user-images.githubusercontent.com/18320004/49377139-aefa1400-f74c-11e8-9b6f-392f8f725caf.png">


## Animating alongside PagingMenuFocusView
You can add custom animation along PagingMenuFocusView

Typically, it is good to implement the animation in the following delegate.

```swift
func menuViewController(viewController: PagingMenuViewController, willAnimateFocusViewTo index: Int, with coordinator: PagingMenuFocusViewAnimationCoordinator) {
        coordinator.animateFocusView(alongside: { coordinator in
           // implement your custom animations in this closure.
        }, completion: nil)
}
```

Sample Project has a implementation to support the feature. See [OverlayViewController](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/OverlayViewController.swift#L108)

## RTL Support
PagingKit doesn't have RTL feature. In general, CGAffineTransform is a reasonable approach to implement RTL.

This is SampleViewController in the sample project.

<img width="200" alt="2018-12-03 22 29 30" src="https://user-images.githubusercontent.com/18320004/49376591-05665300-f74b-11e8-9e2e-c11797c8d116.png">

For example, you can change the scroll direction with the following code.

```swift
    override func viewDidLoad() {
        super.viewDidLoad()
        menuViewController?.menuView.transform = CGAffineTransform(scaleX: -1, y: 1) // <-
        contentViewController?.scrollView.transform = CGAffineTransform(scaleX: -1, y: 1) // <-
    }
```

It's not enough because PagingMenuViewCell and UITableViewCell is also transformed.

<img width="200" alt="2018-12-03 22 26 19" src="https://user-images.githubusercontent.com/18320004/49376416-7f4a0c80-f74a-11e8-8b03-82ef9a96fac2.png">

So you needs to apply transform to them.

```swift
extension SimpleViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! TitleLabelMenuViewCell
        cell.transform = CGAffineTransform(scaleX: -1, y: 1) // <-
        cell.titleLabel.text = dataSource[index].menu
        return cell
    }
}
```

```swift
extension SimpleViewController: PagingContentViewControllerDataSource {
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        let viewController = dataSource[index].content
        viewController.view.transform = CGAffineTransform(scaleX: -1, y: 1) // <-
        return dataSource[index].content
    }
}
```

Only the menu will start at the right.

<img width="200" alt="2018-12-03 22 22 29" src="https://user-images.githubusercontent.com/18320004/49376432-8cff9200-f74a-11e8-9a66-64e3f1fcbbfd.png">


## Code Snippets
There are some snippets to save your time. 

- https://github.com/kazuhiro4949/PagingKit/tree/master/tools/CodeSnippets

Install them on ```~/Library/Developer/Xcode/UserData/CodeSnippets/``` and restart Xcode. You can see the snippets on the right pane.

![1 -04-2018 16-33-59](https://user-images.githubusercontent.com/18320004/34553858-1e8a4876-f16d-11e7-97e1-605fa68896fd.gif)

