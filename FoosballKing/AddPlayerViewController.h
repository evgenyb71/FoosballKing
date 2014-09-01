//
//  AddPlayerViewController.h
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/31/14.
//
//

#import <UIKit/UIKit.h>

/*
 Simple Add New or Edit Player form
 */
@interface AddPlayerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameEditField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic) BOOL addMode;
@property (nonatomic, weak) Player *player;

- (IBAction)doneAction:(id)sender;

@end
