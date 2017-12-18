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
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Visualization;
import clones::Type1;
import clones::Type2;
import clones::Tools;
import tests::Tests;

alias pairs = rel[clone,clone];
public pairs clonePairs = {};
public int blockSize = 6;

/* Series2 public variables */
public map[str, lrel[loc, int]] storage = ();
public map[str, lrel[loc, int]] cloneClasses = ();
public int minLoc = 5; // min loc for statement to be considered as clone, change from 1 to 6 or suitable val
public int perc = 0;

/* functions to get time-stamp in output file name */
str getTimedFilename(str basename) = basename + getTimeForFile();
str getTimeForFile() = printDateTime(now(), "YYYYMMddHHmm");

/* java projects of interest */
public loc smallsql = |project://smallsql0.21_src/|;
public loc hsqldb   = |project://hsqldb-2.3.1/|;


/* Main function to run clone detection type 1 & 2 and testing */
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
	
	// testing1
	//runTest1();
	
	/***************************************************************************************/
	//type2
	run2(project);
	str type2 = getTimedFilename("Output_type2_");
	writeFile((|project://Series2/output/|)+ type2,"Output from analyzing clone classes of type2:\n\n");
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
	
	// testing2
	//runTest2();
	
	
	
	/**********Visualizatio****************/
	
	/* it runs the visualizer for all types, main screen will show up, and here you go.
	*  false because no project is selected yet, 
	*it will turn into true when the user selects any project from the drop-down-list on main screen
	*/
	//visualize(false);
}
