module Vis4
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
import clones::Tools;

loc selectedProj = toLocation("");
map[loc, int] filesMap = ();
bool rerun1 = false;

lrel[loc, int, bool] biggestClone;

/* calculate volume based on files in java project */
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

int getVolume(M3 model)   = (0 | it + countLoc(f) | f <- files(model));

int getBiggerClone() {
	int max = 0;
	for (key <- cloneClasses) {
		for (c <- cloneClasses[key]) {
			if (max < c[1]) {
				max = c[1];
				biggestClone = cloneClasses[key];
			}
		}
	}
	return max;
}

/* Main visualizer */
public void visualize2(loc project) {
	run1(project); // default
    set[Declaration] asts = createAstsFromEclipseProject(project, true);
	M3 model = createM3FromEclipseProject(project);
	int vol = getVolume(model);
	int max =  getBiggerClone();
	fillFiles(asts);
	//selectMenu =  box(dropdownmenu(), width(60), fillColor("white), resizable(true,true));
	
	menuBox = box(getMenuFigure());
	welcome = box(text("Welcome to series2 - Clone detection",  fontBold(true), fontSize(10)), fillColor("green"));
	guide = box(text("Run on one of the projects"));
	//compute = computeFigure(reruntype1, getFigure, [grow(1)]);
	
	Figure topScreen = box(hcat([(welcome), guide]), height(60), resizable(true, false));	
	render("Welcome to series2 - Clone detection", (vcat([topScreen, menuBox/*,compute*/])));
	
	
	render("Welcome to series2 - Clone detection", (hcat(getFigures())));
	render(box(
				vcat([
					box(text("Welcome to series2 - Clone detection", fontSize(10)), fontBold(true), fillColor("white")),
					box(text("Volume after global clean up: <vol> \t\t\t\tDuplication percentage: <vol>\t\t\t\t Clone classes: <size(cloneClasses)>",fontBold(true),left()),vshrink(0.05)),
					box(text("Largest detected clone & size: <biggestClone> \t\t\t<max>",fontBold(true),left()),vshrink(0.05)),
					//computeFigure(reruntype1, headerFigure, [grow(1)]),
					computeFigure(reruntype1, getFigure, [grow(1)])
				])
			)
	);
}


bool reruntype1() {
	if (rerun1) {
		rerun1 = false;
		return true;
	} 
	return false;
}


Figure getFigure() {
	properties = [];
	M3 model = createM3FromEclipseProject(selectedProj);
	str lines;
	//str fileName = "";
	for (file <- filesMap) {
		markers = [];
		for (key <- cloneClasses ) {
			lines = "";
			//fileName = "";
			for (c <- cloneClasses[key] ) {
				if (file == |<c[0].scheme>://<c[0].authority><c[0].path>|) {
					b = c[0].begin.line;
					e = c[0].end.line;
					//println(<c[0].begin.text>);
					for (l <- [b+1..e-1] ) {
						markers += info(l,key);
						lines = getLines(c[0]);
						//fileName = c[0].file;
					}
				};
			}
		}
		if (size(markers)>0) {
			//properties += text(fileName);
			properties += outline(markers, filesMap[file], size(70,200), message("<file.file>"), message("<lines>"));
		}
	}
	return box(	hcat(properties), fillColor("white"));
}

str getLines(loc f) {
	str ll = "";
	list[str] ls = readFileLines(f);
	for (l <-ls) {
		ll +=l;
	}
	return ll;
}


Figure headerFigure() {
	M3 model = createM3FromEclipseProject(selectedProj);
	properties = [];
	str fileName;
	for (file <- filesMap) {
		fileName = "";
		markers = [];
		for (key <- cloneClasses ) {
			for (c <- cloneClasses[key] ) {
				if (file == |<c[0].scheme>://<c[0].authority><c[0].path>|) {
					fileName = file.file;
				};
			}
		}
		properties += text(fileName);
	}
	return box(hcat(properties), fontSize(3), fillColor("white"));
}




FProperty message(str s){
	return { 
		onMouseOver(box(text(s), fillColor("white"), grow(0.2), resizable(false)));
  	}
}


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
	

Figure getMenuFigure() {
	return vcat([
				combo(["sample1","sample2","small","hs"], void(str s){ getSelectedProject(s);}, hsize(200), resizable(false, false)),
				button("Visualize classes", void() {
				run1(selectedProj);
				visualize2(selectedProj);
				}, hsize(100), hgap(25), resizable(false, false))
				], resizable(false, false));
}

void getSelectedProject(str s) {
	if (s == "small")
		selectedProj = smallsql;
	else if (s == "hs")
		selectedProj = hsqldb;
	/*else if (s == "sample1")
		selectedProj = sample1;
	else if (s == "sample2")
		selectedProj = sample2;*/
}



list[Figure] getFigures() {
	figureList = [];
	str lines;
	for (file <- filesMap) {
		markers = [];
		for (key <- cloneClasses ) {
			lines = "";
			for (c <- cloneClasses[key] ) {
				if (file == |<c[0].scheme>://<c[0].authority><c[0].path>|) {
					b = c[0].begin.line;
					e = c[0].end.line;
					for (l <- [b+1..e-1] ) {
						markers += info(l,key);
						lines = getLines(c[0]);
						
					}
				};
				figureList += getCloneBox(c[0]);
			}
		}
	}
	return figureList;
}

Figure getCloneBox(loc f){
	fileName = f.file;
	cloneBox = box(
					text("<fileName>", fontSize(10)),
					resizable(true, false),	
					//hint("<f.file>"),
					onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers)	{
						edit(f);
						return true;
					}
				));
	return cloneBox;
}
