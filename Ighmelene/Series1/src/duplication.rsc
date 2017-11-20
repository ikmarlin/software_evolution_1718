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
		ls	= removeMultipleWhitespaces(ls);
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
		clean += l;
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

rel[loc,int,int,list[str]] fileToBlocks(loc file, int blockSize)
{
	blocks	= {};
	lines 	= cleanFile(file);	
	maxI		= size(lines) - blockSize;
	
	if(maxI < 0) return blocks;
	
	for(i <- [0..maxI])
	{
		block	 = slice(lines,i,blockSize);  
		blocks	+= <file,i,blockSize,block>;
	}
	return blocks;
}

rel[loc,int,int] getDuplicateLines(rel[loc,int,int,list[str]] blocks)
{
	lines	= [block | <file,line,blockSize,block> <- blocks];
	dist		= distribution(lines);
	dupLines	= {};
	for(<file,line,blockSize,block> <- blocks)
	{
		nrDuplicates = dist[block];
		if(nrDuplicates > 1)
		{
			for(l <- [line..line + blockSize])
			{
				for(frequency <- [2..nrDuplicates + 1])
				{
					dupLines += <file,frequency,l>;
				}
			}
		}
	}
	return dupLines;
}

list[list[str]] getDuplicateBlocks(rel[loc,int,int] duplicates, int minBlockSize)
{
	bool first 						= true;
	int blockSize 					= 0;
	list[tuple[loc,int,int]] keys	= [];
	list[list[str]] blocks			= [];
	loc lastFile;
	<lastFreq,lastLine,firstLine> = <-1,-1,-1>;
	for(<file,freq,line> <- sort(duplicates))
	{
		if(first) <lastFile,lastFreq,lastLine,firstLine> = <file,freq,line,line>;
		if((lastLine + 1 == line || lastLine == line) && lastFile == file)
		{
			blockSize += 1;
		}
		else
		{
			if(blockSize >= minBlockSize) 
			{
				tuple[loc,int,int] key = <lastFile,firstLine,blockSize>;
				if(key notin keys)
				{
					keys		+= key;
					blocks	+= [getFileSlice(lastFile,firstLine,blockSize)];
				}
			}
			<firstLine,blockSize> = <line,1>;
		}
		<lastFile,lastFreq,lastLine> = <file,freq,line>;
		first = false;
	}
	return dup(blocks);
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

rel[loc,int,int,list[str]] projectToBlocks(M3 m, int blockSize)
{
	blocks = {};
	for(file <- sort(files(m)))
	{
		blocks += fileToBlocks(file,blockSize);
	}
	return blocks;
}

int getDuplication(M3 m, int blockSize)
{
	project		= projectToList(m);
	strProj 		= intercalate("\n",project);
	projVol		= size(project);
	blocks		= projectToBlocks(m,blockSize);
	dupLines		= getDuplicateLines(blocks);
	dupBlocks	= getDuplicateBlocks(dupLines,blockSize);
	dupVol		= 0;
	for(block <- sort(dupBlocks,sortBlocks))
	{
		strBlock	= intercalate("\n", block);
		parts	= split(strBlock,strProj);
		nrDups	= size(parts) - 2;
		if(nrDups > 1)
		{
			dupSize	 = size(block);
			dupVol	+= (dupSize * nrDups);
			strProj	 = intercalate("\n",parts);
			//println("<dupSize> line block duplicated <nrDups> time(s).");
		}
	}
	//println("<left("duplicate volume:",20," ")> <right("<dupVol>",6," ")>");
	//println("<left("total volume:",20," ")> <right("<projVol>",6," ")>");
	//println("<left("duplication:",20," ")> <right("<perc>",5," ")>%");
	return percent(dupVol,projVol);
}

list[str] getFileSlice(loc f, int i, int length)
{
	ls	= cleanFile(f);
	return slice(ls,i,length);
}

bool sortBlocks(list[str] a, list[str] b) = size(a) > size(b);