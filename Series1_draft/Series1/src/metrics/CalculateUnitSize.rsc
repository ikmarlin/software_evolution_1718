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
import metrics::CalculateLOC;


/* get unit-loc & unit size (method size), by counting LOC in each unit, excluding comments & empty lines */
public map[loc,int] getUnitsSize(M3 model){
	map [loc,int] unitsSize = ();
	for(<_,f> <- declaredMethods(model)){
	//println("<f>");
		if(exists(f)) unitsSize[f] = getCountLOC(f); // _getUnitSize, global name to be used for classes, files 
	}
	return unitsSize;
}


//TODO we might not need this!
public real averageUnitsSize(M3 model) {
	map[loc,int] unitsSize = getUnitsSize(model);
	int l = 0;
	int sm = 0;
	for (<_,f> <- declaredMethods(model)) {
		if(exists(f)) {
			sm += unitsSize[f];
			l += 1;
		}
	}
	if (l!=0) return toReal(sm)/toReal(l); else return 0;
}
