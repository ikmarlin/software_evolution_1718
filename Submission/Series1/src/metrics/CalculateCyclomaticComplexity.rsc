module metrics::CalculateCyclomaticComplexity
/**
 * 
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import util::Math;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Main;
import Extractor;
import metrics::SigModelScale;
import metrics::CalculateLOC;
import metrics::CalculateVolume;

/* get cyclomatic-complexity for complete project */
public map[loc,int] getCyclomaticComplexity(M3 m) {
	map[loc,int] ccs = ();
	for(l <- files(m)){
		ccs += getCyclomaticComplexity(l);
	}
	return ccs;
}

/* get cyclomatic-complexity per loc */
public map[loc,int] getCyclomaticComplexity(loc l) {
	return getCyclomaticComplexity(getFileAst(l));
}

/* get cyclomatic-complexity per unit */
public map[loc,int] getCyclomaticComplexity(Declaration file) {
	map[loc,int] ccs = ();
	for(meth <- [d | /Declaration d := file, isMethod(d.decl)]) {
		ccs[meth.src] = getUnitCC(meth);
	}
	return ccs;
}

/* get count of different statement types for cyclomatic-complexity calculation */
public int getUnitCC(Declaration d) {
	if(d.src notin unitCCs){
		cc = 1;
		visit (d) {
			case \case(_): cc += 1;
			case \catch(_,_): cc += 1;
			case \conditional(_,_,_): cc += 1;
			case \do(_,_): cc += 1;
			case \for(_,_,_): cc += 1;
			case \for(_,_,_,_): cc += 1;
			case \foreach(_,_,_): cc += 1;
			case \if(_,_): cc += 1;
			case \if(_,_,_): cc += 1;
			case \infix(_,"&&",_): cc += 1;
			case \infix(_,"||",_): cc += 1;
			case \infix(_,"^",_): cc += 1;
			case \while(_,_): cc += 1;
		}
		unitCCs[d.src] = cc;
	}
	return unitCCs[d.src];
}

/* get unit-cyclomatic-complexity ranking */
public str getUnitCCClass(int cc) {
	if(cc <= 6)		return "low";
	if(cc <= 8)		return "moderate";
	if(cc <= 14)	return "high";
	return "very high";
}

/* get unit-cyclomatic-complexity ranking following Sig-Model */
public int getCyclomaticComplexityRating(map[str,int] aggr, int volume) {
	moderate	= percent(aggr["moderate"],volume); 
	high		= percent(aggr["high"],volume); 
	veryHigh	= percent(aggr["very high"],volume); 
	if(moderate <= 25 && high ==  0 && veryHigh == 0) sigScales[0];
	if(moderate <= 30 && high <=  5 && veryHigh == 0) sigScales[1];
	if(moderate <= 40 && high <= 10 && veryHigh == 0) sigScales[2];
	if(moderate <= 50 && high <= 15 && veryHigh <= 5) sigScales[3];
	return sigScales[4];
}


map[str,int] aggrUnitCCs(map[loc,int] ccs, map[loc,int] sizes) {
	aggr = ("low":0,"moderate":0,"high":0,"very high":0);
	for(unit <- ccs){
		aggr[getUnitCCClass(ccs[unit])] += sizes[unit];
	}
	return aggr;
}
