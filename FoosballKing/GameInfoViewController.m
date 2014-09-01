//
//  GameInfoViewController.m
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/31/14.
//
//

#import "GameInfoViewController.h"

@interface GameInfoViewController () <UIPickerViewDelegate, UIPickerViewDataSource> {
    NSArray *_sortedPlayers;
    NSMutableDictionary *_nameIndexList;
    // to keep selection
    NSInteger _player1Index, _player2Index;
    NSString *_player2Id;
    NSInteger _player1ScoreValue;
    NSInteger _player2ScoreValue;
}

@end

@implementation GameInfoViewController

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
    _sortedPlayers = [[DataManager sharedInstance].ratedPlayers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((Player *)obj1).name compare:((Player *)obj2).name];
    }];
    _nameIndexList = [NSMutableDictionary dictionaryWithCapacity:_sortedPlayers.count];
    for (int index = 0; index < _sortedPlayers.count; index++) {
        [_nameIndexList setObject:@(index) forKey:((Player *)_sortedPlayers[index]).playerId];
    }
    
    self.player1Picker.dataSource = self;
    self.player1Picker.delegate = self;
    self.player2Picker.dataSource = self;
    self.player2Picker.delegate = self;

    self.player1Score.dataSource = self;
    self.player1Score.delegate = self;
    self.player2Score.dataSource = self;
    self.player2Score.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = _addMode ? @"Add Game" : @"Edit Game";
    if (_game) {
        self.datePicker.date = _game.date;
        _player1Index = [[_nameIndexList objectForKey:_game.player1Id] integerValue];
        _player2Index = [[_nameIndexList objectForKey:_game.player2Id] integerValue];
        _player1ScoreValue = [_game.player1Score integerValue];
        _player2ScoreValue = [_game.player2Score integerValue];
    } else {
        _player1Index = 0;
        _player2Index = 0;
        _player1ScoreValue = 0;
        _player2ScoreValue = 0;
    }
    [self.player1Picker selectRow:_player1Index inComponent:0 animated:NO];
    [self.player2Picker selectRow:_player2Index inComponent:0 animated:NO];
    [self.player1Score selectRow:_player1ScoreValue inComponent:0 animated:NO];
    [self.player2Score selectRow:_player2ScoreValue inComponent:0 animated:NO];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.player1Picker || pickerView == self.player2Picker) {
        return _sortedPlayers.count;
    }
    if (pickerView == self.player1Score || pickerView == self.player2Score) {
        return 11;
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.player1Picker || pickerView == self.player2Picker) {
        return ((Player *)_sortedPlayers[row]).name;
    }
    if (pickerView == self.player1Score || pickerView == self.player2Score) {
        return [@(row) stringValue];
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.player1Picker) {
        _player1Index = row;
    } else if (pickerView == self.player2Picker) {
        _player2Index = row;
    } else if (pickerView == self.player1Score) {
        _player1ScoreValue = row;
    } else if (pickerView == self.player2Score) {
        _player2ScoreValue = row;
    }
}

- (IBAction)doneAction:(id)sender {
    Player *player1 = (Player *)_sortedPlayers[_player1Index];
    Player *player2 = (Player *)_sortedPlayers[_player2Index];
    if (_addMode) {
        Game *game = [[DataManager sharedInstance] createGameRecordForDate:self.datePicker.date
                                                                   player1:player1
                                                           scoreForPlayer1:_player1ScoreValue
                                                                   player2:player2
                                                           scoreForPlayer2:_player2ScoreValue];
        if (game == nil) {
            [Utils showSimpleError:@"Cannot create new game"];
            return;
        }
    } else {
        if ([player1.playerId isEqualToString:_game.player1Id] == NO ||
            _player1ScoreValue != [_game.player1Score integerValue] ||
            [player2.playerId isEqualToString:_game.player2Id] == NO ||
            _player2ScoreValue != [_game.player2Score integerValue])
        {
            BOOL success = [[DataManager sharedInstance] updateGameRecord:_game
                                                                     date:self.datePicker.date
                                                                  player1:player1
                                                          scoreForPlayer1:_player1ScoreValue
                                                                  player2:player2
                                                          scoreForPlayer2:_player2ScoreValue];
            if (success == NO) {
                [Utils showSimpleError:@"Cannot update game"];
                return;
            }
        }
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
