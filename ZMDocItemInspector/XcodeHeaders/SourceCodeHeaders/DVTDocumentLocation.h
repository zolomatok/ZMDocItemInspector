/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import <AppKit/AppKit.h>

//#import "DVTSimpleSerialization-Protocol.h"
//#import "NSCoding-Protocol.h"
//#import "NSCopying-Protocol.h"

@class NSNumber, NSString, NSURL;

@interface DVTDocumentLocation : NSObject// <NSCoding, NSCopying, DVTSimpleSerialization>
{
    NSURL *_documentURL;
    NSNumber *_timestamp;
}

@property(readonly) NSNumber *timestamp; // @synthesize timestamp=_timestamp;
@property(readonly) NSURL *documentURL; // @synthesize documentURL=_documentURL;
//- (void).cxx_destruct;
- (long long)compare:(id)arg1;
- (id)description;
- (void)dvt_writeToSerializer:(id)arg1;
- (id)dvt_initFromDeserializer:(id)arg1;
- (BOOL)isEqualDisregardingTimestamp:(id)arg1;
- (BOOL)isEqualToDocumentLocationDisregardingDocumentURL:(id)arg1;
- (unsigned long long)hash;
- (BOOL)isEqual:(id)arg1;
- (id)copyWithURL:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
@property(readonly) NSString *documentURLString;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)initWithDocumentURL:(id)arg1 timestamp:(id)arg2;
- (id)init;

@end

