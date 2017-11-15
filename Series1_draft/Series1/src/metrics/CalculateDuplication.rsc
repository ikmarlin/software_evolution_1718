module metrics::CalculateDuplication

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
	rascal>getCountLOCDuplication(smallModel);
	int: 892
	
	rascal>getDuplicationRatio(smallModel);
	real: 4.23049561300
	
	rascal>getDuplicationRanking(getDuplicationRatio(smallModel));
	str: "+"
*/

public int getCountLOCDuplication(loc project) {
	blocksOf6Lines = [];
	//println("<extractFiles(project)>");
	for (l <- extractFiles(project)) {
		list[str] content = getLOCFileNoCurlyBraces(l); // method LOC
		//println("<content> <size(content)>");
		if (size(content) >= 6){
		// for methods of loc >=6 excluding comment blocks, empty lines and white-spaces, we store all possible blocks
			blocksOf6Lines += [[l1,l2,l3,l4,l5,l6] | [_*,l1,l2,l3,l4,l5,l6,_*] := zip(content, index(content), [l | i <- [0..size(content)]])];
		}
	}
	storage = ();
	dups = [];
	for (b <- blocksOf6Lines) {
		// extract lines from block
		content = [line | <line,i,l> <- b];
		// check whether the sequencial lines of that block exists elsewhere, if yes register it as duplicate, otherwlse  add it
		if (!(content in storage)) {
			storage[content] = b;
		} else {
			dups += {lineData | lineData <- b};
		}
	}
	return size(dups);
}


public real getDuplicationRatio(M3 model) = toReal(getCountLOCDuplication(model))/toReal(size(extractAllLines(model)))*100;

// sigScales = ["++", "+", "o", "-", "--"]; 
public str getDuplicationRanking(real ratio) {
	if(ratio >=0 && ratio <=3) return sigScales[0]; // ++
	else if(ratio >3 && ratio <=5)return sigScales[1]; // +
	else if(ratio >5 && ratio <=10) return sigScales[2]; // o
	else if(ratio >10 && ratio <=20) return sigScales[3]; // -
	else return sigScales[4]; // --
}
