/*******************************************************************************
 * Copyright (c) 2009 Kåre Morstøl (NotTooBad Software).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   Kåre Morstøl (NotTooBad Software) - initial API and implementation
 *	  Michael Kaye (http://www.sendmetospace.co.uk) - modified addLabel/didMoveWindow. New methods - updateLabel, refreshLabel, rotateLabels and removeLabel
 *******************************************************************************/ 

// http://stackoverflow.com/questions/367471/fixed-labels-in-the-selection-bar-of-a-uipickerview/616517

#import "LabeledPickerView.h"

@implementation LabeledPickerView

/** loading programmatically */
- (id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame:aRect]) {
		labels = [[NSMutableDictionary alloc] initWithCapacity:3];
	}
	return self;
}

/** loading from nib */
- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		labels = [[NSMutableDictionary alloc] initWithCapacity:3];
	}
	return self;
}

#pragma mark Labels

// Add labelText to our array but also add what will be the longest label we will use in updateLabel
// If you do not plan to update label then the longestString should be the same as the labelText
// This way we can initially size our label to the longest width and we get the same effect Apple uses

- (void) addLabel:(NSString *)labeltext forComponent:(NSUInteger)component forLongestString:(NSString *)longestString {
	[labels setObject:labeltext forKey:[NSNumber numberWithInteger:component]];
	
	NSString *keyName = [NSString stringWithFormat:@"longestString_%@", [NSNumber numberWithInteger:component]];
	
	if(!longestString) {
		longestString = labeltext;
	}
	
	[labels setObject:longestString forKey:keyName];
}

// 
- (void) updateLabel:(NSString *)labeltext forComponent:(NSUInteger)component {
	
	UILabel *theLabel = (UILabel*)[self viewWithTag:component + 1];
	
	// Update label if it doesn’t match current label
	if (![theLabel.text isEqualToString:labeltext]) {
		
		NSString *keyName = [NSString stringWithFormat:@"longestString_%@", [NSNumber numberWithInteger:component]];
		NSString *longestString = [labels objectForKey:keyName];
		
		// Update label array with our new string value
		[self addLabel:labeltext forComponent:component forLongestString:longestString];		

		// change label during fade out/in
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.1];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		theLabel.alpha = 0.00;
		theLabel.text = labeltext;
		theLabel.alpha = 1.00;
		[UIView commitAnimations];
	}
}

/** 
 Adds the labels to the view, below the selection indicator glass-thingy.
 The labels are aligned to the right side of the wheel.
 The delegate is responsible for providing enough width for both the value and the label.
 */
- (void)didMoveToWindow {
	// exit if view is removed from the window or there are no labels.
    if (!self.window || [labels count] == 0) {
        return;
    }
	
	// find the width of all the wheels combined 
	CGFloat widthofwheels = 0;
	for (int i=0; i<self.numberOfComponents; i++) {
		widthofwheels += [self rowSizeForComponent:i].width;
	}
	
	// find the left side of the first wheel.
	// seems like a misnomer, but that will soon be corrected.
	CGFloat rightsideofwheel = (self.frame.size.width - widthofwheels) / 2;
	
	// cycle through all wheels
	for (int component=0; component<self.numberOfComponents; component++) {
		// find the right side of the wheel
		rightsideofwheel += [self rowSizeForComponent:component].width;
		
		// get the text for the label. 
		// move on to the next if there is no label for this wheel.
		NSString *text = [labels objectForKey:[NSNumber numberWithInt:component]];
		if (text) {
			
			// set up the frame for the label using our longestString length
			NSString *keyName = [NSString stringWithFormat:@"longestString_%@", [NSNumber numberWithInt:component]];
			NSString *longestString = [labels objectForKey:keyName];
            
			CGRect frame;
            UIFont *labelfont = [UIFont boldSystemFontOfSize:20];
            NSDictionary *attributes = @{NSFontAttributeName: labelfont};
            frame.size = [longestString sizeWithAttributes:attributes];

			// center it vertically 
			frame.origin.y = (self.frame.size.height / 2) - (frame.size.height / 2) - 0.5;
			
			// align it to the right side of the wheel, with a margin.
			// use a smaller margin for the rightmost wheel.
			frame.origin.x = rightsideofwheel - frame.size.width - (component == self.numberOfComponents - 1 ? 5 : 7);
			
			// set up the label. If label already exists, just get a reference to it
			BOOL addlabelView = NO;
			UILabel *label = (UILabel*)[self viewWithTag:component + 1];
			if(!label) {
				label = [[UILabel alloc] initWithFrame:frame];
				addlabelView = YES;
			}
			
			label.text = text;
			label.font = labelfont;
			label.backgroundColor = [UIColor clearColor];
			label.shadowColor = [UIColor whiteColor];
			label.shadowOffset = CGSizeMake(0,1);
			
			// Tag cannot be 0 so just increment component number to esnure we get a positive
			// NB update/remove Label methods are aware of this incrementation!
			label.tag = component + 1;
			
			if(addlabelView) {
				[self insertSubview:label atIndex:[self.subviews count]-3];
			}
			
            if ([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
                [self.delegate pickerView:self didSelectRow:[self selectedRowInComponent:component] inComponent:component];
            }
		}
    }
}

@end
