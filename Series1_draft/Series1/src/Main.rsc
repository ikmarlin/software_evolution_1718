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
import Extractor;
import utils::Tools;

/* java projects of interest */
public loc smallsql = |project://smallsql0.21_src/src/|;
public loc hsqldb = |project://hsqldb-2.3.1/hsqldb/|;

/* model from a project*/
public M3 getModelForProject(loc projectLoc) =  createM3FromEclipseProject(projectLoc);

/* models of interest */
public M3 smallModel = getModelForProject(smallsql);
public M3 hsModel = getModelForProject(hsqldb);

public void main(){

}