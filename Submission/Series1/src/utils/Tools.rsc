module utils::Tools
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import String;
import util::Math;

public str newLine = "\n";
public str tab = "\t";

public int countLines(str s){
  count = 1; 
  for(i <- [0 .. size(s)], s[i]==newLine) count+=1;
  return count;
}

public str eraseOneLineComment(str content) {
	return visit(content) {
		case /^[\n\t ]*\/\/.*/ => ""
	}
}

public str eraseBlockComment(str content) {
	return visit(content) {
		case /\/\*.*?\*\//s => ""
		case /\/\*[\s\S]*?\*\// => ""
	}
}

public str eraseEmptyLines(str content) {
    return visit(content) {
        case /^[ \t]*\r?\n/ => "\n"
    }
}

public str eraseCurlyBraces(str content) {;
    return visit(content) {
        case /[\{\}]/ => " "
    }
}

// ighmelene
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