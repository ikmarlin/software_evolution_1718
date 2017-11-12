module metrics::CalculateUnitSize

import IO;
import String;
import List;
import util::FileSystem;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::\syntax::Java15;
import metrics::CalculateLOC;


/* Get unit size (method size), by counting the number of lines in that method, exlucding comments & empty lines */
public map[loc, int] getUnitSize(M3 model) = (m: countLOCFile(m) | m <- methods(model));
