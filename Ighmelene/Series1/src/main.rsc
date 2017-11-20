module main

import IO;
import Map;
import Set;
import List;
import String;
import util::Math;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import duplication;

public map[loc,int]	unitSizes	= ();
public map[loc,int]	unitCCs		= ();
public map[loc,M3] models		= ();
public map[loc,Declaration] asts	= ();

void check(loc project)
{
	if(project notin models)
	{
		models[project] = createM3FromEclipseProject(project);
	}
	check(models[project]);
}

void check(M3 m)
{
	int labelLength			= 20;
	int intLength			= 8;
	int percLength			= 7;
	int volume				= getVolume(m);
	int duplication			= getDuplication(m,6);
	map[loc,int] sizes		= getUnitSizes(m);
	map[loc,int] ccs			= getCyclomaticComplexity(m);
	map[str,int] aggrSizes	= aggrUnitSizes(sizes);
	map[str,int] aggrCCs		= aggrUnitCCs(ccs,sizes);
	list[str] sizeClasses 	= ["low","moderate","high","very high"];
	list[str] ccClasses 		= ["low","moderate","high","very high"];
	int volRating			= getVolumeRating(volume);
	int unitCCRating			= getCyclomaticComplexityRating(aggrCCs,volume);
	int dupRating			= getDuplicationRating(duplication);
	int unitSizeRating		= getUnitSizeRating(aggrSizes,volume);
	int analysability		= getAnalysabilityRating(volRating,dupRating,unitSizeRating);
	int changeability		= getChangeabilityRating(unitCCRating,dupRating);
	int testability			= getTestabilityRating(unitCCRating,unitSizeRating);
	
	print(left("Volume:",labelLength," "));
	println(right("<volume>",intLength," "));
	print(left("Rating:",labelLength," "));
	println(right("<volRating>",intLength," "));
	
	println(left("",labelLength+intLength,"-"));
	
	println(left("Unit size:",labelLength," "));
	for(classification <- sizeClasses)
	{
		print(left("<classification>:",labelLength," "));
		println("<right("<percent(aggrSizes[classification],volume)>",percLength," ")>%");
	}
	print(left("Rating:",labelLength," "));
	println(right("<unitSizeRating>",intLength," "));
	
	println(left("",labelLength+intLength,"-"));
	
	println(left("Complexity:",labelLength," "));
	for(classification <- ccClasses)
	{
		print(left("<classification>:",labelLength," "));
		println("<right("<percent(aggrCCs[classification],volume)>",percLength," ")>%");
	}
	print(left("Rating:",labelLength," "));
	println(right("<unitCCRating>",intLength," "));
	
	println(left("",labelLength+intLength,"-"));
	
	print(left("Duplication:",labelLength," "));
	println("<right("<duplication>",percLength," ")>%");
	print(left("Rating:",labelLength," "));
	println(right("<dupRating>",intLength," "));
	
	println(left("",labelLength+intLength,"-"));
	
	print(left("Analysability:",labelLength," "));
	println("<right("<analysability>",intLength," ")>");
	print(left("Changeability:",labelLength," "));
	println(right("<changeability>",intLength," "));
	print(left("Testability:",labelLength," "));
	println(right("<testability>",intLength," "));
	print(left("Maintainability:",labelLength," "));
	println("<right("<average([analysability,changeability,testability])>",intLength," ")>");
}

int getAnalysabilityRating(int volRating, int dupRating, int unitSizeRating)
{
	return average([volRating,dupRating,unitSizeRating]);
}

int getChangeabilityRating(int unitCCRating, int dupRating)
{
	return average([unitCCRating,dupRating]);
}

int getTestabilityRating(int unitCCRating, int unitSizeRating)
{
	return average([unitCCRating,unitSizeRating]);
}

int getVolumeRating(int vol)
{
	if(vol <=   66000) return 5;
	if(vol <=  246000) return 4;
	if(vol <=  665000) return 3;
	if(vol <= 1310000) return 2;
	return 1;
}

int getCyclomaticComplexityRating(map[str,int] aggr, int volume)
{
	moderate	= percent(aggr["moderate"],volume); 
	high		= percent(aggr["high"],volume); 
	veryHigh	= percent(aggr["very high"],volume); 
	if(moderate <= 25 && high ==  0 && veryHigh == 0) return 5;
	if(moderate <= 30 && high <=  5 && veryHigh == 0) return 4;
	if(moderate <= 40 && high <= 10 && veryHigh == 0) return 3;
	if(moderate <= 50 && high <= 15 && veryHigh <= 5) return 2;
	return 1;
}

int getDuplicationRating(int percentage)
{
	if(percentage <=  3) return 5;
	if(percentage <=  5) return 4;
	if(percentage <= 10) return 3;
	if(percentage <= 20) return 2;
	return 1;
}

int getUnitSizeRating(map[str,int] aggr, int volume)
{
	moderate	= percent(aggr["moderate"],volume); 
	high		= percent(aggr["high"],volume); 
	veryHigh	= percent(aggr["very high"],volume); 
	if(moderate <= 25 && high ==  0 && veryHigh == 0) return 5;
	if(moderate <= 30 && high <=  5 && veryHigh == 0) return 4;
	if(moderate <= 40 && high <= 10 && veryHigh == 0) return 3;
	if(moderate <= 50 && high <= 15 && veryHigh <= 5) return 2;
	return 1;
}

public int getVolume(M3 m)
{
	return (0 | it + getUnitSize(l) | l <- files(m));
}

public map[loc,int] getCyclomaticComplexity(M3 m)
{
	map[loc,int] ccs = ();
	for(l <- files(m))
	{
		ccs += getCyclomaticComplexity(l);
	}
	return ccs;
}

public map[loc,int] getCyclomaticComplexity(loc l)
{
	return getCyclomaticComplexity(getFileAst(l));
}

public map[loc,int] getCyclomaticComplexity(Declaration file)
{
	map[loc,int] ccs = ();
	for(meth <- [d | /Declaration d := file, isMethod(d.decl)])
	{
		ccs[meth.src] = getUnitCC(meth);
	}
	return ccs;
}

public int getUnitCC(Declaration d)
{
	if(d.src notin unitCCs)
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
		unitCCs[d.src] = cc;
	}
	return unitCCs[d.src];
}

public str getUnitCCClass(int cc)
{
	if(cc <= 6)	return "low";
	if(cc <= 8)	return "moderate";
	if(cc <= 14)	return "high";
	return "very high";
}

public map[loc,int] getUnitSizes(M3 m)
{
	map [loc,int] sizes = ();
	for(l <- files(m))
	{
		sizes += getUnitSizes(l);
	}
	return sizes;
}

public map[loc,int] getUnitSizes(loc l)
{
	ast = getFileAst(l);
	return getUnitSizes(ast);
}

public map[loc,int] getUnitSizes(Declaration ast)
{
	map [loc,int] sizes = ();
	for(meth <- [d | /Declaration d := ast, isMethod(d.decl)])
	{
		sizes[meth.src] = getUnitSize(meth.src);
	}
	return sizes;
}

public int getUnitSize(loc f)
{
	if(f notin unitSizes)
	{
		ls	= readFileLines(f);
		ls -= getBlankLines(ls);
		ls -= getMLComments(ls);
		ls -= getSLComments(ls);
		unitSizes[f] = size(ls);
	}
	return unitSizes[f];
}

public str getUnitSizeClass(int vol)
{
	if(vol <= 30) return "low";
	if(vol <= 44) return "moderate";
	if(vol <= 74) return "high";
	return "very high";
}

map[str,int] aggrUnitSizes(map[loc,int] sizes)
{
	aggr = ("low":0,"moderate":0,"high":0,"very high":0);
	for(unit <- sizes)
	{
		aggr[getUnitSizeClass(sizes[unit])] += sizes[unit];
	}
	return aggr;
}

map[str,int] aggrUnitCCs(map[loc,int] ccs, map[loc,int] sizes)
{
	aggr = ("low":0,"moderate":0,"high":0,"very high":0);
	for(unit <- ccs)
	{
		aggr[getUnitCCClass(ccs[unit])] += sizes[unit];
	}
	return aggr;
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

Declaration getFileAst(loc l)
{
	if(l notin asts)
	{
		asts[l] = createAstFromFile(l, true);
	}
	return asts[l];
}

int average(list[int] vals)
{
	int amount	= size(vals);
	real total	= toReal(sum(vals));
	return round(total/amount);
}