module metrics::Test

import IO;
import String;
import List;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::\syntax::Java15;


//A methodAST = getMethodASTEclipse(|project://smallsql0.21_src/src/smallsql/database/Column.java|, model=model);

public void bla() {
	M3 model = createM3FromEclipseProject(|project://smallsql0.21_src|);
	
	str body = readFile(|project://smallsql0.21_src/src/smallsql/database/Column.java|);
	
	set[loc] m = methods(model);
	println("<m>");
	//for(x <- m) {AST mAST = getMethodASTEclipse(x,model); }
}