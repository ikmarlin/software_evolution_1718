module metrics::CalculateUnitSize

import IO;
import String;
import List;
import util::FileSystem;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::\syntax::Java15;
import metrics::CalculateLOC;


/* Get unit size (method size), by counting the number of lines in that method, exlucding comments & empty lines */
public map[loc, int] getUnitLocAndUnitSize(M3 model) = (m: countLOCFile(m) | m <- methods(model));
public list[int] getUnitSize(M3 model) = [countLOCFile(m) | m <- methods(model)];

public real averageUnitSize(M3 model) {
	map[loc, int] result = getUnitSize(model);
	int l = 0;
	int sm = 0;
	for(v<- result) {
		sm += v;
		l += 1;
	}
	if (l!=0) return sm/l; else return 0;
}
