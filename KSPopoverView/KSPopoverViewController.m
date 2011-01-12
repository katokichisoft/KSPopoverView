//
//  KSPopoverViewController.m
//  KSPopoverView
//
//  Copyright 2010, 2011 KatokichiSoft. All rights reserved.
//

#import "KSPopoverViewController.h"

#define BUTTON_GAP	5.0f	// ボタンの配置間隔

@interface KSPopoverViewController (private)
- (void)forwardTouches:(NSSet *)touches withEventType:(KSPopoverEventType)type;
- (void)hideMenu;
- (void)openMenu;
- (void)didEndHideChilds:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)updateFrameSize;
- (void)calculateFrameToHide:(KSPopoverViewButtonBase *)v;
- (void)calculateFrameWillShow:(KSPopoverViewButtonBase *)v;
@end

@implementation KSPopoverViewController
@synthesize button=_button;
@synthesize childs=_childs;
@synthesize position=_position;
@synthesize delegate=_delegate;
@synthesize debug=_debug;

- (id)initWithType:(KSPopoverType)type
			 image:(UIImage *)buttonImage
			 point:(CGPoint)point {
	if ([super init]) {
		_state = KSPopoverStateNormal;
		
		_normalFrame = CGRectMake(point.x, point.y,
								  buttonImage.size.width, buttonImage.size.height);
		_openedFrame = CGRectZero;
		self.button = [[KSPopoverViewParentButton alloc] initWithImage:buttonImage];
		self.button.userInteractionEnabled = YES;

		self.childs = [[NSMutableArray alloc] init];
		self.debug = NO;
		
		switch (type) {
			case KSPopoverTypeTextLabel:
				klass = [KSPopoverViewButtonLabel class];
				break;
			case KSPopoverTypeOnOffLabel:
				klass = [KSPopoverViewButtonOnOff class];
				break;
			default:
				break;
		}
	}
	return self;
}

- (void)resetFrame {
	self.view.frame = _normalFrame;
}

- (void)loadView {
	[super loadView];

	self.view.frame = _normalFrame;
	self.view.backgroundColor = [UIColor clearColor];
	self.view.multipleTouchEnabled = YES;
	self.view.userInteractionEnabled = YES;
	[self.view addSubview:self.button];

	// TabBarControllerのせいかステータスバーのせいか不明だが、ビュー構造によってはframeが
	// 書き換えられてしまうため、イベント終了後に再設定する。
	[self performSelector:@selector(resetFrame) withObject:nil afterDelay:0.0f];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	NSLog(@"viewDidUnload is called.");
	self.button = nil;
	self.childs = nil;
}


- (void)dealloc {
	NSLog(@"deallocated:%@", self);

	self.button = nil;
	self.childs = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Convenience methods
- (void)updateFrameSize {
	CGFloat maxWidth = 0.0f;
	CGFloat sumHeights = 0.0f;
	for (KSPopoverViewButtonBase *v in self.childs) {
		maxWidth = (maxWidth>[v preferredSize].width)?maxWidth:[v preferredSize].width;
		sumHeights += [v preferredSize].height + BUTTON_GAP;
	}
	switch (self.position) {
		case KSPopoverPositionTopRight:
			_openedFrame = CGRectMake(_normalFrame.origin.x,
									  _normalFrame.origin.y-sumHeights,
									  fmax(_normalFrame.size.width, maxWidth),
									  _normalFrame.size.height+sumHeights);			
			break;
		case KSPopoverPositionTopCenter:
			_openedFrame = CGRectMake(_normalFrame.origin.x - (fmax(_normalFrame.size.width, maxWidth)-_normalFrame.size.width)/2.0,
									  _normalFrame.origin.y-sumHeights,
									  fmax(_normalFrame.size.width, maxWidth),
									  _normalFrame.size.height+sumHeights);			
			break;
		default:
			NSAssert(0, @"Specified position is not implemented!");
			break;
	}
}

- (void)calculateFrameToHide:(KSPopoverViewButtonBase *)v {
	switch (self.position) {
		case KSPopoverPositionTopRight:
			v.frame = CGRectMake(self.button.frame.origin.x,
								 self.button.frame.origin.y,
								 v.frame.size.width, v.frame.size.height);
			break;
		case KSPopoverPositionTopCenter:
			v.frame = CGRectMake((self.button.frame.size.width-v.frame.size.width)/2.0f,
								 self.button.frame.origin.y,
								 v.frame.size.width, v.frame.size.height);
			break;
		default:
			NSAssert(0, @"Specified position is not implemented!");
			break;
	}
}

- (void)calculateFrameWillShow:(KSPopoverViewButtonBase *)v {
	switch (self.position) {
		case KSPopoverPositionTopRight:
			v.frame = CGRectMake(0.0f, 0.0f,
								 _openedFrame.size.width,
								 [v preferredSize].height);
			break;
		case KSPopoverPositionTopCenter:
			v.frame = CGRectMake(-(_openedFrame.size.width-self.button.frame.size.width)/2.0f, 0.0f,
								 _openedFrame.size.width,
								 [v preferredSize].height);
			break;
		default:
			NSAssert(0, @"Specified position is not implemented!");
			break;
	}
}

#pragma mark -
- (CGRect)frame {
	return _normalFrame;
}

- (void)setPosition:(KSPopoverPosition)pos {
	_position = pos;
	// 親ボタン画像の固定位置を再指定
	switch (pos) {
		case KSPopoverPositionTopRight:
			self.button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
			| UIViewAutoresizingFlexibleRightMargin;
			break;
		case KSPopoverPositionTopCenter:
			self.button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
			| UIViewAutoresizingFlexibleLeftMargin
			| UIViewAutoresizingFlexibleRightMargin;
			break;
		default:
			break;
	}
}
#pragma mark -
- (void)forwardTouches:(NSSet *)touches withEventType:(KSPopoverEventType)type {
	NSArray *array = [touches allObjects];
	for (UITouch *t in array) {
		NSUInteger index = 0;
		for (KSPopoverViewButtonBase *child in self.childs) {
			// ボタンに位置を渡して、イベントハンドリングを確認する
			// 返戻値がYESだったら、イベントは処理されたとしてbreak,次のタッチイベントへ
			BOOL handled = [child handleTouchAtPoint:[t locationInView:self.view]
										 withState:type];
			if (handled) {
				if (self.delegate) {
					if ([self.delegate respondsToSelector:
						 @selector(popoverViewController:selectedButtonIndex:)]) {
						[self.delegate popoverViewController:self
										 selectedButtonIndex:index];
						break;
					} else {
						NSLog(@"delegate object does not implement required methods.");
					}
				} else {
					NSLog(@"delegate is not set.");
				}
			}
			++index;
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_state == KSPopoverStateNormal) {
		_state = KSPopoverStateOpened;
		[self openMenu];
		_firstTouch = [touches anyObject];
	}

	[self forwardTouches:touches withEventType:KSPopoverEventTouchesBegan];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	_state = KSPopoverStateOpened;

	[self forwardTouches:touches withEventType:KSPopoverEventTouchesMoved];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	_state = KSPopoverStateNormal;

	[self forwardTouches:touches withEventType:KSPopoverEventTouchesEnded];

	if ([[touches allObjects] count] == 1 && _firstTouch==[touches anyObject]) {
		[self performSelector:@selector(hideMenu) withObject:nil afterDelay:0.1f];
		_firstTouch = nil;
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	_state = KSPopoverStateNormal;

	[self forwardTouches:touches withEventType:KSPopoverEventTouchesEnded];

	if ([[touches allObjects] count] == 1 && _firstTouch==[touches anyObject]) {
		[self performSelector:@selector(hideMenu) withObject:nil afterDelay:0.1f];
		_firstTouch = nil;
	}
}

#pragma mark -
#pragma mark Animation selector
- (void)openMenu {
	// childsのラベルを配置
	[self updateFrameSize];
	for (KSPopoverViewButtonBase *v in self.childs) {
		// 場所を計算
		[self calculateFrameWillShow:v];
		v.alpha = 0.0f;
		v.userInteractionEnabled = YES;
		[self.view addSubview:v];
	}
	
	// アニメーション開始
	[UIView beginAnimations:@"FadeInKSPopoverView" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.2f];
	self.view.frame = _openedFrame;
	CGFloat sumHeight = 0.0;
	for (KSPopoverViewButtonBase *v in self.childs) {
		v.frame = CGRectMake(0.0f,
							 sumHeight,
							 v.frame.size.width,
							 v.frame.size.height);
		v.alpha = 1.0f;

		sumHeight += v.frame.size.height + BUTTON_GAP;
	}
	[UIView commitAnimations];
}
- (void)hideMenu {
	for (KSPopoverViewButtonBase *v in self.childs) {
		v.userInteractionEnabled = NO;
	}
	[UIView beginAnimations:@"FadeOutKSPopoverView" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.2f];
	[UIView setAnimationDidStopSelector:@selector(didEndFadeout:finished:context:)];
	self.view.frame = _normalFrame;
	// 親ボタンに集合
	for (KSPopoverViewButtonBase *v in self.childs) {
		[self calculateFrameToHide:v];
		v.alpha = 0.0f;
		[v resetSelected];
	}
	[UIView commitAnimations];
}

- (void)didEndHideChilds:(NSString *)animationID
				finished:(NSNumber *)finished
				 context:(void *)context {
	// ボタン群をビューから除去
	for (KSPopoverViewButtonBase *v in self.childs) {
		v.alpha = 1.0f;
		[v removeFromSuperview];
	}
}

#pragma mark -
- (NSInteger)addButtonWithTitle:(NSString *)title {
	// 子ボタンの追加
	KSPopoverViewButtonBase *label = [[klass alloc] initWithFrame:CGRectZero];
	label.text = title;
	[self.childs addObject:label];
	[label release];
	
	return [self.childs count] - 1;
}

- (KSPopoverViewButtonBase *)labelAtIndex:(NSInteger)index {
	return [self.childs objectAtIndex:index];
}

- (NSInteger)countOfLabels {
	return [self.childs count];
}

#pragma mark -
#pragma mark For debugging
- (void)setDebug:(BOOL)yesno {
	_debug = yesno;
	if (_debug) {
		self.view.backgroundColor = [UIColor greenColor];
	} else {
		self.view.backgroundColor = [UIColor clearColor];
	}
}
@end
