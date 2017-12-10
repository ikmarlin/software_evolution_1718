module Main
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import String;
import Map;
import List;
import Relation;
import Node;
import DateTime;
import ParseTree;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import clones::Type1;
import clones::Type2;
import clones::Tools;
import tests::TestType1;


alias tree = set[Declaration];
alias pairs = rel[clone,clone];
public pairs clonePairs = {};
public int blockSize = 3;


public map[str, lrel[loc, int, bool]] storage = ();
public map[str, lrel[loc, int, bool]] cloneClasses = ();
public int minLoc = 6;

str getTimedFilename(str basename) = basename + getTimeForFile();
str getTimeForFile() = printDateTime(now(), "YYYYMMddHHmmssSSS");

/* java projects of interest */
public loc smallsql = |project://smallsql0.21_src/|;
public loc hsqldb   = |project://hsqldb-2.3.1/|;



void main(loc project) {
	//type1
	run1(project);
	str type1 = getTimedFilename("Output_type1_");
	writeFile((|project://Series2/output/|)+ type1,"Output from analyzing clone classes of type1:\n");
	for (c <- storage ){
		appendToFile((|project://Series2/output/|)+ type1,  c+"\n");
		appendToFile((|project://Series2/output/|)+ type1, storage[c]);
		appendToFile((|project://Series2/output/|)+ type1,"\n\n\n");
	}
	
	// testing
	println(<hasSameSize(storage)>);
	
	//type2
	run2(project);
	str type2 = getTimedFilename("Output_type2_");
	writeFile((|project://Series2/output/|)+ type2,"Output from analyzing clone classes of type2:\n");
	for (c <- storage ){
		appendToFile((|project://Series2/output/|)+ type2, c+"\n");
		appendToFile((|project://Series2/output/|)+ type2, storage[c]);
		appendToFile((|project://Series2/output/|)+ type2,"\n\n\n");
	}
	
	// testing
	//hasSameSize(storage);
}

/*
//for testing, TODO remove it
void extractClonesType1(loc project) {
	pairs ps = getClonePairsUsingLinesBlock(project);
	getCloneClassesUsingLinesBlock(ps);
	appendToFile(|project://Series2/output/output|,ps);
	run1(project);
	run2(project);
}*/
