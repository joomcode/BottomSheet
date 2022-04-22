# Bottom Sheet

Bottom Sheet component is designed to handle any content, including a scrolling one.
- ✅ use any content size, and it will adapt
- ✅ use scrollable content: `UICollectionView`, `UITableView` or `UIScrollView` 
- ✅ dismiss interactively by swipe-down or just tapping on an empty space
- ✅ build flows inside using `BottomSheetNavigationController`
    - ✅ supports all system transitions: push and (interactive) pop
    - ✅ transition animated between different content sizes

## How it looks like

| Adapts to content size | Interactive dismissal |
| - | - |
| ![adapt-to-content-size](https://user-images.githubusercontent.com/52037202/164746215-64b61eb3-5813-483f-b639-d730e1cbec8c.gif) | ![interactive-dismissal](https://user-images.githubusercontent.com/52037202/164746241-2fa6ec19-eaae-4fcc-9036-9119df68da54.gif) |

### NavigationController inside Bottom Sheet

| Push and pop transitions | Interactive pop transition |
| - | - |
| ![system-push-pop](https://user-images.githubusercontent.com/52037202/164747115-cddbe4fb-403f-4333-994b-64545a7f9a28.gif) | ![interactive-pop](https://user-images.githubusercontent.com/52037202/164746311-74f0c872-3255-4ae5-b895-8c96d7cffb2c.gif) |

## Installation

### Swift Package Manager

To integrate Bottom Sheet into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/joomcode/BottomSheet", from: "1.0.0")
]
```

## Getting started

This repo contains [demo](https://github.com/joomcode/BottomSheet/tree/main/BottomSheetDemo), which can be a great start for understanding Bottom Sheet usage, but here are simple steps to follow:
1. Set content's size using [preferredContentSize](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621476-preferredcontentsize)
2. (optional) Conform to `ScrollableBottomSheetPresentedController` if your view controller is list-based
3. Present using custom transition `BottomSheetTransitioningDelegate`

## Resources

Read the [article on Medium](https://medium.com/me/stats/post/400515255829) for betting understanding of how it works under the hood
