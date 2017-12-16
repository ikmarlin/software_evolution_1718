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
import Visualization;
import clones::Type1;
import clones::Type2;
import clones::Tools;
import tests::TestType1;


alias tree = set[Declaration];
alias pairs = rel[clone,clone];
public pairs clonePairs = {};
public int blockSize = 6;


public map[str, lrel[loc, int, bool]] storage = ();
public map[str, lrel[loc, int, bool]] cloneClasses = ();
public int minLoc = 6; // min loc for statement to be considered as clone, change from 1 to 6 or suitable val

str getTimedFilename(str basename) = basename + getTimeForFile();
str getTimeForFile() = printDateTime(now(), "YYYYMMddHHmmssSSS");

/* java projects of interest */
public loc smallsql = |project://smallsql0.21_src/|;
public loc hsqldb   = |project://hsqldb-2.3.1/|;



void main(loc project) {
	//type1
	run1(project);
	str type1 = getTimedFilename("Output_type1_");
	writeFile((|project://Series2/output/|)+ type1,"Output from analyzing clone classes of type1:\n\n");
	countClass = 0;
	for (c <- storage ){
		countClass += 1;
		appendToFile((|project://Series2/output/|)+ type1, countClass);
		appendToFile((|project://Series2/output/|)+ type1, ")\n" + c + "\n");
		for (cc <- storage[c]) {
			appendToFile((|project://Series2/output/|)+ type1, cc[0]);
			appendToFile((|project://Series2/output/|)+ type1, "\n");
		}
		appendToFile((|project://Series2/output/|)+ type1,"\n\n\n");
	}
	
	// testing
	//println(<hasSameSize(storage)>);
	//println(<correctClasses(storage)>);
	
	//type2
	run2(project);
	str type2 = getTimedFilename("Output_type2_");
	writeFile((|project://Series2/output/|)+ type2,"Output from analyzing clone classes of type2:\n");
	countClass = 0;
	for (c <- storage ){
		countClass += 1;
		appendToFile((|project://Series2/output/|)+ type2, countClass);
		appendToFile((|project://Series2/output/|)+ type2, ")\n" + c + "\n");
		for (cc <- storage[c]) {
			appendToFile((|project://Series2/output/|)+ type2, cc[0]);
			appendToFile((|project://Series2/output/|)+ type2, "\n");
		}
		appendToFile((|project://Series2/output/|)+ type2,"\n\n\n");
	}
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
