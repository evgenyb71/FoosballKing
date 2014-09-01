//
//  GameInfoViewController.h
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/31/14.
//
//

#import <UIKit/UIKit.h>

/*
 Simple Add / Edit Game form
 */
@interface GameInfoViewController : UIViewController

@property (nonatomic) BOOL addMode;
@property (nonatomic, weak) Game *game;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *player1Picker;
@property (weak, nonatomic) IBOutlet UIPickerView *player2Picker;
@property (weak, nonatomic) IBOutlet UIPickerView *player1Score;
@property (weak, nonatomic) IBOutlet UIPickerView *player2Score;

- (IBAction)doneAction:(id)sender;
@end
