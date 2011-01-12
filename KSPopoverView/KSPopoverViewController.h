//
//  KSPopoverViewController.h
//  KSPopoverView
//
//  Copyright 2010, 2011 KatokichiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSPopoverViewParentButton.h"
#import "KSPopoverViewButtonBase.h"

#import "KSPopoverViewButtonLabel.h"
#import "KSPopoverViewButtonOnOff.h"

typedef enum {
	KSPopoverTypeTextLabel = 0,
	KSPopoverTypeOnOffLabel,
} KSPopoverType;

typedef enum {
	KSPopoverStateNormal = 0,
	KSPopoverStateOpened,
} KSPopoverState;

typedef enum {
	KSPopoverPositionTopCenter = 0,
	KSPopoverPositionTopLeft,      // Not implemented
	KSPopoverPositionTopRight,
	KSPopoverPositionBottomCenter, // Not implemented
	KSPopoverPositionBottomLeft,   // Not implemented
	KSPopoverPositionBottomRight,  // Not implemented
} KSPopoverPosition;

@protocol KSPopoverViewControllerDelegate;

@interface KSPopoverViewController : UIViewController {
	@private
	// メニュー内の子要素
	Class klass;
	NSMutableArray *_childs;
	
	// 通常時、広がったときのサイズとその場所
	CGRect _normalFrame;
	CGRect _openedFrame;
	KSPopoverState _state;
	KSPopoverPosition _position;
	
	// ユーザーに見せるボタン相当
	KSPopoverViewParentButton *_button;
	UITouch *_firstTouch;
	
	id<KSPopoverViewControllerDelegate> _delegate;

	// デバッグ情報の表示
	BOOL _debug;
}

@property(nonatomic, retain) KSPopoverViewParentButton *button;
@property(retain) NSMutableArray *childs;
@property(nonatomic, assign) id<KSPopoverViewControllerDelegate> delegate;
@property(nonatomic, assign, readonly) CGRect frame;
@property(nonatomic, assign) KSPopoverPosition position;
@property(nonatomic, assign) BOOL debug;

- (id)initWithType:(KSPopoverType)type image:(UIImage *)buttonImage point:(CGPoint)point;
- (NSInteger)addButtonWithTitle:(NSString *)title;
- (KSPopoverViewButtonBase *)labelAtIndex:(NSInteger)index;
- (NSInteger)countOfLabels;
@end

#pragma mark -
@protocol KSPopoverViewControllerDelegate <NSObject>
@required
- (void)popoverViewController:(KSPopoverViewController *)controller
		  selectedButtonIndex:(NSInteger)buttonIndex;
@end

