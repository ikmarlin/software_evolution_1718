module Main
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import String;
import List;
import Set;
import Map;
import util::Math;
import util::Benchmark;
import util::FileSystem;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;
import analysis::graphs::Graph;
import Extractor;
import utils::Tools;
import metrics::CalculateVolume;
import metrics::CalculateUnitSize;
import metrics::CalculateUnitTesting;
import metrics::CalculateDuplication;
import metrics::CalculateCyclomaticComplexity;

/* java projects of interest */
public loc smallsql = |project://smallsql0.21_src/|;
public loc hsqldb   = |project://hsqldb-2.3.1/|;


/* test-classes of interest */
public loc baseClassSmall	= |java+class:///smallsql/junit/BasicTestCase|;
public loc baseClassHQ 	= |java+class:///org/hsqldb/test/TestBase|;

/* public maps to store intermediate or final output */
public map[loc,int]	unitCCs			= ();
public map[loc,M3] models			= ();
public map[loc,Declaration] asts	= ();

//checkMaintainability(smallsql, baseClassSmall);
//checkMaintainability(hsqldb, baseClassHQ);

void checkMaintainability(loc project, loc baseClass){
	model = createM3FromEclipseProject(project);
	checkMaintainability(model, baseClass);
}

void checkMaintainability(M3 m, loc baseClass){
 	int time = realTime();
	println("***Start of demo .. analyzing code for project ...");
	int blockSize = 6;
	int labelLength			= 20;
	int intLength			= 8;
	int percLength			= 7;
	int volume				= getVolume(m);
	int duplication			= getDuplication(m, blockSize);
	int unitTestCoverage 	= getUnitTestCoverage(m, baseClass);
	int assertCount 		= getCountAssertionStatements(m, baseClass);
	map[loc,int] sizes		= getUnitSizes(m);
	map[loc,int] ccs		= getCyclomaticComplexity(m);
	map[str,int] aggrSizes	= aggrUnitSizes(sizes);
	map[str,int] aggrCCs	= aggrUnitCCs(ccs,sizes);
	list[str] sizeClasses 	= ["low","moderate","high","very high"];
	list[str] ccClasses 	= ["low","moderate","high","very high"];
	int volRating			= getVolumeRating(volume);
	int unitCCRating		= getCyclomaticComplexityRating(aggrCCs,volume);
	int dupRating			= getDuplicationRating(duplication);
	int unitSizeRating		= getUnitSizeRating(aggrSizes,volume);
	int unitTestCovRating   = getUnitTestCoverageRanking(unitTestCoverage);
	int analysability		= getAnalysabilityRating(volRating,dupRating,unitSizeRating,unitTestCovRating);
	int changeability		= getChangeabilityRating(unitCCRating,dupRating);
	int testability			= getTestabilityRating(unitCCRating,unitSizeRating,unitTestCovRating);
	int stability 			= unitTestCovRating;
	int maintainability		= getMaintainabilityRating(analysability,changeability,testability,stability);
	

	print(left("Volume:",labelLength," "));
	println(right("<volume>",intLength," "));
	print(left("Rating:",labelLength," "));
	println(right("<volRating>",intLength," "));
	
	println(left("",labelLength+intLength,"-"));
	
	println(left("Unit size:",labelLength," "));
	for(classification <- sizeClasses)
	{
		print(left("<classification>:",labelLength," "));
		println("<right("<percent(aggrSizes[classification],volume)>",percLength," ")>%");
	}
	print(left("Rating:",labelLength," "));
	println(right("<unitSizeRating>",intLength," "));
	
	println(left("",labelLength+intLength,"-"));
	
	println(left("Complexity:",labelLength," "));
	for(classification <- ccClasses)
	{
		print(left("<classification>:",labelLength," "));
		println("<right("<percent(aggrCCs[classification],volume)>",percLength," ")>%");
	}
	print(left("Rating:",labelLength," "));
	println(right("<unitCCRating>",intLength," "));
	
	println(left("",labelLength+intLength,"-"));
	
	print(left("Duplication:",labelLength," "));
	println("<right("<duplication>",percLength," ")>%");
	print(left("Rating:",labelLength," "));
	println(right("<dupRating>",intLength," "));
	
	println(left("",labelLength+intLength,"-"));
	
	print(left("Unit-testing:",labelLength," "));
	println("<right("<unitTestCoverage>",percLength," ")>%");
	print(left("Rating:",labelLength," "));
	println(right("<unitTestCovRating>",intLength," "));
	print(left("Assert-count:",labelLength," "));
	println(right("<assertCount>",intLength," "));
	
	println(left("",labelLength+intLength,"-"));
	
	
	print(left("Analysability:",labelLength," "));
	println("<right("<analysability>",intLength," ")>");
	print(left("Changeability:",labelLength," "));
	println(right("<changeability>",intLength," "));
	print(left("Testability:",labelLength," "));
	println(right("<testability>",intLength," "));
	print(left("Stability:",labelLength," "));
	println(right("<unitTestCovRating>",intLength," "));
	print(left("Maintainability:",labelLength," "));
	println("<right("<maintainability>",intLength," ")>");
	
	println("***demo time: <time/10000000>");
	println("***End of demo...");
}

int getAnalysabilityRating(int volRating, int dupRating, int unitSizeRating, int unitTestCovRating) 
	= average([volRating,dupRating,unitSizeRating,unitTestCovRating]);

int getChangeabilityRating(int unitCCRating, int dupRating)
	=  average([unitCCRating,dupRating]);

int getTestabilityRating(int unitCCRating, int unitSizeRating, int unitTestCovRating) 
	= average([unitCCRating,unitSizeRating,unitTestCovRating]);
	
int getMaintainabilityRating(int analysability, int changeability, int testability, int stability) 
	= average([analysability,changeability,testability,stability]);