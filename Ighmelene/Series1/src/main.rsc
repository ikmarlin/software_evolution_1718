module main

import IO;
import List;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;
import Map;
import util::Math;
import Set;
import Relation;
import analysis::graphs::Graph;

public str t1 = "Hello, World!";
public M3 model;
public int volume					= 0;
public map[loc,M3] m3s 				= ();
public map[loc,Declaration] asts 	= ();
public map[loc,str] filestr			= ();
public map[loc,list[str]] filearr	= ();
public map[loc,int] unitsize			= ();
public map[loc,int] unitcc			= ();

void check(loc project)
{
	model = createM3FromEclipseProject(project);
	check(model);
}

void check(M3 m)
{
	volume = 0;
	m3s = ();
	asts = ();
	filearr = ();
	filearr = ();
	unitsize = ();
	unitcc = ();
	
	int volume				= getVolume(m);
	map[loc,int] unitSizes 	= getUnitSize(m);
	
	println();
	
	map[loc,int] unitCCs		= getCyclomaticComplexity(m);
	
	println("Volume: <volume>");
	allUnits = domain(unitsize) + domain(unitcc);
	for(f <- sort(allUnits))
	{
		if(isMethod(f))
		{
			s = (f notin unitsize)? -1 : unitsize[f];
			c = (f notin unitcc)? -1 : unitcc[f];
			println("<f>");
			println("  loc:  <s>");
			println("  cc:   <c>");
			println("");
		}
	}
}

public int getVolume(M3 m)
{
	if(volume == 0) volume = (0 | it + _getUnitSize(c) | c <- classes(m));
	return volume;
}

public map[loc,int] getUnitSize(M3 m)
{
	map [loc,int] unitCCs = ();
	for(<c,f> <- declaredMethods(m))
	{
		if(exists(f)) unitCCs[f] = _getUnitSize(f);
	}
	return unitCCs;
}

public map[loc,int] getCyclomaticComplexity(M3 m)
{
	map [loc,int] unitCCs = ();
	for(l <- files(m))
	{
		a 	= _getClassAst(l);
		for(f <- [d | /Declaration d := a, isMethod(d.decl)])
		{
			cc 	= 0;
			visit(f)
			{
				case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions): cc = -1;
				case \method(_,_,_,_, Statement impl): cc = _getUnitCC(f);
				case \constructor(_,_,_, Statement impl): cc = _getUnitCC(f);
			}
			if(cc > 0) unitCCs[f.decl] = cc;
		}
	}
	
	return unitCCs;
}

public str getCyclomaticComplexityRanking(M3 m)
{
	real v	= toReal(getVolume(m));
	s		= 0;
	c		= 0;
	u		= 0;
	ccs 		= getCyclomaticComplexity(m);
	
	for(f <- methods(m))
	{
		if(f in unitsize) 	println("size: <unitsize[f]>");
		if(f in unitcc)		println("cc:   <unitcc[f]>");
		println("");
		if(ccs[f] <= 20) s += _getUnitSize(f);
		else if(ccs[f] <= 50) c += _getUnitSize(f);
		else u += _getUnitSize(f);
	}
	ps = 100 * (s/v);
	pc = 100 * (c/v);
	pu = 100 * (u/v);
	println("Volume: <getVolume(m)>");
	println("Moderate:  <s> --\> <ps>%");
	println("High:      <c> --\> <pc>%");
	println("Very high: <u> --\> <pu>%");
	if(ps <= 25 && pc == 0 && pu == 0) return "++";
	if(ps <= 30 && pc <= 5 && pu == 0) return "+";
	if(ps <= 40 && pc <= 10 && pu == 0) return "o";
	if(ps <= 50 && pc <= 15 && pu <= 5) return "-";
	return "--";
}
//Get LOC in unit
public int _getUnitSize(loc f)
{
	if(!exists(f)) return 0;
	if(f notin unitsize)
	{
		m			= _getUnitM3(f);
		content		= size(_getFileLOContentAsArray(f));
		comments		= _getFileLOComments(m);
		unitsize[f] = content-comments;
	}
	
	return unitsize[f];
}

public int _getUnitCC(Declaration d)
{
	cc = 1;
	key = d.decl;
	if(key notin unitcc)
	{
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
		unitcc[key] = cc;
	}
	return unitcc[key];
}

private M3 _getUnitM3(loc f)
{
	if(f notin m3s)
	{
		s = _getFileLOContentAsString(f);
		m = createM3FromString(f,s);
		m3s[f] = m;
	}
	
	return m3s[f];
}

private Declaration _getClassAst(loc f)
{
	if(f notin asts)
	{
		asts[f] = createAstFromFile(f, true);
	}
	
	return asts[f];
}

//Get no. lines of comments in model
public int _getFileLOComments(M3 m)
{
	allLines		= [<t.begin,t.end> | /<loc _, loc t> := m, t.begin?];
	allComments	= [<c.begin,c.end> | /<loc _, loc c> := m.documentation, c.begin?];
	onlyComments	= [<bl,el> | <<bl,_>,<el,_>> <- allComments] - [<bl,el> | <<bl,_>,<el,_>> <- allLines-allComments];
	linesComms 	= [l | l <- [*[bl..el+1] | <bl,el> <- onlyComments]];
	return size(linesComms);
}

//Get list of file lines that aren't blank
private list[str] _getFileLOContentAsArray(loc f)
{
	if(f notin filearr)
	{
		//Lines that aren't blank
		filearr[f] = [l | l <- readFileLines(f), ! /^\s*$/ := l];
	}

	return filearr[f];
}

//Get file lines that aren't blank
private str _getFileLOContentAsString(loc f)
{
	if(f notin filestr)
	{
		ls = _getFileLOContentAsArray(f);
		filestr[f] = intercalate("\n",ls);
	}

	return filestr[f];
}

