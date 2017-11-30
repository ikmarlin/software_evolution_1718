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
import util::Math;

public int getSubtreeSize(node n) {
	count = 0;
	visit (n) {
		case node n: count += 1;
	}
	return count;
}

loc getSubtreeLocation(node n) {
	switch(n) {
            case Declaration d: return d@src;
            case Statement s: return s@src;
            case Expression e: return e@src;
            default : return |project:///|;
	}
}

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

/* get average of a list of integers, round result to int */
int average(list[int] vals) {
	int amount	= size(vals);
	real total	= toReal(sum(vals));
	return round(total/amount);
}