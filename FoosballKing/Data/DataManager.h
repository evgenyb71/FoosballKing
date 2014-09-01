//
//  DataManager.h
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/30/14.
//
//

#import "Player.h"
#import "Game.h"

// inform delegate of data related events
@protocol DataManagerDelegateProtocol <NSObject>

@optional
- (void)dataManagerPlayerListUpdatedEvent;
- (void)dataManagerGameListUpdatedEvent;

@end

/*
 Singletone, handles all data access
 
 */
@interface DataManager : NSObject

+ (DataManager *)sharedInstance;

@property (nonatomic, weak) id<DataManagerDelegateProtocol> delegate;

- (Player *)createPlayerRecord:(NSString *)name;
- (BOOL)deletePlayerRecord:(Player *)player;
- (BOOL)updatePlayerRecord:(Player *)player1 newName:(NSString *)newName;

- (Game *)createGameRecordPlayer1:(Player *)player1 scoreForPlayer1:(NSInteger)score1 player2:(Player *)player2 scoreForPlayer2:(NSInteger)score2;
- (Game *)createGameRecordForDate:(NSDate *)date player1:(Player *)player1 scoreForPlayer1:(NSInteger)score1 player2:(Player *)player2 scoreForPlayer2:(NSInteger)score2;
- (BOOL)updateGameRecord:(Game *)game date:(NSDate *)date player1:(Player *)player1 scoreForPlayer1:(NSInteger)score1 player2:(Player *)player2 scoreForPlayer2:(NSInteger)score2;

@property (nonatomic, readonly) NSArray *ratedPlayers;
@property (nonatomic, readonly) NSArray *gamesByDate;

- (Player *)playerById:(NSString *)playerId;

@end
