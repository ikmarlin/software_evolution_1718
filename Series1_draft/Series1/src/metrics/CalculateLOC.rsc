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
import Extractor;
import utils::Tools;

/* LOC count per file */
public int countLOCFile(loc f) = size(getLOCFile(f));
public list[str] getLOCFile(loc f) {
	str content = eraseOneLineComment(readFile(f)); // get rid of comments
	content = eraseBlockComment(content); // get rid of comments
	//println ("file after comments omitted: <content>");
	content = eraseEmptyLines(content); // get rid of empty lines
	//println ("file after empty lines omitted: <content>");
	list[str] locf  = [s | s <- split(newLine, content), !(/^\s*$/ := s)];
	return locf;
}

//content = eraseCurlyBraces(content);

/* LOC count per unit (method) */
public int countLOCUnit(loc f) = size(getLOCUnit(f));
public list[int] getLOCUnit(M3 model) = mapper(methods(Model), getLOCFile);

public list[str] extractAllLines(M3 model) = [trim(l) | m <- extractMethods(model), l <-  getLOCFile(m)];