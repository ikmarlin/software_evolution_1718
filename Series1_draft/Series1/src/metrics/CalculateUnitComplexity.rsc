module metrics::CalculateUnitComplexity

import IO;
import String;
import List;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::\syntax::Java15;
import Main;
import Extractor;
import metrics::SigModelScale;
import metrics::CalculateUnitSize;

/* calculate the percentages of the complexity risks levels for units
	CC 		Risk evaluation
	#################################
	1-10 	simple, without much risk
	11-20 	more complex, moderate risk
	21-50 	complex, high risk
	 > 50  untestable, very high risk
	 
	 rascal>cyclomaticComplexityUnit(smallModel);
	 ComplexityRisksPercentages: <38.0934313500,15.6082523100,24.9845862000,21.3137301400>
*/

alias ComplexityRisksPercentages = tuple[real simple, real moderate, real highk, real veryHigh];

public ComplexityRisksPercentages cyclomaticComplexityUnit(M3 model) {
// we need to categorize unit-size values between 4 different categories according to the definition of Cyclomatic complexity */
	list [int] unitSizeList = getUnitSize(model);
	int simple = sum([unitSize | unitSize <- unitSizeList, unitSize <= 10]);
	int moderate = sum([unitSize | unitSize <- unitSizeList, unitSize > 10 && unitSize <= 20]);
	int high = sum([unitSize | unitSize <- unitSizeList, unitSize > 20 && unitSize <= 50]);
	int veryHigh = sum([unitSize | unitSize <- unitSizeList, unitSize > 50]);
	// get total of all
	int totalUnitSize = simple + moderate + high + veryHigh;
	
	// get ratio per category of unit-size
	real ccSimple = toReal(simple)/toReal(totalUnitSize)*100;
	real ccModerate = toReal(moderate)/toReal(totalUnitSize)*100;
	real ccHigh = toReal(high)/toReal(totalUnitSize)*100;
	real ccVeryHigh = toReal(veryHigh)/toReal(totalUnitSize)*100;
	
	// return the calculated rations
	return <ccSimple, ccModerate, ccHigh, ccVeryHigh>;
}



/*
	     maximum relative LOC
	#    #####################
	rank# moderate high very-high
	 ++     25%     0%    0%
	 +      0%      5%    0%
	 o      40%     10%   0%
	 -      50%     15%   5%
	 --      -       -     -
*/