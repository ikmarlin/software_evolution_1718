module metrics::CalculateVolume

import IO;
import String;
import List;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::\syntax::Java15;
import Main;
import Extractor;
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


/* calculate volume/classes - Halstead volume*/
public int getVolumeAllClasses(M3 model) {
	list[loc] cls = extractClasses(model);
	return toInt(sum(mapper(cls, countLOCFile)));
}

/* calculate volume/files */
public int getVolumeAllFiles(loc project, list[str] paths, str fileExt) {
	list[loc] files = extractFiles(project, paths, fileExt);
	return toInt(sum(mapper(files, countLOCFile)));
}

/*
	rascal>getVolumeAllClasses(smallModel);
	int: 23673
	
	rascal>getVolumeAllFiles(smallsql, ["junit"], "java");
	int: 24048
	
	rascal>getVolumeRanking(getVolumeAllClasses(smallModel));
	str: "++"

	rascal>getVolumeRanking(getVolumeAllClasses(hsModel));
	str: "+"
*/
