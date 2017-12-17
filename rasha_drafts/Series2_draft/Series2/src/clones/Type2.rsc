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

/* main method to detect & store clone classes in java project */
void run2(loc project) {
	println("Type2");
	storage = ();
	cloneClasses = ();
    set[Declaration] asts = createAstsFromEclipseProject(project, true);
    getCloneClassesType2(asts);
	println("Storage size = <size(storage)>");
}

/* gets clone classs from ast and post process them to get rid of subsumptions*/
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


// normalize subtree for type2, variables names, times and identifiers not to be compared */
node convert(node subtree) {
	return visit(subtree){
    	case \simpleName(_) => \simpleName("simple") // skip details
    	case \variable(_,ext) => \variable("var",ext) // var name is not important
	    case \variable(_,ext,i) => \variable("var",ext,i) // var name is not important
		//case \variables(t,frgs) => variables(t,frgs) // no need, type will go in last branch
		case \method(t,_,ps,es,impl) => \method(t,"unit",ps,es,impl) // we don't care about type & name
		case \method(t,_,list[Declaration] ps,list[Expression] es) => \method(t,"unit",ps,es) // we don't care about type & name
   		case \parameter(t, _,ext) => \parameter(t,"parameter",ext)
   		case Modifier _ => \private()
   		case Type _ => wildcard() // will catch all types including the ones in subtrees above and normalize them!
	}
}


