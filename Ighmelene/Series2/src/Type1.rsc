module Type1

import IO;
import List;
import DateTime;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import Node;
import Relation;

str getTimedFilename(str basename) = basename + getTimeForFile();
str getTimeForFile() = printDateTime(now(), "YYYYMMddHHmmssSSS");

set[set[loc]] getCloneClasses(rel[node n, loc l] trees)
{
	return groupRangeByDomain(trees);
}

rel[node n, loc l] getTrees(Declaration ast)
{
	rel[node,loc] statements = {};
	visit(ast)
	{
		case \method(_,_,_,_,Statement body): for(t <- getTrees(body)) statements += <unsetRec(t),t.src>;
		case \constructor(_,_,_,Statement body): for(t <- getTrees(body)) statements += <unsetRec(t),t.src>;
	}
	
	return statements;
}

list[Statement] getTrees(Statement s)
{
	stmts = [];
	visit(s)
	{
		case Statement stmt: stmts += stmt;
	}
	return stmts;
}
