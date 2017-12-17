module Tests
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import Prelude;
import Main;
import clones::Type1;
import clones::Type2;

loc proj = |project://smallsql0.21_src_test|;

/* results 
	rascal>runTest();
	Type1
	clone classes before taking out strictly included clone classes = 9
	clone classes after taking out strictly included clone classes = 9
	Storage size = 9
	<true>
	<true>
	ok
*/
void runTest() {
	storage = ();
	cloneClasses = ();
	run1(proj);
	// testing
	println(<hasSameSize(storage)>);
	println(<correctClasses(storage)>);
}


/* properties */
bool hasSameSize(map[str, lrel[loc, int]] storage) {
	bool isSameSize = true;
	for (key <- storage) {
		for (rel1 <- storage[key]) {
			for (rel2 <- storage[key]) {
				if (rel1!=rel2) {
					isSameSize = (rel1[1] == rel2[1]);
					//println("<key>, <rel1[1]>");
					//println("<key>, <rel2[1]>");
				}	
			}
		}
		if (!isSameSize) {
			break;
		}
	}
	return isSameSize;
}

bool correctClasses(map[str, lrel[loc, int]] storage) {
	bool isCorrectClasses = true;
	for (key1 <- storage) {
		for (key2 <- storage) {
			if (key1!=key2) {
				isCorrectClasses = (storage[key1] != storage[key2]);
			}		
		}
		if (!isCorrectClasses) {
			break;
		}
	}
	return isCorrectClasses;
}
