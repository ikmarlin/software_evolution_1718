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
import ParseTree;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import clones::Type1;
import clones::Tools;


alias tree = set[Declaration];
alias pairs = rel[clone,clone];
public pairs clonePairs = {};
public int blockSize = 6;

str getTimedFilename(str basename) = basename + getTimeForFile();
str getTimeForFile() = printDateTime(now(), "YYYYMMddHHmmssSSS");

/* java projects of interest */
public loc smallsql = |project://smallsql0.21_src/|;
public loc hsqldb   = |project://hsqldb-2.3.1/|;

/* result smallsql:
	Count duplicated blocks = 445
	Count duplicated lines = 2670
	Duplication percentage = 11%
*/
void extractClonesType1(loc project) {
	pairs ps = getClonePairs(project);
	getCloneClasses(ps);
	appendToFile(|project://Series2/output/output|,ps);
}

void main() {
	//|project://Series2/output| + ("file_" + printDateTime(now(), "yyyyMMdd;hh.mm.ss")+ ".txt");
	//printDateTime(now(), "yyyyMMdd;hh.mm.ss");
	loc l = |project://Series2/testExamples/smallsql/database/Column.java|;
	set[Declaration] ast = createAstsFromEclipseProject(smallsql, true);
	//ast = createAstFromFile(l, true);
	//println("<ast>");
	children = [];
	for (Declaration a <- ast) {
		b = unsetRec(a);
		println(<getTrees(b)>);
		visit(b) {
			case node n: {
				//println("node = <n> size = <getSubtreeSize(n)>");
				children += getChildren(n);
			}
		}
	}
	
	dist = distribution(children);
	
	//for (d <-dist) {
		//println ("\n ***** <d> **** \n");
//	}
}
