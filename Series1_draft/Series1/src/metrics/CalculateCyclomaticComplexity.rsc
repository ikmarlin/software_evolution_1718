module metrics::CalculateCyclomaticComplexity
/**
 *
 * This module is
 * 
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;
import lang::java::\syntax::Java15;
import Extractor;
import metrics::SigModelScale;
import metrics::CalculateLOC;

/* get count of different statement types for cyclomatic-complexity calculation */
public int _getUnitCC(Declaration d){
	cc = 1;
	key = d.decl;
	if(key notin unitcc){
		visit (d){
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
		unitcc[key] = cc;
	}
	return unitcc[key];
}

/* get cyclomatic-complexity per unit */
public map[loc,int] getCyclomaticComplexity(M3 model){
	map [loc,int] unitCCs = ();
	for(l <- files(model)){
		a 	= _getClassAst(l);
		for(f <- [d | /Declaration d := a, isMethod(d.decl)]){
			cc 	= 0;
			visit(f){
				case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions): cc = -1;
				case \method(_,_,_,_, Statement impl): cc = _getUnitCC(f);
				case \constructor(_,_,_, Statement impl): cc = _getUnitCC(f);
			}
			if(cc > 0) unitCCs[f.decl] = cc;
		}
	}
	return unitCCs;
}

/* get unit-cyclomatic-complexity ranking following Sig-Model */
public str getCyclomaticComplexityRanking(M3 model){
	real v	= toReal(getVolume(model));
	s		= 0;
	c		= 0;
	u		= 0;
	ccs 	= getCyclomaticComplexity(model);
	
	for(f <- extractMethods(model)){
		if(f in unitsize) 	println("size: <unitsize[f]>");
		if(f in unitcc)		println("cc:   <unitcc[f]>");
		println("");
		if(ccs[f] <= 20) s += getCountLOC(f);// _getUnitSize
		else if(ccs[f] <= 50) c += getCountLOC(f);// _getUnitSize
		else u += getCountLOC(f); // _getUnitSize
	}
	ps = 100 * (s/v);
	pc = 100 * (c/v);
	pu = 100 * (u/v);
	println("Volume: <getVolumeAllFiles(model)>"); //TODO - or getVolumeAllClasses?
	println("Moderate:  <s> --\> <ps>%");
	println("High:      <c> --\> <pc>%");
	println("Very high: <u> --\> <pu>%");
	if(ps <= 25 && pc == 0 && pu == 0) return sigScales[0];
	if(ps <= 30 && pc <= 5 && pu == 0) return sigScales[1];
	if(ps <= 40 && pc <= 10 && pu == 0) return sigScales[2];
	if(ps <= 50 && pc <= 15 && pu <= 5) return sigScales[3];
	return sigScales[4];
}