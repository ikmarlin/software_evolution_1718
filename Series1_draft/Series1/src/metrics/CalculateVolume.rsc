module metrics::CalculateVolume

import IO;
import String;
import List;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::\syntax::Java15;
import Main;
import metrics::SigModelScale;
import metrics::CalculateLOC;


/* Based on java KLOC ranking for Volume of a project, get the sig scale string
	
		Rank (Java KLOC)
		##############
		 ++   0-66
		##############
		 +   66-246
		##############
		 o   246-665
		##############
		 - 	 655-1,310
		##############
		 --	 > 310
		##############
*/
public str getVolumeRanking(int numLines) {
	if(numLines <= 66000) return sigScales[0];
	else if(numLines <= 246000) return sigScales[1];
	else if(numLines <= 665000) return sigScales[2]; 
	else if(numLines <= 1310000) return sigScales[3];
	else return sigScales[4];
}


/* calculate volume */
public int getVolume(M3 model) {
	list[loc] cls = extractClasses(model);
	return toInt(sum(mapper(cls, countLOCFile)));
}


/*
1)
	rascal>getVolumeRanking(getVolume(smallModel));
	str: "++"

2)
	rascal>getVolumeRanking(getVolume(hsModel));
	str: "+"
*/
