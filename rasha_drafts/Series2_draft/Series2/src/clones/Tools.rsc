module clones::Tools
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import String;
import List;
import Node;
import Prelude;
import util::Math;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import Main;
import clones::Type1;
import clones::Type2;

/* Begin of AST help functions */

int getSubtreeSize(node n) {
	count = 0;
	visit (n) {
		case node _: count += 1;
	}
	return count;
}


loc getSubtreeLocation(node n) {
	switch(n) {
            case Declaration d: return d.src;
            case Statement s: return s.src;
            case Expression e: return e.src;
            default : return |unknown:///|;
	}
}


bool isTextContained(str text1, str text2){
	bool contained = false;
	if(text1 == text2){
		return contained;
	}
	int count = 0;
	while((count + size(text2)) <= size(text1)){
		if(text2 == text1[count..(count + size(text2))]){
			contained = true;
		}
		count += 1;
	}
	return contained;
}

bool isSubsumed(lrel[loc,int,bool] c1, lrel[loc,int,bool] c2) {
	bool subsumed = true;
	//tuple[loc,int,bool] x;
	//tuple[loc,int,bool] y;
	// scan all and compare positions for excluding strictly included classes
	for(c22 <- c2){
		for(c11 <- c1){
			//println("subclass position: (<c22[0].begin.line>, <c22[0].end.line>)");
			//println("mainclass position: (<c11[0].begin.line>, <c11[0].end.line>)");
			//println("------------------------");
			if(!(c22[0].begin > c11[0].begin && c22[0].end < c11[0].end)) {
				subsumed = false;
			} else {
				continue; // do next comparison, until exiting loops with false, it means the class is strictly included given all pairs
			}
		}
	}
	return subsumed;
}

/* End of AST help functions */


/* Begin of Textual scan help functions */

list[str] getBlankLines(list[str] lines) {
	blankLines = [];
	for(l <- lines)	{
		if(trim(l) == "") blankLines += l;
	}
	return blankLines;
}

list[str] getSLComments(list[str] lines) {
	slcomments = [];
	for(l <- lines) {
		if(startsWith(trim(l),"//")) {
			slcomments += l;
		}
	}
	return slcomments;
}

list[str] getMLComments(list[str] lines) {
	mlcomments = [];
	inComment = false;
	open = "/*";
	close = "*/";
	for(l <- lines)	{
		tl = trim(l);
		if(contains(tl,"\"")) tl = cleanQuotedMLC(tl);
		
		if(contains(tl,open) && contains(tl,close)) {
			if(isMixedLineMLC(tl)) mlcomments += l;
			inComment = (findLast(tl,open) > findLast(tl,close))? true; false;
		}
		else if(contains(tl,open)) {
			if(startsWith(tl,open)) mlcomments += l;
			inComment = true;
		}
		else if(contains(tl,close))	{
			if(endsWith(tl,close)) mlcomments += l;
			inComment = false;
		}
		else if(inComment)	{
			mlcomments += l;
		}
	}
	return mlcomments;
}

str cleanQuotedMLC(str s) {
	s = replaceAll(s, "\\\"", "");
	newString = "";
	while(/^<before:[^\"]*><oq:\"><enclosed:[^\"]*><cq:\"?><after:.*>$/ := s) {
		enclosed = replaceAll(enclosed,"/*","");
		enclosed = replaceAll(enclosed,"*/","");
		newString += before + oq + enclosed + cq;
		s = after;
	}
	return newString + s;
}

bool isMixedLineMLC(str s) {
	open = "/*";
	close = "*/";
	comment = "";
	pairs = [];
	cs = findAll(s,close);
	os = findAll(s,open);
	for(c <- cs) {
		beforeC	= takeWhile(os,bool (int x){return c > x;});
		os 		= drop(size(beforeC),os);
		if(!isEmpty(beforeC)) {
			comment += substring(s,top(beforeC),c+2);
		}
	}
	return (comment == s);
}


list[str] removeAccolades(list[str] lines) {
	clean = [];
	for(l <- lines) 	{
		l = replaceAll(l,"{"," ");
		l = replaceAll(l,"}"," ");
		clean += trim(l);
	}
	return clean;
}

list[str] removeMultipleWhitespaces(list[str] lines) {
	clean = [];
	for(line <- lines) 	{
		cleanLine = "";
		while (/^<before:\S*><ws:\s+><after:.*$>/ := line) 		{ 
			cleanLine += before + " ";
			line = after;
		}
		cleanLine += line;
		clean += trim(cleanLine);
	}
	return clean;
}

list[str] getPackages(list[str] lines) {
	matches = [];
	for(line <- lines) {
		if(startsWith(trim(line),"package")) matches += line;
	}
	return matches;
}

list[str] getImports(list[str] lines) {
	matches = [];
	for(line <- lines) {
		if(startsWith(trim(line),"import")) matches += line;
	}
	return matches;
}

/* End of Textual scan help functions */

