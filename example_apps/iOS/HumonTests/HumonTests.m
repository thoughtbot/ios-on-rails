//
//  HumonTests.m
//  HumonTests
//
//  Created by Diana Zmuda on 10/17/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import <Kiwi/Kiwi.h>

SPEC_BEGIN(InitialSpec)

describe(@"Kiwi tests", ^{
    
    it(@"can pass", ^{
        [[theValue(1+1) should] equal:theValue(2)];
    });
    
    it(@"can fail", ^{
        [[theValue(1+1) shouldNot] equal:theValue(2)];
    });
    
});

SPEC_END