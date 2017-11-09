module Main

import IO;
import String;
import List;
import Set;
import Map;
import util::FileSystem;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::\syntax::Java15;
import utils::Tools;

/* java projects */
public loc smallsql = |project://smallsql0.21_src/src/|;
public loc hsqldb = |project://hsqldb-2.3.1/hsqldb/|;

/* model from a project*/
public M3 getModelForProject(loc projectLoc) =  createM3FromEclipseProject(projectLoc);

/* models of interest */
public M3 smallModel = getModelForProject(smallsql);
public M3 hsModel = getModelForProject(hsqldb);

/* get files of a java project */
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
	return methodslocs;
}
	
/*
extractFiles(smallsql, ["junit", "tool"], "java");
extractFiles(smallsql, ["junit"], "java");

filterExtractedMethods(smallModel, ["junit"], "java");
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
