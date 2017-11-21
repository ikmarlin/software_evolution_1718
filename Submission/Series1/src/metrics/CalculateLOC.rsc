module metrics::CalculateLOC
/**
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
import lang::java::m3::AST;
import lang::java::\syntax::Java15;

import Main;
import Extractor;
import utils::Tools;


/* get LOC count per item, item can be file, class, unit */
public int countLOC(loc f) = size(getLOC(f));
public list[str] getLOC(loc f) {
	str content = eraseOneLineComment(readFile(f)); // get rid of comments
	content = eraseBlockComment(content); // get rid of comments
	//println ("file after comments omitted: <content>");
	content = eraseEmptyLines(content); // get rid of empty lines
	//println ("file after empty lines omitted: <content>");
	list[str] locf  = [s | s <- split(newLine, content), !(/^\s*$/ := s)];
	return locf;
}

/* get LOC count per item without curly braces */
public int countLOCNoCurlyBraces(loc f) = size(getLOCNoCurlyBraces(f));
public list[str] getLOCNoCurlyBraces(loc f) {
	str content = eraseOneLineComment(readFile(f)); // get rid of comments
	content = eraseBlockComment(content); // get rid of comments
	//println ("file after comments omitted: <content>");
	content = eraseEmptyLines(content); // get rid of empty lines
	//println ("file after empty lines omitted: <content>");
	content = eraseCurlyBraces(content); // get rid of curly braces
	//println ("file after {} omitted: <content>");
	list[str] locf  = [s | s <- split(newLine, content), !(/^\s*$/ := s)];
	return locf;
}

public list[str] extractAllLines(M3 model) = [trim(l) | m <- extractMethods(model), l <-  getLOCNoCurlyBraces(m)];

