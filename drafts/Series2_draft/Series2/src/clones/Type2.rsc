module clones::Type2
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Type;
import Prelude;
import Node;
import Main;
import clones::Type1;


void run2(loc project) {
	println("Type2");
	storage = ();
	cloneClasses = ();
    set[Declaration] asts = createAstsFromEclipseProject(project, true);
    getCloneClassesType2(asts);
	println("Storage size = <size(storage)>");
}

void getCloneClassesType2(set[Declaration] asts) {
	// get initial classes
	getInitialCloneClassesType2(asts);
	// get rid of strictly included classes
	postProcessCloneClasses();
}

void getInitialCloneClassesType2(set[Declaration] asts) {
    visit (asts) {
        case node n: storeSubtreeWithLoc(convert(n)); //convert each subtree first
    }
    for (key <- storage) {
		// at least duplicated once
        if (size(storage[key]) >= 2) {
            cloneClasses[key] = dup(storage[key]);
        }
    }
   	println("clone classes before taking out strictly included clone classes = <size(cloneClasses)>");
}


// skip leaves details
node convert(node subtree) {
	return visit(subtree) {
	    case \variable(str name,int ext) => \variable("var",ext) // var name is not important
	    case \variable(str name,int ext,Expression i) => \variable("var",ext,i) // var name is not important
    	case \simpleName(_) => \simpleName("simple") // skip details
    	case \stringLiteral(_) => \stringLiteral("str") // skip strval
    	case \characterLiteral(_) => characterLiteral("char") // skip charval
    	case \booleanLiteral(_) => \booleanLiteral(true) // skip boolval
    	case \number(_) => \number("0") // skip val
		case \method(Type t,str n,list[Declaration] ps,list[Expression] es, Statement impl) => \method(t,"unit",ps,es,impl)
		case \method(Type t,str n,list[Declaration] ps,list[Expression] es) => \method(t,"unit",ps,es)
        case \methodCall(bool isSuper,str name,list[Expression] args) => \methodCall(isSuper,"methodCall",args)
        //case \methodCall(bool isSuper,str name,Expression receiver,list[Expression] args) => \methodCall(isSuper,receiver,"methodCall",args)
		case \fieldAccess(bool isSuper,Expression ex,str name) => \fieldAccess(isSuper,ex,"fieldAccess")
   		case \fieldAccess(bool isSuper,str name) => \fieldAccess(isSuper,"fieldAccess")
   		case \parameter(Type t, _,int ext) => \parameter(t,"parameter",ext)
   		case \vararg(Type t, _) => \vararg(t,"vararg")
   		case Modifier _ => \private()
   		case Type _ => wildcard()
	}
}
