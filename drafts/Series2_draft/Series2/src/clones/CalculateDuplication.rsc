module clones::CalculateDuplication
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
import Set;
import Relation;
import Map;
import util::Math;
import lang::java::jdt::m3::Core;
import Main;
import clones::Tools;


/* We need to calculate the total-count lines of code, and the total-count of duplicated lines of code.
	rank 	duplication
	####################
	++ 		0-3%
	+ 		3-5%
	o 		5-10%
	- 		10-20%
	-- 		20-100%
*/

public int countCleanLOC = 0;

public int getUnitSize(loc f) {
	ls	= readFileLines(f);
	ls -= getBlankLines(ls);
	ls -= getMLComments(ls);
	ls -= getSLComments(ls);
	return size(ls);
}

/* calculate volume based on files in java project */
public int getVolume(M3 m) = (0 | it + getUnitSize(l) | l <- files(m));


/* count the LOC in the java project, on files level, based on the 6-line block concept */
public int getCountLOCDuplication(M3 model) {
	blocksOf6Lines = [];
	//println("<size(extractFiles(model))>");
	for (l <- files(model)) {
		list[str] content = [trim(s) | s <- (getUnitSize(l))]; // get LOC per file
		countCleanLOC += size(content);
		// ignore files that are shorter than 6 lines, exclusive comments, empty lines, leading spaces
		if (size(content) >= 6){ // for files of loc >=6 we store all possible blocks with file location and block index (start-line)
			blocksOf6Lines += [[l1,l2,l3,l4,l5,l6] | [_*,l1,l2,l3,l4,l5,l6,_*] := zip(content, index(content), [l | i <- [0..size(content)]])];
			//println("blocks: <blocksOf6Lines>");
		}
	}
	
	println("volume after cleaning = <countCleanLOC>");
	storage = ();
	dups = {};
	// scan list for possible duplicates
	for (b <- blocksOf6Lines) {
		// extract lines from block
		content = [line | <line,i,l> <- b];
		// check whether the sequencial lines of that block exists elsewhere, if yes register it as duplicate, otherwlse  add it
		if (content notin storage) { // save it to storage with file location & block start-line index
			storage[content] = b;
		} else { //duplicate and not same block, store it
			dups +=  {lineData | lineData <- b};
			if(storage[content] notin dups) 
				dups +=  {lineData | lineData <- storage[content]};
			//println("content: <content>");
		}
	}
	
	//lines in dups are duplicated line, return size of list
	println("Duplicated LOC = <size(dups)>");
	return size(dups);
}


public real getDuplicationRatio(M3 model) {
	if(countCleanLOC!=0) {
	 	return toReal(getCountLOCDuplication(model))/toReal(countCleanLOC)*100;
	 } else {
		println("calculate volume first");
		return 0.;
	}
}


