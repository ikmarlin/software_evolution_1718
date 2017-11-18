module metrics::CalculateDuplication
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
import util::FileSystem;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::\syntax::Java15;
import Extractor;
import utils::Tools;
import metrics::CalculateLOC;
import metrics::SigModelScale;

/* We need to calculate the total-count lines of code, and the total-count of duplicated lines of code.
	rank 	duplication
	####################
	++ 		0-3%
	+ 		3-5%
	o 		5-10%
	- 		10-20%
	-- 		20-100%
*/

/* count the LOC in the java project, on files level, based on the 6-line block concept */
public int getCountLOCDuplication(M3 model) {
	blocksOf6Lines = [];
	//println("<size(extractFiles(model))>");
	for (l <- extractFiles(model)) {
		list[str] content = [trim(s) | s <- (getLOCNoCurlyBraces(l))]; // get LOC per file
		// ignore files that are shorter than 6 lines, exclusive comments, empty lines, leading spaces, and curly-braces
		if (size(content) >= 6){ // for foles of loc >=6 we store all possible blocks with file location and block index (start-line)
			blocksOf6Lines += [[l1,l2,l3,l4,l5,l6] | [_*,l1,l2,l3,l4,l5,l6,_*] := zip(content, index(content), [l | i <- [0..size(content)]])];
			//println("blocks: <blocksOf6Lines>");
		}
	}
	
	storage = ();
	dups = {};
	// scan list for possible duplicates
	for (b <- blocksOf6Lines) {
		// extract lines from block
		content = [line | <line,i,l> <- b];
		// check whether the sequencial lines of that block exists elsewhere, if yes register it as duplicate, otherwlse  add it
		if (!(content in storage)) { // save it to storage with file location & block start-line index
			storage[content] = b;
		} else { //duplicate and not same block, store it
			dups +=  {lineData | lineData <- content};
			//println("content: <content>");
		}
	}
	
	//lines in dups are duplicated line, return size of list
	//println("dups: <dups>");
	return size(dups);
}


public real getDuplicationRatio(M3 model) = toReal(getCountLOCDuplication(model))/toReal(size(extractAllLines(model)))*100;

/*  get sig-model rankining based on the duplicates ratio */
public str getDuplicationRanking(real ratio) {
	if(ratio >=0 && ratio <=3) return sigScales[0]; // ++
	if(ratio >3 && ratio <=5)return sigScales[1]; // +
	if(ratio >5 && ratio <=10) return sigScales[2]; // o
	if(ratio >10 && ratio <=20) return sigScales[3]; // -
	return sigScales[4]; // --
}
