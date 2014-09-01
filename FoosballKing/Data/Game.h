//
//  Game.h
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/30/14.
//
//

#import <CoreData/CoreData.h>

@interface Game : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * gameId;
@property (nonatomic, retain) NSString * player1Id;
@property (nonatomic, retain) NSNumber * player1Score;
@property (nonatomic, retain) NSString * player2Id;
@property (nonatomic, retain) NSNumber * player2Score;

@end
