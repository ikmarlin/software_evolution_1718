module main

import IO;
import Map;
import Set;
import List;
import String;
import util::Math;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import duplication;
import Extractor;
import utils::Tools;
import metrics::CalculateVolume;
import metrics::CalculateUnitSize;
import metrics::CalculateUnitTesting;
import metrics::CalculateDuplication;
import metrics::CalculateUnitComplexity;
import metrics::CalculateCyclomaticComplexity;

public map[loc,int]	unitSizes	= ();
public map[loc,int]	unitCCs		= ();
public map[loc,M3] models		= ();
public map[loc,Declaration] asts	= ();

void check(loc project) {
	if(project notin models) 	{
		models[project] = createM3FromEclipseProject(project);
	}
	check(models[project]);
}

void check(M3 m) {
	int labelLength			= 20;
	int intLength			= 8;
	int percLength			= 7;
	int volume				= getVolume(m);
	int duplication			= getDuplication(m,6);
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
	int analysability		= getAnalysabilityRating(volRating,dupRating,unitSizeRating);
	int changeability		= getChangeabilityRating(unitCCRating,dupRating);
	int testability			= getTestabilityRating(unitCCRating,unitSizeRating);
	
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
	
	print(left("Analysability:",labelLength," "));
	println("<right("<analysability>",intLength," ")>");
	print(left("Changeability:",labelLength," "));
	println(right("<changeability>",intLength," "));
	print(left("Testability:",labelLength," "));
	println(right("<testability>",intLength," "));
	print(left("Maintainability:",labelLength," "));
	println("<right("<average([analysability,changeability,testability])>",intLength," ")>");
}

int getAnalysabilityRating(int volRating, int dupRating, int unitSizeRating) 
	= average([volRating,dupRating,unitSizeRating]);

int getChangeabilityRating(int unitCCRating, int dupRating)
	=  average([unitCCRating,dupRating]);

int getTestabilityRating(int unitCCRating, int unitSizeRating) 
	= average([unitCCRating,unitSizeRating]);

//fixme
int stability(int ut)
	= average([utRating]);
