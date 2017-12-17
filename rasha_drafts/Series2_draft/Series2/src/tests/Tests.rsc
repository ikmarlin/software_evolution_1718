module tests::Tests
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import Prelude;
import Main;
import clones::Type1;
import clones::Type2;
import Visualization;

loc proj = |project://smallsql0.21_src_test|;

void runTest1() {
	storage = ();
	cloneClasses = ();
	run1(smallsql);
	// testing
	println(<hasSameSize()>);
	println(<correctClasses()>);
	println(<countClonesCorrect()>);
}

void runTest2() {
	storage = ();
	cloneClasses = ();
	run2(smallsql);
	// testing
	println(<hasSameSize()>);
	println(<correctClasses()>);
	println(<countClonesCorrect()>);
}


/* properties */
bool hasSameSize() {
	bool isSameSize = true;
	for (key <- cloneClasses) {
		for (rel1 <- cloneClasses[key]) {
			for (rel2 <- cloneClasses[key]) {
				if (rel1!=rel2) {
					isSameSize = (rel1[1] == rel2[1]);
					if(!isSameSize) {
						if ((rel1[1] - rel2[1]) == 1) {
							isSameSize = true;
						}
						if ((rel2[1] - rel1[1]) == 1) {
							isSameSize = true;
						}
					}
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

bool correctClasses() {
	bool isCorrectClasses = true;
	for (key1 <- cloneClasses) {
		for (key2 <- cloneClasses) {
			if (key1!=key2) {
				isCorrectClasses = (cloneClasses[key1] != cloneClasses[key2]);
			}		
		}
		if (!isCorrectClasses) {
			break;
		}
	}
	return isCorrectClasses;
}

bool countClonesCorrect() {
	int clonesVol = getVolumeClones();
	int count = 0;
	for(key <- cloneClasses) {
		for (c <- cloneClasses[key]) {
			count += c[1];
		}
	}
	
	return (clonesVol == count);
}
