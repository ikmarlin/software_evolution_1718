module Vis4

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

/* Main visualizer */
public void visualize2(loc project) {
	run1(project); // default
    set[Declaration] asts = createAstsFromEclipseProject(project, true);
	M3 model = createM3FromEclipseProject(project);
	int vol = getVolume(model);
	fillFiles(asts);
	//selectMenu =  box(dropdownmenu(), width(60), fillColor("white), resizable(true,true));
	
	menuBox = box(getMenuFigure());
	welcome = box(text("Welcome to series2 - Clone detection",  fontBold(true), fontSize(10)), fillColor("green"));
	guide = box(text("Run on one of the projects"));
	//compute = computeFigure(reruntype1, getFigure, [grow(1)]);
	
	Figure topScreen = box(hcat([(welcome), guide]), height(60), resizable(true, false));	
	render("Welcome to series2 - Clone detection", (vcat([topScreen, menuBox/*,compute*/])));
	
	
	render(box(
				vcat([
					box(text("Welcome to series2 - Clone detection", fontSize(10)), fontBold(true), fillColor("white")),
					box(text( "Volume after global clean up: <vol> \t\t\t\t\tClone classes: <size(cloneClasses)>",fontBold(true),left()),vshrink(0.05)),
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
	int count = 0;
	for (file <- filesMap) {
		markers = [];
		for (key <- cloneClasses ) {
			for (c <- cloneClasses[key] ) {
				if (file == |<c[0].scheme>://<c[0].authority><c[0].path>|) {
					beginline = c[0].begin.line;
					endline   = c[0].end.line;
					for (l <- [beginline+1..endline-1] ) {
						markers += info(l,key);
					}
				};
			}
		}
		if (size(markers)>0) {
			properties += outline(markers, filesMap[file], size(70,200), fileLoc("<file.file>"));
		} 	
	}
	return box(hcat(properties), fillColor("red"));
}



FProperty fileLoc(str s){
	return { 
		onMouseOver(box(text(s), fillColor("red"), grow(0.2), resizable(false)));
  	}
}


void fillFiles(set[Declaration] asts) {
	int totalLines = 0;
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
}
