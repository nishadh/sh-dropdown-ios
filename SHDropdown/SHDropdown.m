//
//  SHDropdown.m
//  SHDropdown
//
//  Created by Nishadh Shrestha on 3/21/15.
//  Copyright (c) 2015 Nishadh Shrestha. All rights reserved.
//

#import "SHDropdown.h"

// Drop down item
@implementation SHDropdownItem
- (id)init:(NSString *) title {
    self = [super init];
    if (self) {
        self.title = title;
    }
    return self;
}

- (id)init:(NSString *) title tag:(NSObject*) tag {
    self = [super init];
    if (self) {
        self.title = title;
        self.tag = tag;
    }
    return self;
}
@end


@implementation SHDropdownArrowView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
+(SHDropdownArrowView*) default:(CGRect)frame {
    
    SHDropdownArrowView* view = [[SHDropdownArrowView alloc] initWithFrame:frame];
    //view.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    view.backgroundColor = [UIColor whiteColor];
    // Create the path (with only the top-left corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(6.0, 10.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    view.layer.mask = maskLayer;
    
    return view;
    
}


- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat left = rect.origin.x + 7;
    CGFloat width = rect.size.width - 14;
    CGFloat height = width - 4;
    CGFloat top = rect.size.height / 2 - height / 2;
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f].CGColor);
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(ctx, 2.0f);
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect) + 3); //start at this point
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect) - 3); //draw to this point
    // and now draw the Path!
    CGContextStrokePath(ctx);
    
    
    CGRect rectSmaller = CGRectMake(left, top, width, height);
    
    CGRectInset(rect, 10, 10);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(rectSmaller), CGRectGetMinY(rectSmaller));  // top left
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rectSmaller), CGRectGetMinY(rectSmaller));  // mid right
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rectSmaller), CGRectGetMaxY(rectSmaller));  // bottom left
    CGContextClosePath(ctx);
    
    CGContextSetRGBFillColor(ctx, 0.5, 0.5, 0.5, 1);
    CGContextFillPath(ctx);
}

@end


@implementation SHDropdown

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        
        _items = [[NSMutableArray alloc] initWithCapacity:40];
        self.selectedIndex = -1;
        
        self.rightView = [SHDropdownArrowView default:CGRectMake(0, 1, 24, self.frame.size.height - 2)];
        self.rightViewMode = UITextFieldViewModeAlways;
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                       byRoundingCorners:UIRectCornerAllCorners
                                                             cornerRadii:CGSizeMake(6.0, 10.0)];
        
        // Create the shape layer and set its path
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        
        // Set the newly created shape layer as the mask for the image view's layer
        self.layer.mask = maskLayer;
        self.delegate = self;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
        singleTap.numberOfTapsRequired = 1;
        [self  setUserInteractionEnabled:YES];
        [self addGestureRecognizer:singleTap];
    }
    
    return self;
}

-(void)addItem:(SHDropdownItem *)item {
    if (_items.count == 0) {
        self.text = item.title; // Default item
        self.selectedIndex = 0;
    }
    [_items addObject:item];
}

-(void)removeAllItems{
    self.text = @"";
    self.selectedIndex = -1;
    [_items removeAllObjects];
}

- (SHDropdownItem *) getSelectedItem {
    if (self.selectedIndex == -1) {
        return nil;
    } else {
        return (SHDropdownItem *)[_items objectAtIndex: self.selectedIndex];
    }
}

-(void)tapDetected{
    SHMenuViewController *view = [[SHMenuViewController alloc] init: self];
    [view presentView];
}

-(void)selectedRow:(NSInteger)row item:(SHDropdownItem *)item {
    self.text = item.title;
    NSInteger oldRow = self.selectedIndex;
    self.selectedIndex = row;
    
    if ([self dropDownDelegate]) {
        if([[self dropDownDelegate] respondsToSelector:@selector(dropDown:didSelectRow:row:)]) {
            [[self dropDownDelegate] dropDown:self didSelectRow:item row:row];
        }
        
        if(oldRow != row &&  [[self dropDownDelegate] respondsToSelector:@selector(dropDown:didChangeSelection:newRow:oldRow:)]) {
            [[self dropDownDelegate] dropDown:self didChangeSelection:item newRow: row oldRow: oldRow];
        }
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    SHMenuViewController *view = [[SHMenuViewController alloc] init: self];
    [view presentView];
    return NO;  // Hide both keyboard and blinking cursor.
}

@end

@implementation SHMenuViewController

SHDropdown* dropdown;
UIPickerView *myPickerView;
UIPopoverController *currentPopover;
UITableView *tableView;

- (id)init:(SHDropdown *) dd {
    self = [super init];
    if (self)
    {
        dropdown = dd; //Assume that mode is a class variable
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (dropdown.items.count > 0) {
        tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)]; // Remove blank rows
        //[tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.view addSubview:tableView];
        
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:dropdown.selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        tableView.layoutMargins = UIEdgeInsetsZero;
        
        
        [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:NSDictionaryOfVariableBindings(tableView)]];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-0-[tableView]-0-|"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:NSDictionaryOfVariableBindings(tableView)]];
    } else {
        // Add a label to tell user the drop down is empty
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setText:@"No items available!"];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label sizeToFit];
        [self.view addSubview:label];
        // Center label on the screen
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label  attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label  attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) presentView {
    currentPopover = [[UIPopoverController alloc] initWithContentViewController: self];
    
    if (dropdown.items.count > 0) {
        currentPopover.popoverContentSize = CGSizeMake(self.getMaxTitleWidth + 40, dropdown.items.count * 44);
    } else {
        currentPopover.popoverContentSize = CGSizeMake(200, 50);
    }
    
    [currentPopover presentPopoverFromRect:dropdown.rightView.frame inView:dropdown permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

- (NSInteger) getMaxTitleWidth {
    NSInteger width = 1;
    for (SHDropdownItem* item in dropdown.items) {
        CGSize labelSize = [item.title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
        if (labelSize.width > width) {
            width = labelSize.width;
        }
    }
    return width;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dropdown.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    SHDropdownItem *item = dropdown.items[indexPath.row];
    cell.textLabel.text = item.title;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    //cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.layoutMargins = UIEdgeInsetsZero;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"you clicked on button %ld", (long)sender.tag);
    NSInteger row = indexPath.row;
    SHDropdownItem *item = dropdown.items[row];
    [dropdown selectedRow:row item:item];
    [currentPopover dismissPopoverAnimated:YES];
}

@end
