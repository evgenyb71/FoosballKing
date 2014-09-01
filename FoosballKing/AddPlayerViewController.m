//
//  AddPlayerViewController.m
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/31/14.
//
//

#import "AddPlayerViewController.h"

@interface AddPlayerViewController () <UITextFieldDelegate>

@end

@implementation AddPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = _addMode ? @"Add Player" : @"Edit Player";
    if (_player) {
        self.nameEditField.text = _player.name;
    }
    self.doneButton.enabled = [self.nameEditField.text length] > 0;
}

#pragma mark - UITextFieldDelegate

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.doneButton.enabled = [string length] > 0;
	return YES;
}

- (IBAction)doneAction:(id)sender {
    if (self.doneButton.enabled == NO)
        return;
    if (_addMode) {
        Player *player = [[DataManager sharedInstance] createPlayerRecord:self.nameEditField.text];
        if (player == nil) {
            [Utils showSimpleError:@"Player with the same name already exists"];
            return;
        }
    } else {
        if ([_player.name isEqualToString:self.nameEditField.text] == NO) {
            BOOL success = [[DataManager sharedInstance] updatePlayerRecord:_player newName:self.nameEditField.text];
            if (success == NO) {
                [Utils showSimpleError:@"Cannot change the name"];
                return;
            }
        }
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
