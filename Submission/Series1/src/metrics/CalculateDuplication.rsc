module metrics::CalculateDuplication
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import String;
import List;
import Set;
import Relation;
import Map;
import util::Math;
import util::FileSystem;
import lang::java::jdt::m3::Core;
import Main;
import Extractor;
import utils::Tools;
import metrics::SigModelScale;

/* We need to calculate the total-count lines of code, and the total-count of duplicated lines of code.
	rank 	duplication
	####################
	++ 		0-3%
	+ 		3-5%
	o 		5-10%
	- 		10-20%
	-- 		20-100%
*/

public map[loc,list[str]] cleanFiles = ();
alias Block = list[str];

/* clean up a file from blank lines, all kinds of comments */
list[str] cleanFile(loc f) {
	if(f notin cleanFiles) 	{
		ls	= readFileLines(f);
		ls 	= [trim(l) | l <- ls];
		ls -= getBlankLines(ls);
		ls -= getMLComments(ls);
		ls -= getSLComments(ls);
		ls	= removeAccolades(ls);
		ls -= getBlankLines(ls);
		ls	= removeMultipleWhitespaces(ls);
		cleanFiles[f] = ls;
	}
	return cleanFiles[f];
}

/* extract blocks of n lines from a file */
rel[loc,int,int,Block] fileToBlocks(loc file, int blockSize) {
	blocks	= {};
	Block lines = cleanFile(file);	
	maxI		= size(lines) - blockSize;
	
	if(maxI < 0) return blocks;
	
	for(i <- [0..maxI+1]) {
		Block block	 = slice(lines,i,blockSize);  
		blocks		+= <file,i,blockSize,block>;
	}
	return blocks;
}



/* get duplicated lines from the blocks */
rel[loc file,int line] getDuplicateLines(rel[loc,int,int,Block] blocks) {
	content			= [block | <file,line,blockSize,block> <- blocks];
	frequency		= distribution(content);
	return {*[<file,line + i> | i <- [0..blockSize]] | <file, line, blockSize, block> <- blocks, frequency[block] > 1};
}

/* clean and slice file into list of strings*/
Block getFileSlice(loc f, int i, int length) {
	ls	= cleanFile(f);
	return slice(ls,i,length);
}

int getDuplication(M3 m, int blockSize) {
	project		= projectToList(m);
	projVol		= size(project);
	blocks		= projectToBlocks(m,blockSize);
	dupLines	= getDuplicateLines(blocks);
	dupVol		= size(dupLines);
	perc		= percent(dupVol,projVol);
	//println("<left("duplicate volume:",20," ")> <right("<dupVol>",6," ")>");
	//println("<left("total volume:",20," ")> <right("<projVol>",6," ")>");
	//println("<left("duplication:",20," ")> <right("<perc>",5," ")>%");
	return perc;
}

/*  get sig-model rankining based on the duplicates ratio */
public int getDuplicationRating(int ratio) {
	if(ratio <=3) return sigScales[0]; // ++
	if(ratio <=5)return sigScales[1]; // +
	if(ratio <=10) return sigScales[2]; // o
	if(ratio <=20) return sigScales[3]; // -
	return sigScales[4]; // --
}

rel[loc,int,int,Block] projectToBlocks(M3 m, int blockSize) {
	blocks = {};
	for(file <- sort(files(m)))	{
		blocks += fileToBlocks(file,blockSize);
	}
	return blocks;
}

list[str] projectToList(M3 m) {
	project = [];
	for(file <- sort(files(m))) {
		project	+= cleanFile(file);
	}
	return project;
}
