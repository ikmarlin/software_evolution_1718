module metrics::CalculateLOC

import IO;
import String;
import List;
import util::Math;
import util::FileSystem;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::\syntax::Java15;
import utils::Tools;

/* LOC count per file */
public int countLOCFile(loc f) = size(getLOCFile(f));

public list[str] getLOCFile(loc f) {
	str content = eraseComments(readFile(f)); // get rid of comments
	content = eraseEmptyLines(content); // get rid of empty lines
	list[str] locf  = [s | s <- split(newLine, content), !(/^\s*$/ := s)];
	return locf;
}

/* LOC count per unit (method) */
public int countLOCUnit(loc f) = size(getLOCUnit(f));
public list[int] getLOCUnit(M3 model) = mapper(methods(Model), getLOCFile);