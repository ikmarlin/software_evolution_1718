module clones::Visualize
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import Prelude;
import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import vis::Figure;
import vis::Render;
import Main;
import clones::Type1;
import clones::Type2;
import clones::Tools;

void drawTest() {
	b1 = box(hshrink(0.5), fillColor("Red"), left());
	b2 = box(hshrink(1.0),fillColor("Blue"));
	render(vcat([b1, b2]));
}

//map[str, lrel[loc, int, bool]] storage = ();
void draw(loc project) {
	//run1(project);
	i = hcat([cloneClassFigure(key) | key <- storage], top());
	sc = hscreen(i,id("screen"));
	render(sc);
}



void cloneClassFigure(str text) {
	textLabel = text;
	cFigure = LocsFigure(storage[text]);
	return grid([[cFigure], [textLabel]],top());
}



Figure LocsFigure(lrel[loc, int, bool] clones) {
	figures = [];
	for(c <- clones) {
		myBox = box(
					text("clone", fontSize(10)),
					resizable(true, false),
					hint("<c[0]>"));
		figures += myBox;
	}
	i = vcat(figures,top());
	sc = vscreen(i, vshrink(0.2));
	return sc;
}
