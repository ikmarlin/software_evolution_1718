module Extractor
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import String;
import List;
import util::FileSystem;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import Main;
import utils::Tools;
import metrics::CalculateLOC;

/* get asts of an item (File) */	
public Declaration getFileAst(loc l) {
	if(l notin asts) {
		asts[l] = createAstFromFile(l, true);
	}
	return asts[l];
}
