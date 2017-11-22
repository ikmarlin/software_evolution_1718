module metrics::CalculateUnitSize
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import String;
import List;
import util::Math;
import util::FileSystem;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Extractor;
import utils::Tools;
import metrics::SigModelScale;


/* We can calculate the unit size rating of a project
*	     maximum relative LOC
*	#    #####################
*	rank# moderate high very-high
*	 ++     25%     0%    0%
*	 +      30%      5%    0%
*	 o      40%     10%   0%
*	 -      50%     15%   5%
*	 --      -       -     -    default
*/

public map[loc,int]	unitSizes		= ();

/* get unit-loc & unit size (method size), by counting LOC in each unit, excluding comments & empty lines */
public map[loc,int] getUnitSizes(M3 model) {
	map [loc,int] sizes = ();
	for(l <- files(model))	{
		sizes += getUnitSizes(l);
	}
	return sizes;
}

public map[loc,int] getUnitSizes(loc l) {
	ast = getFileAst(l);
	return getUnitSizes(ast);
}

public map[loc,int] getUnitSizes(Declaration ast) {
	map [loc,int] sizes = ();
	for(meth <- [d | /Declaration d := ast, isMethod(d.decl)]) {
		sizes[meth.src] = getUnitSize(meth.src);
	}
	return sizes;
}

public int getUnitSize(loc f) {
	if(f notin unitSizes) {
		ls	= readFileLines(f);
		ls -= getBlankLines(ls);
		ls -= getMLComments(ls);
		ls -= getSLComments(ls);
		unitSizes[f] = size(ls);
	}
	return unitSizes[f];
}

map[str,int] aggrUnitSizes(map[loc,int] sizes) {
	aggr = ("low":0,"moderate":0,"high":0,"very high":0);
	for(unit <- sizes) 	{
		aggr[getUnitSizeClass(sizes[unit])] += sizes[unit];
	}
	return aggr;
}

/* get sig model rating - unit-size */
int getUnitSizeRating(map[str,int] aggr, int volume) {
	moderate	= percent(aggr["moderate"],volume); 
	high		= percent(aggr["high"],volume); 
	veryHigh	= percent(aggr["very high"],volume); 
	if(moderate <= 25 && high ==  0 && veryHigh == 0) return sigScales[0];
	if(moderate <= 30 && high <=  5 && veryHigh == 0) return sigScales[1];
	if(moderate <= 40 && high <= 10 && veryHigh == 0) return sigScales[2];
	if(moderate <= 50 && high <= 15 && veryHigh <= 5) return sigScales[3];
	return sigScales[4];
}

public str getUnitSizeClass(int vol) {
	if(vol <= 30) return "low";
	if(vol <= 44) return "moderate";
	if(vol <= 74) return "high";
	return "very high";
}

