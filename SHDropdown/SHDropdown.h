//
//  SHDropdown.m
//  SHDropdown
//
//  Created by Nishadh Shrestha on 3/21/15.
//  Copyright (c) 2015 Nishadh Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SHDropdownItem : NSObject
- (id)init:(NSString *) title;
- (id)init:(NSString *) title tag:(NSObject*) tag;

@property (copy) NSString *title;
@property (retain) NSObject *tag;
@end

@class SHDropdown; //Forward declaration for sending via delegate
@protocol SHDropDownDelegate <NSObject>
@optional
-(void)dropDown:(SHDropdown *)dropDown didSelectRow:(SHDropdownItem *)item row:(NSInteger)row;
-(void)dropDown:(SHDropdown *)dropDown didChangeSelection:(SHDropdownItem *)newItem newRow:(NSInteger)newRow oldRow:(NSInteger)oldRow ;
@end // end of delegate protocol

@interface SHDropdownArrowView : UIView
+(SHDropdownArrowView*) default:(CGRect)frame;
@end

@interface SHDropdown : UITextField<UITextFieldDelegate>
@property (nonatomic, weak) id<SHDropDownDelegate> dropDownDelegate;
@property(readonly) NSMutableArray *items;
@property NSInteger selectedIndex;

- (void) selectedRow:(NSInteger)row item:(SHDropdownItem *)item;
- (void) addItem:(SHDropdownItem *)item;
- (SHDropdownItem *) getSelectedItem;
- (void) removeAllItems;
@end

@interface SHMenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
- (id)init:(SHDropdown *) dd;
- (void) presentView;
- (NSInteger) getMaxTitleWidth;
@end

