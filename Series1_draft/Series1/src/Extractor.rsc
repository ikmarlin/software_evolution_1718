module Extractor
/**
 *
 * This module is
 * 
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import String;
import List;
import Set;
import Map;
import util::FileSystem;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::\syntax::Java15;
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


/* get asts of a class */	
public Declaration _getClassAst(loc f){
	if(f notin asts){
		asts[f] = createAstFromFile(f, true);
	}
	return asts[f];
}

/* get test methods */
public list[loc] extractTestMethods(loc testloc) = extractMethods(testloc);

/* get non-test methods */
public list[loc] extractNoTestMethods(M3 model) = [m | m <-extractMethods(model), m notin extractTestMethods(junitLoc)];

/*TODO, not used, get files from a java project, excluding sub-folders and with specific extension */
public list[loc] extractSpecificFiles(loc project, list[str] paths, str fileExt) =
	[f | path <- paths, /file(f) <- crawl(project), f.extension == fileExt && f.path != path];
// rascal>extractFiles(smallsql, ["junit"], "java");
