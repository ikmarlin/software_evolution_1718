module Extractor

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
public list[loc] extractFiles(loc project, list[str] paths, str fileExt) =
	[f | path <- paths, /file(f) <- crawl(project), f.extension == fileExt && f.path != path];
// rascal>extractFiles(smallsql, ["junit"], "java");

/* count number of java classes in the model (project) 
TODO we need to exclude the junit folder */
public list[loc] extractClasses(M3 model) = toList(classes(model));
public int countClasses(M3 model) = size(toList(classes(model)));

public list[loc] extractMethods(M3 model) {
	list[str] bodyTexts = [];
	methodslocs = methods(model);
	for (l <- methodslocs) {
		//println("<l>");
		statementsInMethod(l);
	}
	return toList(methodslocs);
}
	
/*
extractFiles(smallsql, ["junit", "tool"], "java");
extractFiles(smallsql, ["junit"], "java");

*/


public void statementsInMethod(loc location) {
    ast = createAstFromFile(location, true, javaVersion="1.8");
	visit(ast){ 
    case \if(icond,ithen,ielse): {
        println(" if-then-else statement with condition <icond> found\n"); } 
    case \if(icond,ithen): {
        println(" if-then statement with condition <icond> found\n"); } 
    case \while(icond): {
    	println(" while statement with condition <icond> found\n"); } 
    case \for(_): {
    	println(" for statement found\n"); } 
	};
}

public list[loc] extractFiles_(loc project) =
	[f | /file(f) <- crawl(project)];
	
public int lengthExtractFiles_(loc project) =
	size([f | /file(f) <- crawl(project)]);