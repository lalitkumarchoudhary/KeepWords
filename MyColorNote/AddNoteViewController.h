//
//  AddNoteViewController.h
//  MyColorNote
//
//  Created by Lalit Choudhary on 23/04/15.
//  Copyright (c) 2015 Lalit Choudhary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AddNoteViewController : UIViewController<UIAlertViewDelegate, UIGestureRecognizerDelegate>
@property (strong) NSManagedObject *note;
@end
