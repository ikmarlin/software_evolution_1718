module Main
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
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;
import lang::java::\syntax::Java15;
import analysis::graphs::Graph;
import Extractor;
import utils::Tools;
import metrics;

/* java projects of interest */
public loc smallsql = |project://smallsql0.21_src/|;
public loc hsqldb   = |project://hsqldb-2.3.1/|;
public loc junitLoc = |project://smallsql0.21_src/src/junit|;

/* create a model from eclipse project*/
public M3 getModelForProject(loc projectLoc) =  createM3FromEclipseProject(projectLoc);

/* models of interest */
public M3 smallModel = getModelForProject(smallsql);
public M3 hsModel    = getModelForProject(hsqldb);

/* public maps to store intermediate or final output */
public int volume					= 0;
public map[loc,M3] m3s 				= ();
public map[loc,Declaration] asts 	= ();
public map[loc,str] filestr			= ();
public map[loc,list[str]] filearr	= ();
public map[loc,int] unitsize		= ();
public map[loc,int] unitcc			= ();

public void main(){

}