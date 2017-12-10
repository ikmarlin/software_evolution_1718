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
/*
map[str, lrel[loc, int, bool]] storage = ();
map[str, lrel[loc, int, bool]] cloneClasses = ();
int minLoc = 3;*/

/* 1- Clones block of 6 lines -> series1 */
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
		ls -= getPackages(ls);
		ls -= getImports(ls);
		ls -= getBlankLines(ls);
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
	//println("XXXX= <res>");
	return res;
}


str checkRelation(clone c1, clone c2) {
	<l1,text1> = c1;
	<l2,text2> = c2;
	if (l1.uri != l2.uri) {
		return "no relation";
	} else if (l1 == l2) {
		return "equivalent";
	} else if (l1 > l2) {
		return "contains";
	} else if (l1 < l2) {
		return "contained in";
	} else {
		return "no relation";
	}
}

pairs filterClones() {
	pairs ps = getClonePairsUsingLinesBlock(smallsql);
	//println("ps = <ps>");
	for (<c1 , c2> <- ps) {
		for (<c3 , c4> <- ps) {
			str s1 = checkRelation(c1,c3);
			str s2 = checkRelation(c2,c4);
			if(s1 == "contained in" && s2 == "contained in"){
				println("contained in");
			}
			else if (s1 == "contains" && s2 == "contains") {
				println("contains");
			}
		}
	}
	return ps;
}

/* end of 1- Clones block of 6 lines -> series1 */



/* 2- detecting type1 clone classes using AST -> series2 */
void run1(loc project) {
	println("Type1");
	storage = ();
	cloneClasses = ();
    set[Declaration] asts = createAstsFromEclipseProject(project, true);
    getCloneClassesType1(asts);
	println("Storage size = <size(storage)>");
}

void getCloneClassesType1(set[Declaration] asts) {
	// get initial classes
	getInitialCloneClassesType1(asts);
	// get rid of strictly included classes
	postProcessCloneClasses();
}

void getInitialCloneClassesType1(set[Declaration] asts) {
    visit (asts) {
        case node n: storeSubtreeWithLoc(n);
    }
    for (key <- storage) {
		// at least duplicated once
        if (size(storage[key]) >= 2) {
            cloneClasses[key] = dup(storage[key]);
			/*println("class = <cloneClasses[key]>");
			println("****************************");
			println("****************************");
			println("****************************");
			println("XXX = <key>");*/
        }
    }
    println("clone classes before taking out strictly included clone classes = <size(cloneClasses)>");
}

void postProcessCloneClasses() {
	// post processing
	storage = ();
	list[str] finalClasses = [];
	for (c <- cloneClasses){ 
		bool keep = true; 
		for (entry <- cloneClasses){
			if(isTextContained(entry, c)){
				bool subsumed = isSubsumed(cloneClasses[entry],cloneClasses[c]);
				if (subsumed) {
					//println("delete clone class = <entry> ... <c>");
					//println("deleted ... <cloneClasses[entry]> ... <cloneClasses[c]>");
					keep = false;
				}
			}
		}
		if(keep){
			finalClasses += c;
		}
	}

	
	for(entry <- finalClasses){
		storage[entry] = cloneClasses[entry];
		/*println("class = <storage[entry] >");
		println("****************************");
		println("****************************");*/
	}
	println("clone classes after taking out strictly included clone classes = <size(finalClasses)>");
}

void storeSubtreeWithLoc(node subtree) {
    val = getSubtreeLocation(subtree);

	if(val!=|unknown:///|) {
		int begin = val.begin.line;
		int end = val.end.line;
		int length = end - begin;
		//println("XXX= <length>");
		
	  	if (length < minLoc) {
	        return;
	   	}
 	
	    subtree = unsetRec(subtree);
	    key = toString(subtree);
		if (storage[key]?) {
			storage[key] += <val,length,false>;
		} else {
			storage[key] = [<val,length,false>];
		}
	}
}


/* end of 2- detecting type1 clone classes */
