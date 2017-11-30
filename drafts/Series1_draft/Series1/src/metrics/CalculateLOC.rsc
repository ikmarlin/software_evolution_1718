module metrics::CalculateLOC
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


/* Ighmelene - get item LOC, that can be file, class, unit .. */
public int getCountLOC(loc f){
	if(!exists(f)) return 0;
	if(f notin unitsize){
		m			= _getUnitM3(f);
		content		= size(_getFileLOContentAsArray(f));
		comments	= _getFileLOComments(m);
		unitsize[f] = content-comments;
		//println("<comments>");
	}
	return unitsize[f];
}

/* get count lines of comments in model */
public int _getFileLOComments(M3 m){
	allLines		= [<t.begin,t.end> | /<loc _, loc t> := m, t.begin?];
	allComments	    = [<c.begin,c.end> | /<loc _, loc c> := m.documentation, c.begin?];
	onlyComments	= [<bl,el> | <<bl,_>,<el,_>> <- allComments] - [<bl,el> | <<bl,_>,<el,_>> <- allLines-allComments];
	linesComms 	    = [l | l <- [*[bl..el+1] | <bl,el> <- onlyComments]];
	//println("<size(linesComms)>");
	return size(linesComms);
}

/* get file lines that aren't blank */
private str _getFileLOContentAsString(loc f){
	if(f notin filestr){
		ls = _getFileLOContentAsArray(f);
		filestr[f] = intercalate("\n",ls);
	}
	return filestr[f];
}


private M3 _getUnitM3(loc f){
	if(f notin m3s){
		s = _getFileLOContentAsString(f);
		m = createM3FromString(f,s);
		m3s[f] = m;
	}
	return m3s[f];
}


/* get list o LOC that are't blank */
private list[str] _getFileLOContentAsArray(loc f){
	if(f notin filearr){
		filearr[f] = [l | l <- readFileLines(f), ! /^\s*$/ := l]; //Lines that aren't blank
	}
	return filearr[f];
}
