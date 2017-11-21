module metrics::CalculateUnitSize
/**
 *
 * This module is
 * 
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import String;
import List;
import util::Math;
import util::FileSystem;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::\syntax::Java15;
import Main;
import metrics::CalculateLOC;


/* get unit-loc & unit size (method size), by counting LOC in each unit, excluding comments & empty lines */
public map[loc,int] getUnitsSize(M3 model){
	map[loc,int] unitsize = ();
	for(<_,f> <- declaredMethods(model)){
		if(exists(f)) unitsize[f] = countLOC(f); // RD method
	}
	//println("<unitsize>");
	return unitsize;
}


//TODO we might not need this!
public real averageUnitsSize(M3 model) {
	map[loc,int] unitsize = getUnitsSize(model);
	int l = 0;
	int sm = 0;
	for (<_,f> <- declaredMethods(model)) {
		if(exists(f)) {
			sm += unitsize[f];
			l += 1;
		}
	}
	if (l!=0) return toReal(sm)/toReal(l); else return 0;
}
