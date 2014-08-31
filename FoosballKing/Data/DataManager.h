//
//  DataManager.h
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/30/14.
//
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "Game.h"

/*
 Singletone, handles all data access
 
 */
@interface DataManager : NSObject

+ (DataManager *)sharedInstance;

- (Player *)createPlayerRecord:(NSString *)name;
- (Game *)createGameRecordPlayer1:(Player *)player1 scoreForPlayer1:(NSInteger)score1 player2:(Player *)player2 scoreForPlayer2:(NSInteger)score2;
 
@end
