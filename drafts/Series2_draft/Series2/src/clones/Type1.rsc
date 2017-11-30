module clones::Type1
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
 
import IO;
import List;
import Set;
import String;
import DateTime;
import util::Math;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import Node;
import Relation;
import Main;
import clones::Tools;

alias clone = tuple[loc l, list[str] lines];
alias clones = lrel[loc l, list[str] lines];
alias pairs = rel[clone,clone];

public int getSubtreeSize(node n) {
	count = 0;
	visit (n) {
		case node _: count += 1;
	}
	return count;
}

loc getSubtreeLocation(node n) {
	switch(n) {
        case Declaration d: return d@src;
        case Statement s: return s@src;
        case Expression e: return e@src;
        default : return |unknown:///|;
   }
}

//ighmelene
set[set[loc]] getCloneClasses(rel[node n, loc l] trees) {
	return groupRangeByDomain(trees);
}


set[rel[loc,list[str]]] getCloneClasses(pairs c) {
	list[rel[loc,list[str]]] l = [];
	for (n <- groupRangeByDomain(c)){
	  if(size(n) > 1) {l +=n;}
	}
	return toSet(l);
}

public pairs getClonePairs(loc project) {
	cleanVolume = 0;
	countDuplicates = 0;
	model = createM3FromEclipseProject(project);
	clones storage = [];
	contentIndex = 1;
	pairs res = {};
	
	for (f <- files(model)) {
		//moving window in file
		begin = 0;
		end = blockSize;
		
		//cleaning
		ls	= readFileLines(f);
		ls -= getBlankLines(ls);
		ls -= getMLComments(ls);
		ls -= getSLComments(ls);
		list[str] lines = [];
		for (l <- ls) {
			lines += trim(l);
		}
		
		// process files longer than 6 lines, exclusive comments, empty lines, leading spaces
		if (size(ls) >= blockSize) {
			cleanVolume += size(lines);
			while (size(lines) > end) {
				b = lines[begin..end]; // get block
				clone c1 = <f , b>;
				orig = countDuplicates;
			    for(c2 <- storage){
					if(b == c2[contentIndex]) {
						// clone detected, count block and append pairs to result
					    countDuplicates += 1;
						if (countDuplicates ==200) {
							println("clonepairs = \n 1***) <c1> \n\n 2***)<c2>");
						}
						res += <c1 , c2>; 
						begin +=1;
						if(size(lines) <= end+1) {end+=1;} // still some to go
					}
					
				}
				if(orig == countDuplicates) {
					// block b not found, store it for the first time and move window 1 line 
					storage += c1;
					begin += 1;
					end = begin + blockSize;
				}
			}
		}
	}

	println("Count duplicated blocks = <countDuplicates>");
	println("Count duplicated lines = <countDuplicates*blockSize>");
	println("Duplication percentage = <100*(countDuplicates*blockSize)/cleanVolume>%");
	return res;
}

// ighmelene
rel[node n, loc l] getTrees(Declaration ast) {
	rel[node,loc] statements = {};
	visit(ast) {
		case \method(_,_,_,_,Statement body): for(t <- getTrees(body)) statements += <unsetRec(t),t.src>;
		case \constructor(_,_,_,Statement body): for(t <- getTrees(body)) statements += <unsetRec(t),t.src>;
	}
	
	for (s <- statements) {
		println("*****<s>");
		println("*****");
	}
	
	return statements;
}

list[Statement] getTrees(Statement s) {
	stmts = [];
	visit(s) {
		case Statement stmt: stmts += stmt;
	}
	return stmts;
}


