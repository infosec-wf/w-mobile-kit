//
//  WActionSheet.swift
//  WMobileKit

import Foundation
import UIKit
import SnapKit

let CANCEL_SEPARATOR_HEIGHT: CGFloat = 10.0
let ROW_HEIGHT: CGFloat = 58.0
let CANCEL_HEIGHT: CGFloat = 56.0
let HEADER_HEIGHT: CGFloat = 44.0
let SHEET_WIDTH_IPAD: CGFloat = 355.0
let SHEET_HEIGHT_MAX: CGFloat = 400.0

let ACTION_CELL = "actionCell"
let HEADER_VIEW = "headerView"

public enum ActionStyle {
    case Normal, Destructive
}

public enum SheetSeparatorStyle {
    case All, DestructiveOnly
}

public class WActionSheetVC<ActionDataType> : UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var darkView = UIView(frame: CGRectZero)
    private var containerView = UIView(frame: CGRectZero)
    private var cancelButton = UIButton(type: .System)
    private var actions = [WAction<ActionDataType>]()
    var tableView : UITableView?

    public var titleString: String?
    public var selectedIndex : Int?
    public var dismissOnAction = true
    public var sheetSeparatorStyle = SheetSeparatorStyle.DestructiveOnly {
        didSet {
            tableView?.reloadData()
        }
    }
    public var maxSheetHeight: CGFloat = SHEET_HEIGHT_MAX {
        didSet {
            setupUI(false);
        }
    }

    public var hasCancel = false

    // MARK: - Initialization
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            modalPresentationStyle = .OverCurrentContext
        } else {
            modalPresentationStyle = .OverFullScreen
        }

        modalTransitionStyle = .CrossDissolve

        providesPresentationContextTransitionStyle = true

        commonInit()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        animateIn()
    }

    public func commonInit() {
        view.addSubview(darkView)

        // Do not use #selector here, causes issue with iPhone 4S
        let darkViewRecognizer = UITapGestureRecognizer(target: self, action: Selector("animateOut"))
        darkView.addGestureRecognizer(darkViewRecognizer)

        // Do not use #selector here, causes issue with iPhone 4S
        cancelButton.addTarget(self, action: Selector("animateOut"), forControlEvents: .TouchUpInside)
        cancelButton.tintColor = .lightGrayColor()

        view.addSubview(containerView)
        view.addSubview(cancelButton)

        tableView = UITableView(frame: CGRectZero, style: .Plain)

        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.delaysContentTouches = false
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.scrollEnabled = true
        tableView?.bounces = false
        tableView?.allowsMultipleSelection = false
        tableView?.separatorStyle = .None

        tableView?.registerClass(WHeaderView.self, forHeaderFooterViewReuseIdentifier: HEADER_VIEW)
        tableView?.registerClass(WTableViewCell<ActionDataType>.self, forCellReuseIdentifier: ACTION_CELL)

        containerView.addSubview(tableView!)

        setupUI(false)
    }

    public func setupUI(animated: Bool) {
        let height = heightForActionSheet()
        preferredContentSize = CGSizeMake(SHEET_WIDTH_IPAD, height)

        containerView.snp_remakeConstraints { (make) in
            if (animated) {
                make.top.equalTo(view.snp_bottom)
            } else {
                if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                    make.centerY.equalTo(view)
                } else {
                    make.bottom.equalTo(view).offset(-10)
                }
            }
            if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                make.width.equalTo(SHEET_WIDTH_IPAD)
                make.centerX.equalTo(view)
            } else {
                make.left.equalTo(view).offset(10)
                make.right.equalTo(view).offset(-10)
            }
            make.height.equalTo(height)
        }
        containerView.backgroundColor = .clearColor()

        darkView.snp_remakeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
        }
        darkView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)

        if (hasCancel) {
            cancelButton.snp_remakeConstraints { (make) in
                make.left.equalTo(containerView)
                make.right.equalTo(containerView)
                make.height.equalTo(CANCEL_HEIGHT)
                make.bottom.equalTo(containerView)
            }

            cancelButton.setTitle("Cancel", forState: .Normal)
            cancelButton.setTitleColor(UIColor(hex: 0x595959), forState: .Normal)
            cancelButton.titleLabel?.font = UIFont.systemFontOfSize(20)
            cancelButton.backgroundColor = .whiteColor()
            cancelButton.layer.cornerRadius = 4
            cancelButton.clipsToBounds = true
        }

        tableView?.snp_remakeConstraints { (make) in
            make.left.equalTo(containerView)
            make.right.equalTo(containerView)
            make.top.equalTo(containerView)
            if (hasCancel) {
                make.bottom.equalTo(cancelButton.snp_top).offset(-CANCEL_SEPARATOR_HEIGHT)
            } else {
                make.bottom.equalTo(containerView)
            }
        }

        tableView?.layer.cornerRadius = 4
        tableView?.clipsToBounds = true
        tableView?.contentSize = CGSize(width: tableView!.contentSize.width, height: heightForSheetContent())
        if (titleString != nil) {
            tableView?.scrollIndicatorInsets = UIEdgeInsets(top: HEADER_HEIGHT, left: 0, bottom: 0, right: 0)
        }

        view.layoutIfNeeded()

        if (animated) {
            containerView.snp_remakeConstraints { (make) in
                if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                    make.centerY.equalTo(view)
                    make.centerX.equalTo(view)
                    make.width.equalTo(SHEET_WIDTH_IPAD)
                } else {
                    make.bottom.equalTo(view).offset(-10)
                    make.left.equalTo(view).offset(10)
                    make.right.equalTo(view).offset(-10)
                }
                make.height.equalTo(height)
            }

            UIView.animateWithDuration(0.35, delay: 0.1,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 5.0,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    self.view.layoutIfNeeded()
                },
                completion: nil)
        }
    }

    // MARK: - Helper Methods
    public func heightForActionSheet() -> CGFloat {
        let numCells = actions.count
        let height = ((CGFloat(numCells)) * ROW_HEIGHT) + (hasCancel ? (CANCEL_SEPARATOR_HEIGHT + CANCEL_HEIGHT) : 0) + (titleString != nil ? HEADER_HEIGHT : 0)
        return min(height, maxSheetHeight)
    }

    public func heightForSheetContent() -> CGFloat {
        let numCells = actions.count
        let height = ((CGFloat(numCells)) * ROW_HEIGHT)
        return height
    }

    public func animateIn() {
        setupUI(true)
    }

    public func animateOut() {
        animateOut(0.1)
    }

    public func animateOut(delay: NSTimeInterval) {
        containerView.snp_remakeConstraints { (make) in
            if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                make.centerX.equalTo(view)
                make.centerY.equalTo(view).offset(-10)
                make.width.equalTo(SHEET_WIDTH_IPAD)
            } else {
                make.bottom.equalTo(view).offset(-20)
                make.left.equalTo(view).offset(10)
                make.right.equalTo(view).offset(-10)
            }
            make.height.equalTo(heightForActionSheet())
        }

        UIView.animateWithDuration(0.05, delay: delay, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: { finished in
                self.containerView.snp_remakeConstraints { (make) in
                    if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                        make.width.equalTo(SHEET_WIDTH_IPAD)
                        make.centerX.equalTo(self.view)
                    } else {
                        make.left.equalTo(self.view).offset(10)
                        make.right.equalTo(self.view).offset(-10)
                    }
                    make.height.equalTo(self.heightForActionSheet())
                    make.top.equalTo(self.view.snp_bottom)
                }

                UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,
                    animations: {
                        self.view.layoutIfNeeded()
                    },
                    completion: { finished in
                        self.dismissViewControllerAnimated(true, completion: nil)
                })
        })
    }

    // MARK: - Actions
    public func addAction(action: WAction<ActionDataType>) {
        var actionCopy = action
        actionCopy.index = actions.count
        actions.append(actionCopy)

        setupUI(false)

        tableView?.reloadData()
    }

    // MARK: Action Selection Methods
    public func setSelectedAction(action: WAction<ActionDataType>) {
        setSelectedAction(action.index)
    }

    public func setSelectedAction(index: Int) {
        if (index >= actions.count || index < 0) {
            return
        }

        let path = NSIndexPath(forRow: index, inSection: 0)
        let cell = tableView?.cellForRowAtIndexPath(path) as! WTableViewCell<ActionDataType>

        cell.setSelectedAction(true)
        selectedIndex = index
    }

    public func toggleSelectedAction(action: WAction<ActionDataType>) {
        toggleSelectedAction(action.index)
    }

    public func toggleSelectedAction(index: Int) {
        if (index >= actions.count || index < 0) {
            return
        }

        let path = NSIndexPath(forRow: index, inSection: 0)
        let cell = tableView?.cellForRowAtIndexPath(path) as! WTableViewCell<ActionDataType>

        cell.setSelectedAction(!cell.isSelectedAction)
        selectedIndex = cell.selectBar.hidden ? selectedIndex : index
    }

    public func deselectAllActions() {
        for action in actions {
            deselectAction(action.index)
        }
    }

    public func deselectAction(index: Int? = nil) {
        var path : NSIndexPath?
        if let index = index {
            if (index > actions.count) {
                return
            }
            path = NSIndexPath(forRow: index, inSection: 0)
        } else if let selectedIndex = selectedIndex {
            path = NSIndexPath(forRow: selectedIndex, inSection: 0)
        } else {
            return
        }

        let cell = tableView?.cellForRowAtIndexPath(path!) as! WTableViewCell<ActionDataType>
        cell.setSelectedAction(false)
    }

    // MARK: - Table Methods
    public func actionForIndexPath(indexPath: NSIndexPath) -> WAction<ActionDataType>? {
        return actions[indexPath.row]
    }

    // MARK: - UITableViewDataSource
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return actions.count
        }

        return 0
    }

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ROW_HEIGHT
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : WTableViewCell<ActionDataType>

        cell = tableView.dequeueReusableCellWithIdentifier(ACTION_CELL) as! WTableViewCell

        let action = actionForIndexPath(indexPath)
        cell.backgroundColor = .whiteColor()
        cell.actionInfo = action

        cell.separatorBar.hidden = !((sheetSeparatorStyle == .All && indexPath.row != 0)
            || (sheetSeparatorStyle == .DestructiveOnly && action?.actionStyle == ActionStyle.Destructive))

        if (indexPath.row == selectedIndex) {
            cell.setSelectedAction(true)
        }

        return cell
    }

    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let WHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HEADER_VIEW) as! WHeaderView
        WHeader.title = titleString
        WHeader.contentView.backgroundColor = UIColor(hex: 0xF3F3F3)

        return WHeader
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return titleString != nil ? HEADER_HEIGHT : 0
    }

    // MARK: - UITableViewDelegate
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            // perform handler
            if let action = actionForIndexPath(indexPath) {
                action.handler?(action)
            }

            if (dismissOnAction) {
                animateOut(0.1)
            }
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

public struct WAction<T> {
    public private(set) var data: T?
    public var title: String?
    public var subtitle: String?
    public var image: UIImage?
    private var actionStyle : ActionStyle?
    private var handler : (WAction -> Void)?
    public var index = 0

    public init(title: String?,
                subtitle: String? = nil,
                image: UIImage? = nil,
                data: T? = nil,
                style: ActionStyle? = ActionStyle.Normal,
                handler: (WAction<T> -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.data = data
        self.actionStyle = style
        self.handler = handler
    }
}

// MARK: - Table Cell
public class WTableViewCell<ActionDataType> : UITableViewCell {
    private var actionInfo : WAction<ActionDataType>? {
        didSet {
            commonInit()
        }
    }

    var selectBar = WSelectBar(frame: CGRectZero)
    private var subtitleLabel : UILabel?
    private var titleLabel : UILabel?
    private var iconImageView : UIImageView?
    public private(set) var separatorBar = UIView(frame: CGRectZero)
    public private(set) var isSelectedAction = false

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        commonInit()
    }

    public func commonInit() {
        if (!subviews.contains(selectBar)) {
            contentView.addSubview(selectBar)
        }
        selectBar.snp_removeConstraints()
        selectBar.snp_makeConstraints { (make) in
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(3)
        }
        selectBar.hidden = true

        if (!subviews.contains(separatorBar)) {
            contentView.addSubview(separatorBar)
        }
        separatorBar.snp_removeConstraints()
        separatorBar.snp_makeConstraints { (make) in
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(0.5)
        }
        separatorBar.backgroundColor = UIColor(hex: 0xDADADE)

        if let actionInfo = actionInfo {
            if let image = actionInfo.image {
                if (iconImageView == nil) {
                    iconImageView = UIImageView(image: image)
                    addSubview(iconImageView!)
                }

                iconImageView?.snp_removeConstraints()
                iconImageView?.snp_makeConstraints(closure: { (make) in
                    make.left.equalTo(self).offset(14)
                    make.centerY.equalTo(self)
                    make.width.equalTo(25)
                    make.height.equalTo(25)
                })
            }

            if let subtitle = actionInfo.subtitle {
                if (subtitleLabel == nil) {
                    subtitleLabel = UILabel(frame: CGRectZero)
                    subtitleLabel?.adjustsFontSizeToFitWidth = true
                    addSubview(subtitleLabel!)
                }

                subtitleLabel?.text = subtitle
                subtitleLabel?.font = UIFont.systemFontOfSize(12)
                subtitleLabel?.textColor = UIColor(hex: 0x707070)

                subtitleLabel?.snp_removeConstraints()

                subtitleLabel?.snp_makeConstraints(closure: { (make) in
                    if (actionInfo.image != nil) {
                        make.left.equalTo(iconImageView!.snp_right).offset(16)
                    } else {
                        make.left.equalTo(self).offset(22)
                    }
                    make.right.equalTo(self)
                    make.height.equalTo(14)
                    make.bottom.equalTo(self).offset(-8)
                })
            }

            if let title = actionInfo.title {
                if (titleLabel == nil) {
                    titleLabel = UILabel(frame: CGRectZero)
                    addSubview(titleLabel!)
                }

                titleLabel?.text = title
                titleLabel?.font = UIFont.systemFontOfSize(20)
                titleLabel?.textColor = UIColor(hex: 0x595959)

                titleLabel?.snp_removeConstraints()

                titleLabel?.snp_makeConstraints(closure: { (make) in
                    make.height.equalTo(20)

                    if (actionInfo.image != nil) {
                        make.left.equalTo(iconImageView!.snp_right).offset(16)
                    } else {
                        make.left.equalTo(self).offset(22)
                    }

                    make.right.equalTo(self)

                    if (actionInfo.subtitle != nil) {
                        make.top.equalTo(self).offset(8)
                    } else {
                        make.centerY.equalTo(self)
                    }
                })
            }
        }

        layoutIfNeeded()
    }

    public override func setSelected(selected: Bool, animated: Bool) {
        let oldSeparatorColor = separatorBar.backgroundColor
        super.setSelected(selected, animated: animated)
        selectBar.backgroundColor = WThemeManager.sharedInstance.currentTheme.actionSheetSelectColor
        separatorBar.backgroundColor = oldSeparatorColor
    }

    public override func setHighlighted(highlighted: Bool, animated: Bool) {
        let oldSeparatorColor = separatorBar.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        selectBar.backgroundColor = WThemeManager.sharedInstance.currentTheme.actionSheetSelectColor
        separatorBar.backgroundColor = oldSeparatorColor
    }

    public func setSelectedAction(selected: Bool) {
        selectBar.hidden = !selected

        if let titleLabel = titleLabel {
            titleLabel.font = selected ? UIFont.boldSystemFontOfSize(titleLabel.font.pointSize) : UIFont.systemFontOfSize(titleLabel.font.pointSize)
        }

        if let subtitleLabel = subtitleLabel {
            subtitleLabel.font = selected ? UIFont.boldSystemFontOfSize(subtitleLabel.font.pointSize) : UIFont.systemFontOfSize(subtitleLabel.font.pointSize)
        }

        isSelectedAction = selected
    }
}

// MARK: Header View
public class WHeaderView : UITableViewHeaderFooterView {
    private var title : String? {
        didSet {
            commonInit()
        }
    }

    private var separatorBar = UIView(frame: CGRectZero)
    private var titleLabel : UILabel?

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        commonInit()
    }
    public func commonInit() {
        if (!subviews.contains(separatorBar)) {
            addSubview(separatorBar)
        }
        separatorBar.snp_removeConstraints()
        separatorBar.snp_makeConstraints { (make) in
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(0.5)
        }
        separatorBar.backgroundColor = UIColor(hex: 0xDADADE)
        
        if let title = title {
            if (titleLabel == nil) {
                titleLabel = UILabel(frame: CGRectZero)
                addSubview(titleLabel!)
            }
            titleLabel?.textAlignment = .Center
            titleLabel?.text = title
            titleLabel?.font = UIFont.systemFontOfSize(15)
            titleLabel?.textColor = UIColor(hex: 0x595959)
            
            titleLabel?.snp_remakeConstraints(closure: { (make) in
                make.left.equalTo(self)
                make.right.equalTo(self)
                make.height.equalTo(18)
                make.centerY.equalTo(self)
            })
        }
        
        layoutIfNeeded()
    }
}

// MARK: Select Bar
public class WSelectBar : UIView { }