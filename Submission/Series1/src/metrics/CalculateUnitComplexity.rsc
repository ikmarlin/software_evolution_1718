module metrics::CalculateUnitComplexity
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import String;
import List;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import Main;
import Extractor;
import metrics::SigModelScale;
import metrics::CalculateUnitSize;

/* calculate the percentages of the complexity risks levels for units
*	CC 		Risk evaluation
*	#################################
*	1-10 	simple, without much risk
*	11-20 	more complex, moderate risk
*	21-50 	complex, high risk
*	 > 50  untestable, very high risk
*	 
*	 rascal>getComplexityRisksPercentages(smallModel);
	ComplexityRisksPercentages: <38.0633518500,15.5767678200,25.0178088000,21.3420715200>
*/

alias ComplexityRisksPercentages = tuple[real low, real moderate, real high, real veryHigh];

public ComplexityRisksPercentages getComplexityRisksPercentages(map[loc,int] unitsize) {
// we need to categorize unit-size values between 4 different categories according to the definition of Cyclomatic complexity */
	list[int] unitsSizeList = [unitsize[l] | l <- unitsize];
	int low = sum([unitSize | unitSize <- unitsSizeList, unitSize <= 10]);
	int moderate = sum([unitSize | unitSize <- unitsSizeList, unitSize > 10 && unitSize <= 20]);
	int high = sum([unitSize | unitSize <- unitsSizeList, unitSize > 20 && unitSize <= 50]);
	int veryHigh = sum([unitSize | unitSize <- unitsSizeList, unitSize > 50]);
	
	// get total of all
	int totalUnitSize = low + moderate + high + veryHigh;
	
	// get ratio per category of unit-size
	real prctLow= toReal(low)/toReal(totalUnitSize)*100;
	real prctModerate = toReal(moderate)/toReal(totalUnitSize)*100;
	real prctHigh = toReal(high)/toReal(totalUnitSize)*100;
	real prctVeryHigh = toReal(veryHigh)/toReal(totalUnitSize)*100;
	
	// return the calculated ration's
	return <prctLow, prctModerate, prctHigh, prctVeryHigh>;
}



/* now, we can calculate the unit complexity rating of a project
	     maximum relative LOC
	#    #####################
	rank# moderate high very-high
	 ++     25%     0%    0%
	 +      0%      5%    0%
	 o      40%     10%   0%
	 -      50%     15%   5%
	 --      -       -     -
	 
	 rascal>getUnitComplexityRanking(getComplexityRisksPercentages(smallModel));
	str: "--"
	
	rascal>getUnitComplexityRanking(getComplexityRisksPercentages(hsModel));
	str: "--"
*/

// sigScales = ["++", "+", "o", "-", "--"]; 
public str getUnitComplexityRanking(ComplexityRisksPercentages crPercentages) {
	real low = crPercentages.low;
	real moderate = crPercentages.moderate;
	real high = crPercentages.high;
	real veryHigh = crPercentages.veryHigh;
	
	if(low <=25 && high == 0 && veryHigh == 0) return sigScales[0]; // ++
	else if(low <=30 && high <=5 && veryHigh == 0) return sigScales[1]; // +
	else if(low <=40 && high <=10 && veryHigh == 0) return sigScales[2]; // o
	else if(low <=50 && high <=15 && veryHigh <=5) return sigScales[3]; // -
	else return sigScales[4]; // --
}
