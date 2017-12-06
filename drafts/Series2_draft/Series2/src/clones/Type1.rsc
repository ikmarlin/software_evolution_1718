module clones::Type1
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
 
import Prelude;
import DateTime;
import util::Math;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import Node;
import Main;
import clones::Tools;

alias clone = tuple[loc l, list[str] lines];
alias clones = lrel[loc l, list[str] lines];
alias pairs = rel[clone,clone];


/* 1- Clones block of 6 lines */
set[rel[loc,list[str]]] getCloneClassesUsingLinesBlock(pairs c) {
	list[rel[loc,list[str]]] l = [];
	for (n <- groupRangeByDomain(c)){
	  if(size(n) > 1) {l +=n;}
	}
	println("size = <size(l)>");
	return toSet(l);
}

public pairs getClonePairsUsingLinesBlock(loc project) {
	cleanVolume = 0;
	countDuplicates = 0;
	model = createM3FromEclipseProject(project);
	clones store = [];
	contentIndex = 1;
	pairs res = {};
	//println("<files(model)>");
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
		
		//println("lines <lines>");
		
		// process files longer than 6 lines, exclusive comments, empty lines, leading spaces
		if (size(ls) >= blockSize) {
			cleanVolume += size(lines);
			while (size(lines) > end) {
				b = lines[begin..end]; // get block
				clone c1 = <f , b>;
				orig = countDuplicates;
			    for(c2 <- store){
					if(b == c2[contentIndex]) {
						// clone detected, count block and append pairs to result
					    countDuplicates += 1;
						/*if (size(b) >6) {
							println("XXXXXXXXXXXXXXXXXXclonepairs = \n 1***) <c1> \n\n 2***)<c2>");
						}*/
						res += <c1 , c2>; 
						begin +=1;
						if(size(lines) <= end+1) {end+=1;} // still some to go
					}
					
				}
				if(orig == countDuplicates) {
					// block b not found, store it for the first time and move window 1 line 
					store += c1;
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

/* end of 1- Clones block of 6 lines */



/* 2- detecting type1 clone classes */
void run1(loc project) {
	println("Type1");
	storage = ();
	cloneClasses = ();
    set[Declaration] asts = createAstsFromEclipseProject(project, true);
    getCloneClassesType1(asts);
	println("Storage size = <size(storage)>");
}

void getCloneClassesType1(set[Declaration] ast) {
    visit (ast) {
        case node n: storeSubtreeWithLoc(n);
    }
    for (key <- storage){
		// at least duplicated once
        if (size(storage[key]) >= 2) {
            cloneClasses[key] = dup(storage[key]);
			//println("XXX = <key>");
        }
    }
	
    println(<size(cloneClasses)>);
}

void storeSubtreeWithLoc(node subtree) {
    val = getSubtreeLocation(subtree);

	if(val!=|unknown:///|) {
		int begin = val.begin.line;
		int end = val.end.line;
		int length = end - begin;
		//println("XXX= <length>");
		
	  	if (length < 6) {
	        return;
	   	}
	    subtree = unsetRec(subtree);
	    key = toString(subtree);
		if (storage[key]?) {
			storage[key] += val;
			
		} else {
			storage[key] = [val];
		}
	}
	return;
}

/* end of 2- detecting type1 clone classes */

/* Testing section */
//property1
bool property1(clone x, clone y) {
		return (x.lines == y.lines);
}
