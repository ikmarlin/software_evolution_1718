module Visualization
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import vis::Figure;
import vis::Render; 
import vis::KeySym;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import util::Editors;
import util::Editors;
import demo::common::Crawl;
import Main;
import clones::Type1;
import clones::Type2;
import clones::Tools;

loc selectedProj = toLocation("");
lrel[loc, int] biggestClone;
str biggestCloneClassKey;
str biggestCloneKey;
map[loc, int] filesMap = ();
bool rerun1 = false;


/* Main visualizer */
public void visualize(bool run) {
	menuBox = box(getMenuFigure());
	welcome = box(text("Welcome to series2 - Clone detection tool type 1 & 2",  fontBold(true), fontSize(12)), fillColor("azure"));
	//guide   = box(text("Please select one of the following project:"));
	Figure topScreen = box(hcat([welcome]), height(30), width(150), resizable(false, false));	
	
	if (selectedProj != toLocation("") && run == true){ // run needed with project selected
		set[Declaration] asts = createAstsFromEclipseProject(selectedProj, true);
		M3 model = createM3FromEclipseProject(selectedProj);
		int vol = getVolume(model);
		int clonesVolume = getVolumeClones();
		int biggestCloneSize = getBiggerClone();
		int biggestCloneClassSize = getBiggestCloneClass();
		fillFiles(asts);
		
		// render clones per file
		fileClones = box(
				vcat([
					box(text("Clone detection - clones per java file", fontSize(20)), fontBold(true), fillColor("white")),
					box(text("Volume after global clean up: <vol> \t\t\t\tDuplication size: <clonesVolume>\t\t\t\t Clone classes: <size(cloneClasses)>",fontBold(true),left()),vshrink(0.05)),
					box(text("Biggest clone class size: <biggestCloneClassSize>",fontBold(true),left()),vshrink(0.05)),
					box(text("Biggest clone size: <biggestCloneSize>",fontBold(true),left()),vshrink(0.05)),
					computeFigure(reruntype1, getFigure, [grow(0.5)])
				])
			);
		
		mainPage = box(button("Main page", void(){visualize(false);},hsize(130), hgap(25), resizable(false, false)), size(20), fillColor("white"), resizable(false,true));
		mainPageBox = box(hcat([mainPage]), height(30), resizable(true, false));
		render("Clones per file view", vcat([mainPageBox, fileClones]));
		
		// render clone classes, each box has all boxes of clones in that class
		panel = box(text("Clone classes view", fontSize(20)), height(10),fillColor("azure"));
		render("Clone classes view", vcat([mainPageBox, panel, hcat(getFigures(), gap(10))]));
		
		// render biggest clone class
		box1 = box(text("Biggest clone class", fontSize(20)), fontBold(true), fillColor("white"));
		box2 = getCloneClassBox(biggestCloneClassKey);
		largestCloneClassBox = hcat([box1, box2],height(30), shrink(0.3), resizable(false, false));
		render("Biggest clone class", largestCloneClassBox);
		
		// render biggest clone 
		box1 = box(text("Biggest clone", fontSize(20)), fontBold(true), fillColor("white"));
		box2 = getCloneClassBox(biggestCloneKey);
		largestCloneBox = hcat([box1, box2],height(30), shrink(0.3), resizable(false, false));
		render("Biggest clone", largestCloneBox);
		
		// render example hasse graph
		getClonesGraph();
		
	} 
	else { // main screen, no run no project selected
		render("Clone detection tool", vcat([topScreen/*, guide*/, menuBox]));
	}
}

/* get main menu figure with buttons on it & actions follow button press */
Figure getMenuFigure() {
	return vcat([
				combo([/*"sample1","sample2",*/"smallsql0.21_src project","hsqldb-2.3.1 project"], void(str s){getSelectedProject(s);}, center(), hsize(300), resizable(false, false)),
				button("Visualize type1", void() {
					run1(selectedProj);
					visualize(true);
				},
				hsize(100), hgap(25), resizable(false, false)),
				button("Visualize type2", void() {
					run2(selectedProj);
					visualize(true);
				}, 
				hsize(100), hgap(25), resizable(false, false))
				], resizable(false, false));
}

/* determine project loc based on selected option in main menu */
void getSelectedProject(str s) {
	if (s == "smallsql0.21_src project")
		selectedProj = smallsql;
	else if (s == "hsqldb-2.3.1 project")
		selectedProj = hsqldb;
	/*else if (s == "sample1")
		selectedProj = sample1;
	else if (s == "sample2")
		selectedProj = sample2;*/
}

/* get clone classes figures */
list[Figure] getFigures() {
	figureList = [];
	for (key <- cloneClasses) {
		figureList += getCloneClassBox(key);
	}
	return figureList;
}

/* get clone figure for clone classes view */
Figure getCloneBox(loc f){
	fileName = f.file;
	cloneBox = box(
					text("<fileName>", fontSize(10)),
					resizable(true, false),
					hint("<f.begin.line> .. <f.end.line>"),
					fillColor("azure"),
					onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers){ // opens clone in the java file
						edit(f);
						return true;
					}
				));
	return cloneBox;
}

/* get clone class view */
Figure getCloneClassBox(str key) {
	list[Figure] boxes = [];
	for (c <- cloneClasses[key]) {
		fileName = |<c[0].scheme>://<c[0].authority><c[0].path>|.file;
		cloneBox = getCloneBox(c[0]); // get clone box in that class
		boxes += cloneBox; // add box to other boxes
	}
	return box(vcat(boxes)); // form box by stacking clones boxes vertically
}


/* get size of biggest cloned code */
int getBiggerClone() {
	int max = 0;
	for (key <- cloneClasses) {
		for (c <- cloneClasses[key]) {
			if (max < c[1]) {
				max = c[1];
				biggestClone = cloneClasses[key];
				biggestCloneKey = key;
			}
		}
	}
	return max;
}

/* get biggest clone class (in term of number of locations */
int getBiggestCloneClass() {
	int max = 0;
	int count;
	for (key <- cloneClasses) {
		count = 0;
		for (c <- cloneClasses[key]) {
			count += 1;
		}
		if (count > max) {
			max = count;
			biggestCloneClassKey = key;
		}
	}
	return max;
}


/* get clones per file figures */
Figure getFigure() {
	properties = [];
	M3 model = createM3FromEclipseProject(selectedProj);
	str lines;
	int max = 0;
	map[loc,str] cloneLinesPerFile = ();
	for (file <- filesMap) {
		markers = [];
		for (key <- cloneClasses ) {
			lines = "";
			for (c <- cloneClasses[key] ) {
				if (file == |<c[0].scheme>://<c[0].authority><c[0].path>|) {
					b = c[0].begin.line;
					e = c[0].end.line;
					lines = getLines(c[0]);
					if (max < filesMap[file]) 
						max = filesMap[file];
					if(cloneLinesPerFile[file]?) {
						if (!contains(cloneLinesPerFile[file], "<b>..<e>"))
							cloneLinesPerFile[file] += " <b>..<e>,";
					} else {
						cloneLinesPerFile[file] = " <b>..<e>,";
					}
					
					for (l <- [b+1..e-1]) {
						markers += highlight(l,"<b>..<e>\t");
					}
				}
			}
		}
		if (size(markers)>0) {
			properties += outline(markers, filesMap[file], size(20,(2*filesMap[file]*150)/max), message("<file.file>", cloneLinesPerFile[file]));
		}
	}
	return box(hcat(properties), fillColor("azure"));
}

bool reruntype1() { // needed for the computeFigure
	if (rerun1) {
		rerun1 = false;
		return true;
	} 
	return false;
}

str getLines(loc f) { // not used anymore
	str ll = "";
	list[str] ls = readFileLines(f);
	for (l <-ls) {
		ll +=l;
	}
	return ll;
}


/* get message for clones per file */
FProperty message(str s, str ins){
	return { 
		onMouseOver(box(text(s+ins), fillColor("white"), grow(0.2), resizable(false)));
  	}
}

/* fill files map / size per file */
void fillFiles(set[Declaration] asts) {
	filesMap = ();
	
	visit (asts) {
		case Declaration a:
			visit (a) {
				 case \compilationUnit(Declaration _, list[Declaration] _, list[Declaration] _):{
				 	m = a.src;
				 	f = |<m.scheme>://<m.authority><m.path>|;
			 		content =  a.src.end.line;
				 	filesMap[f] = content;
				 }
			}
	}
}


/* calculate loc of a clean java file */
int countLoc(loc f) {
	//cleaning
	ls	= readFileLines(f);
	ls -= getBlankLines(ls);
	ls -= getMLComments(ls);
	ls -= getSLComments(ls);
	ls -= getPackages(ls);
	ls -= getImports(ls);
	ls -= getBlankLines(ls);
	list[str] lines = [];
	for (l <- ls) {
		lines += trim(l);
	}
	return size(lines);
}

/* calculate volume based on files in java project */
int getVolume(M3 model)   = (0 | it + countLoc(f) | f <- files(model));

/* get loc cloned, works for all clone types */
int getVolumeClones() {
	clonesVolume = 0;
	for (key <- cloneClasses) {
		for (c <- cloneClasses[key]) {
				b = c[0].begin.line;
				e = c[0].end.line;
				clonesVolume += (e-b);
			}
		}
	return clonesVolume;
}

void getClonesGraph() {
	nodes = [];
	edges = [];
	int count = 0;
	for(key <- cloneClasses) {
		count += 1;
		set[loc] locs = {};
		for (c <- cloneClasses[key]) {
			locs += c[0];
		}
		for(l <- locs) {
			nodes += box(text("<l.file> <l.begin.line> <l.end.line>"), id("<l.uri><l.begin.line><l.end.line>"),fillColor("azure"),
				onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers){ // opens clone in the java file
				edit(l);
					return true;
					}));
			for(ll <- locs) {
				if(l.file != ll.file) {
					edges +=edge("<l.uri><l.begin.line><l.end.line>", "<ll.uri><ll.begin.line><ll.end.line>");
				}
			}
		}
		//break;
		if (count == 4)
			render(graph(nodes, edges, hint("layered"), gap(20)));
	}
}

