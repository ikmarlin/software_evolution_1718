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
}


// normalize subtree
node convert(node subtree) {
	return visit(subtree){
    	case \simpleName(_) => \simpleName("simple") // skip details
    	case \variable(_,ext) => \variable("var",ext) // var name is not important
	    case \variable(_,ext,i) => \variable("var",ext,i) // var name is not important
		case \variables(t,frgs) => variables(t,frgs)
		case \method(t,_,ps,es,impl) => \method(t,"unit",ps,es,impl) // we don't care about type & name
		case \method(t,_,list[Declaration] ps,list[Expression] es) => \method(t,"unit",ps,es) // we don't care about type & name
   		case \parameter(t, _,ext) => \parameter(t,"parameter",ext)
   		case Modifier _ => \private()
   		case Type _ => wildcard()
	}
}

/* obsolete code, it takes more than what the definition points to - probably as a second demo!
node convert(node subtree) {
	return visit(subtree) {
	    case \variable(_,ext) => \variable("var",ext) // var name is not important
	    case \variable(_,ext,i) => \variable("var",ext,i) // var name is not important
    	case \simpleName(_) => \simpleName("simple") // skip details
    	case \stringLiteral(_) => \stringLiteral("str") // skip strval
    	case \characterLiteral(_) => characterLiteral("char") // skip charval
    	case \booleanLiteral(_) => \booleanLiteral(true) // skip boolval
    	case \number(_) => \number("0") // skip val
    	//case \annotationTypeMember(type,_) => \annotationTypeMember(type,"annotatedTypeMember")
    	//case \annotationTypeMember(type,_,_) => \annotationTypeMember(type,"annotatedTypeMember"))
		case \method(t,_,ps,es,impl) => \method(t,"unit",ps,es,impl)
		//case \method(t,_,ps,es) => \method(t,"unit",ps,es)
		case \method(Type t,str _,list[Declaration] ps,list[Expression] es) => \method(t,"unit",ps,es)
        case \methodCall(isSuper,_,args) => \methodCall(isSuper,"methodCall",args)
        case \methodCall(isSuper,receiver,_,arg) => \methodCall(isSuper,receiver,"methodCall",arg)
		case \constructor(_,ps,exc, imp) => \constructor("constructor",ps,exc,imp)
		case \fieldAccess(isSuper,ex,_) => \fieldAccess(isSuper,ex,"fieldAccess")
   		case \fieldAccess(isSuper,_) => \fieldAccess(isSuper,"fieldAccess")
   		case \parameter(t, _,ext) => \parameter(t,"parameter",ext)
   		case \vararg(t, _) => \vararg(t,"vararg")
   		case \interface(_,ext,imp,b) => \interface("interface",ext,imp,b)
		case \class(_,ext,imp,b) => \class("class",ext,imp,b)
   		case Modifier _ => \private()
   		case Type _ => wildcard()
	}
}*/

