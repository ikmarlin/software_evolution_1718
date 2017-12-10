module tests::TestType1

import Prelude;

bool hasSameSize(map[str, lrel[loc, int, bool]] storage) {
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


