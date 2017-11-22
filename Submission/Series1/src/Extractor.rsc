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

/* get files from a java project */
public list[loc] extractFiles(M3 model) = toList(files(model));
public int lengthExtractedFiles(loc project) = size([f | /file(f) <- crawl(project)]); //all lines included


/* count number of java classes in the model (project) */
public list[loc] extractClasses(M3 model) = toList(classes(model));
public int countClasses(M3 model) = size(toList(classes(model)));

/* count number of units in the model (project) */
public list[loc] extractMethods(M3 model) = toList(methods(model));
public int countMethods(M3 model) = size(toList(methods(model)));


/* get test & non-test methods */
public list[loc] extractTestMethods(M3 model)  
	= [m | m <-extractMethods(testModel)];
public list[loc] extractNoTestMethods(M3 model)
	=  [m | m <-extractMethods(model), m notin extractMethods(testModel)];

/* get asts of an item (File) */	
public Declaration getFileAst(loc l) {
	if(l notin asts) {
		asts[l] = createAstFromFile(l, true);
	}
	return asts[l];
}
