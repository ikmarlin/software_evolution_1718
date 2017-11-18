module main

import IO;
import Map;
import Set;
import List;
import String;
import util::Math;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

public map[str,int] ccAggregate	= ("low":0, "moderate":0, "high":0, "very high":0);
public map[str,int] volAggregate	= ("low":0, "moderate":0, "high":0, "very high":0);

void check(loc project)
{
	model = createM3FromEclipseProject(project);
	check(model);
}

void check(M3 m)
{
	int volume			= getVolume(m);
	map[loc,int] unitCCs	= getCyclomaticComplexity(m);
	
	println("Volume: <volume>");
	println("Complexity");
	for(c <- ccAggregate)
	{
		println("<left(c,10," ")> <percent(ccAggregate[c],volume)>%");
	}
	println("Unit size");
	for(c <- volAggregate)
	{
		println("<left(c,10," ")> <percent(volAggregate[c],volume)>%");
	}
}

public int getVolume(M3 m)
{
	return (0 | it + getUnitSize(l) | l <- files(m));
}

public int getUnitCC(Declaration d)
{
	cc = 1;
	visit (d)
	{
		case \case(_): cc += 1;
		case \catch(_,_): cc += 1;
		case \conditional(_,_,_): cc += 1;
		case \do(_,_): cc += 1;
		case \for(_,_,_): cc += 1;
		case \for(_,_,_,_): cc += 1;
		case \foreach(_,_,_): cc += 1;
		case \if(_,_): cc += 1;
		case \if(_,_,_): cc += 1;
		case \infix(_,"&&",_): cc += 1;
		case \infix(_,"||",_): cc += 1;
		case \infix(_,"^",_): cc += 1;
		case \while(_,_): cc += 1;
	}
	return cc;
}

public map[loc,int] getCyclomaticComplexity(M3 m)
{
	map [loc,int] unitCCs = ();
	for(l <- files(m))
	{
		unitCCs += getCyclomaticComplexity(l);
	}
	return unitCCs;
}

public map[loc,int] getCyclomaticComplexity(loc l)
{
	ast = createAstFromFile(l, true);
	return getCyclomaticComplexity(ast);
}

public map[loc,int] getCyclomaticComplexity(Declaration c)
{
	map [loc,int] unitCCs = ();
	for(f <- [d | /Declaration d := c, isMethod(d.decl)])
	{
		cc	= getUnitCC(f);
		vol	= getUnitSize(f.src);
		ccAggregate[getUnitCCClass(cc)]		+= vol;
		volAggregate[getUnitSizeClass(vol)]	+= vol;
	}
	return unitCCs;
}

public str getUnitCCClass(int cc)
{
	if(cc <= 6)	return "low";
	if(cc <= 8)	return "moderate";
	if(cc <= 14)	return "high";
	return "very high";
}

public int getUnitSize(loc f)
{
	ls	= readFileLines(f);
	ls -= getBlankLines(ls);
	ls -= getSLComments(ls);
	ls -= getMLComments(ls);
	return size(ls);
}

public map[loc,int] getUnitSizes(M3 m)
{
	map [loc,int] unitSizes = ();
	for(l <- files(m))
	{
		unitSizes += getUnitSizes(l);
	}
	return unitSizes;
}

public map[loc,int] getUnitSizes(loc l)
{
	ast = createAstFromFile(f, true);
	return getUnitSizes(ast);
}

public map[loc,int] getUnitSizes(Declaration c)
{
	map [loc,int] unitCCs = ();
	for(f <- [d | /Declaration d := c, isMethod(d.decl)])
	{
		vol	= getUnitSize(f.src);
		volAggregate[getUnitSizeClass(vol)]	+= vol;
	}
	return unitCCs;
}

public str getUnitSizeClass(int vol)
{
	if(vol <= 30) return "low";
	if(vol <= 44) return "moderate";
	if(vol <= 74) return "high";
	return "very high";
}

list[str] getBlankLines(list[str] lines)
{
	blankLines = [];
	for(l <- lines)
	{
		if(trim(l) == "") blankLines += l;
	}
	return blankLines;
}

list[str] getSLComments(list[str] lines)
{
	slcomments = [];
	for(l <- lines)
	{
		if(startsWith(trim(l),"//"))
		{
			slcomments += l;
		}
	}
	return slcomments;
}

list[str] getMLComments(list[str] lines)
{
	mlcomments = [];
	inComment = false;
	open = "/*";
	close = "*/";
	for(l <- lines)
	{
		tl = trim(l);
		if(contains(tl,"\"")) tl = cleanQuotedMLC(tl);
		
		if(contains(tl,open) && contains(tl,close))
		{
			if(isMixedLineMLC(tl)) mlcomments += l;
			inComment = (findLast(tl,open) > findLast(tl,close))? true; false;
		}
		else if(contains(tl,open))
		{
			if(startsWith(tl,open)) mlcomments += l;
			inComment = true;
		}
		else if(contains(tl,close))
		{
			if(endsWith(tl,close)) mlcomments += l;
			inComment = false;
		}
		else if(inComment)
		{
			mlcomments += l;
		}
	}
	return mlcomments;
}

str cleanQuotedMLC(str s)
{
	s = replaceAll(s, "\\\"", "");
	newString = "";
	while(/^<before:[^\"]*><oq:\"><enclosed:[^\"]*><cq:\"?><after:.*>$/ := s)
	{
		enclosed = replaceAll(enclosed,"/*","");
		enclosed = replaceAll(enclosed,"*/","");
		newString += before + oq + enclosed + cq;
		s = after;
	}
	return newString + s;
}

bool isMixedLineMLC(str s)
{
	open = "/*";
	close = "*/";
	comment = "";
	pairs = [];
	cs = findAll(s,close);
	os = findAll(s,open);
	for(c <- cs)
	{
		beforeC	= takeWhile(os,bool (int x){return c > x;});
		os 		= drop(size(beforeC),os);
		if(!isEmpty(beforeC))
		{
			comment += substring(s,top(beforeC),c+2);
		}
	}
	return (comment == s);
}
