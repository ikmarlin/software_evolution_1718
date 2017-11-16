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
import util::Benchmark;
import util::FileSystem;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;
import lang::java::\syntax::Java15;
import analysis::graphs::Graph;
import Extractor;
import utils::Tools;
import metrics::CalculateVolume;
import metrics::CalculateUnitSize;
import metrics::CalculateUnitTesting;
import metrics::CalculateDuplication;
import metrics::CalculateUnitComplexity;
import metrics::CalculateCyclomaticComplexity;

/* java projects of interest */
public loc smallsql = |project://smallsql0.21_src/|;
public loc hsqldb   = |project://hsqldb-2.3.1/|;

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

void main(){
 	int time = realTime();
	println("***Start of demo .. analyzing code for project smallsql...");
	
	real dupsRatio = getDuplicationRatio(smallModel);
	str dupsScale = getDuplicationRanking(dupsRatio);
	println("***Code duplication = <dupsRatio>% : <dupsScale>");
	
	str ccScale = getCyclomaticComplexityRanking(smallModel);
	println("***Unit-cc-ranking = <ccScale>");
	
	// is it needed?
	ComplexityRisksPercentages tup = getComplexityRisksPercentages(smallModel);
	usScale = getUnitComplexityRanking(tup);
	println ("***Complexity % based on unit-size = <tup>, <usScale>");
	
	
	int vol = getVolumeAllFiles(smallModel);
	str volScale = getVolumeRanking(vol);
	println("***Code volume = <vol> LOC : <volScale>");
	
	
	real coverage = getUnitTestCoverage(smallModel, |java+class:///smallsql/junit/BasicTestCase|);
	str utscale = getUnitTestCoverageRanking(coverage);
	println("***Unit-test-coverage = <coverage>% : <utscale>");
	
	println("########################");
	changeability(ccScale, dupsScale);
	testability(ccScale, utscale);
	analysability(volScale, dupsScale, utscale, usScale);
	stability(utscale);
	
	// overall
	//maintainability(smallModel);
	
	debug("***demo time: <time/1000.0> seconds");
	println("***End of demo...");
}


// TODO review how we get the overall ranking per aspect
void analysability(str vol, str dupl, str ut, str us){
	int volVal = sigScalesMap[vol];
	int duplval = sigScalesMap[dupl];
	int utVal = sigScalesMap[ut];
	int usVal = sigScalesMap[us];
	int anScale = toInt((volVal+duplval+utVal+usVal)/4);
	println("Analysability ranking <anScale>");
}

void changeability(str cc, str dupl){
	int ccval = sigScalesMap[cc];
	int duplval = sigScalesMap[dupl];
	int chScale = toInt((ccval+duplval)/2);
	println("Changeability ranking <chScale>");
}

void testability(str cc, str ut){
	int ccval = sigScalesMap[cc];
	int utVal = sigScalesMap[ut];
	int tsScale = toInt((ccval+utVal)/2);
	println("Testability <tsScale>");
}

// bonus
void stability(str ut){
	println("Stability ranking <ut>");
}