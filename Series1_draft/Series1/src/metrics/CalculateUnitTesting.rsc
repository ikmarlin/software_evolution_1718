module metrics::CalculateUnitTesting
/**
 * Bonus
 * This module is
 * 
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import Set;
import List;
import Relation;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::AST;

import Main;
import Extractor;
import metrics::SigModelScale;

/*
*	rank 	unit test coverage
*	############################
*	++ 			95-100%
*	+ 			80-95%
*	o 			60-80%
*	- 			20-60%
*	-- 			0-20%
*
* |java+class:///smallsql/junit/BasicTestCase|
* rascal>getUnitTestCoverage(smallModel, |java+class:///smallsql/junit/BasicTestCase|);
* real: 15.6393744300.
*
*
* rascal>getUnitTestCoverageRanking(getUnitTestCoverage(smallModel, |java+class:///smallsql/junit/BasicTestCase|));
* str: "--"
*/


/* get all methods in test-units */
list[loc] extractTestsMethods(M3 model, loc extendedTestClass) {
	list[loc] junitClasses = 
		[from | <from,to> <- model.extends, to == extendedTestClass];   
    //println("<junitClasses>");
    return [m | c <- junitClasses, m <- methods(model, c)];
}


/* get methods that are called from test-units */
list[loc] extractCalledMethods(M3 model, loc extendedTestClass) {
	// grep all methods that are in a class  for testing (extends BasicTestCase)
    list[loc] ms = extractTestsMethods(model, extendedTestClass);
    //println("<model.methodInvocation>");
    list[loc] result = [];
    for (<caller, called> <- model.methodInvocation) {
    	if (caller in ms && called notin ms) {
    		result += called;
    		//println ("<caller>");
    	} else continue; 
    }
   return result;
}


/* calculate the unit-test-coverage, it is needed for test-quality */
public real getUnitTestCoverage(M3 model, loc extendedTestClass) {
	real methodsTested = 
	 toReal(size([m | m <- extractMethods(model), m notin extractTestsMethods(model, extendedTestClass)]));
	real calledMethods = toReal(size(extractCalledMethods(model, extendedTestClass)));
	println("<methodsTested>, <calledMethods>");
	if (methodsTested !=0) return (calledMethods/methodsTested)*100; else return 0;
}


/* get sig-model ranking for unit-test-coverage */
public str getUnitTestCoverageRanking(real ratio) {
	if(ratio >=95 && ratio <=100) return sigScales[0]; // ++
	if(ratio >95 && ratio <=80)return sigScales[1]; // +
	if(ratio >80 && ratio <=60) return sigScales[2]; // o
	if(ratio >60 && ratio <=20) return sigScales[3]; // -
	return sigScales[4]; // --
}



public int getCountAssertionStatements(M3 model, loc extendedTestClass) {
    int total = 0;
    list[loc] ms = extractTestsMethods(model, extendedTestClass);
    for (m <- ms){
	    int counter = 0;
   		a 	= createAstFromFile(m, true);
	    if ((\constructor(_,_,_,Statement impl) := a) || (method(_,_,_,_,Statement impl) := a)) {  
	        visit (impl){
	            case \assert(Expression expression): counter += 1;
	            case \assert(Expression expression, Expression message): counter += 1;
	            case \methodCall(bool isSuper, /assert/, list[Expression] arguments): counter += 1;
	            case \methodCall(bool isSuper, Expression receiver, /assert/, list[Expression] arguments):counter += 1;
			 }
	    }
		total += counter;
    }
    return total;
}