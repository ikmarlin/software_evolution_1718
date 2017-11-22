module testcoverage

import main;
import duplication;
import IO;
import String;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

public loc f1 = |project://smallsql0.21_src/src/smallsql/junit/BasicTestCase.java|;
public loc f2 = |project://smallsql0.21_src/src/smallsql/junit/TestDBMetaData.java|;
void testing(loc file)
{
	ast = getFileAst(file);
	visit(ast)
	{
		case \methodCall(_, "assertTrue",	list[Expression] arguments): println("assertTrue");
		case \methodCall(_, "assertFalse",	list[Expression] arguments): println("assertFalse");
		case \methodCall(_, "assertEquals",	list[Expression] arguments): println("assertEquals");
	}
}

public map[loc,int] getUnitTests(M3 m)
{
	map[loc,int] ccs = ();
	for(l <- files(m))
	{
		ccs += getUnitTests(l);
	}
	return ccs;
}

public map[loc,int] getUnitTests(loc l)
{
	return getUnitTests(getFileAst(l));
}

public map[loc,int] getUnitTests(Declaration file)
{
	map[loc,int] ccs = ();
	for(meth <- [d | /Declaration d := file, isMethod(d.decl), isUnitTest(d)])
	{
		ccs[meth.src] = getNrAsserts(meth);
	}
	return ccs;
}

public int getNrAsserts(Declaration d)
{
	//if(d.src notin unitCCs)
	//{
		cc = 0;
		visit (d)
		{
			case \methodCall(_, str name,	list[Expression] arguments):
			{
				if(startsWith(name,"assert")) cc += 1;
			}
		}
		//unitCCs[d.src] = cc;
	//}
	//return unitCCs[d.src];
	return cc;
}

public bool isUnitTest(Declaration meth)
{
	return getNrAsserts(meth) > 0;
}

