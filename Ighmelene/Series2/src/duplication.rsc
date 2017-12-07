module duplication

import IO;
import List;
import String;
import Map;
import Set;
import Relation;
import util::Math;
import lang::java::m3::Core;
import main;

public map[loc,list[str]] cleanFiles = ();
alias Block = list[str];
 
list[str] cleanFile(loc f)
{
	if(f notin cleanFiles)
	{
		ls	= readFileLines(f);
		ls 	= [trim(l) | l <- ls];
		ls -= getBlankLines(ls);
		ls -= getMLComments(ls);
		ls -= getSLComments(ls);
		ls	= removeAccolades(ls);
		ls -= getBlankLines(ls);
		//ls	= removeMultipleWhitespaces(ls);
		cleanFiles[f] = ls;
	}
	return cleanFiles[f];
}

list[str] removeAccolades(list[str] lines)
{
	clean = [];
	for(l <- lines)
	{
		l = replaceAll(l,"{"," ");
		l = replaceAll(l,"}"," ");
		clean += trim(l);
	}
	return clean;
}

list[str] removeMultipleWhitespaces(list[str] lines)
{
	clean = [];
	for(line <- lines)
	{
		cleanLine = "";
		while (/^<before:\S*><ws:\s+><after:.*$>/ := line)
		{ 
			cleanLine += before + " ";
			line = after;
		}
		cleanLine += line;
		clean += trim(cleanLine);
	}
	return clean;
}

rel[loc,int,int,Block] fileToBlocks(loc file, int blockSize)
{
	blocks	= {};
	lines 	= cleanFile(file);	
	maxI		= size(lines) - blockSize;
	
	if(maxI < 0) return blocks;
	
	for(i <- [0..maxI+1])
	{
		block	 = slice(lines,i,blockSize);  
		blocks	+= <file,i,blockSize,block>;
	}
	return blocks;
}

list[str] projectToList(M3 m)
{
	project = [];
	for(file <- sort(files(m)))
	{
		project	+= cleanFile(file);
	}
	return project;
}

rel[loc,int,int,Block] projectToBlocks(M3 m, int blockSize)
{
	blocks = {};
	for(file <- sort(files(m)))
	{
		blocks += fileToBlocks(file,blockSize);
	}
	return blocks;
}

rel[loc file,int line] getDuplicateLines(rel[loc,int,int,Block] blocks)
{
	content			= [block | <file,line,blockSize,block> <- blocks];
	frequency		= distribution(content);
	return {*[<file,line + i> | i <- [0..blockSize]] | <file, line, blockSize, block> <- blocks, frequency[block] > 1};
}

Block getFileSlice(loc f, int i, int length)
{
	ls	= cleanFile(f);
	return slice(ls,i,length);
}

void getDuplication2(M3 m, int blockSize)
{
	project		= projectToList(m);
	projVol		= size(project);
	blocks		= projectToBlocks(m,blockSize);
	dupLines		= getDuplicateLines(blocks);
	//dupVol		= size(dupLines);
	//perc			= percent(dupVol,projVol);
	//println("<left("duplicate volume:",20," ")> <right("<dupVol>",6," ")>");
	//println("<left("total volume:",20," ")> <right("<projVol>",6," ")>");
	//println("<left("duplication:",20," ")> <right("<perc>",5," ")>%");
	//return perc;
}
