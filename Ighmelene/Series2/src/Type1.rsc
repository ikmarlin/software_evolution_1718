module Type1

import IO;
import List;
import String;
import Map;
import Set;
import Relation;
import util::Math;
import lang::java::m3::Core;
import main;
import duplication;

public map[loc,list[str]] cleanFiles = ();
alias Block = list[str];
alias Clone = tuple[Block block,loc file,int line,int size,int freq];
 
list[str] cleanFile1(loc f)
{
	if(f notin cleanFiles)
	{
		ls	= readFileLines(f);
		ls 	= [trim(l) | l <- ls];
		ls -= getBlankLines(ls);
		ls -= getMLComments(ls);
		ls -= getSLComments(ls);
		ls -= getPackages(ls);
		ls -= getImports(ls);
		ls	= removeAccolades(ls);
		ls -= getBlankLines(ls);
		//ls	= removeMultipleWhitespaces(ls);
		cleanFiles[f] = ls;
	}
	return cleanFiles[f];
}

list[str] getPackages(list[str] lines)
{
	matches = [];
	for(line <- lines)
	{
		if(startsWith(trim(line),"package")) matches += line;
	}
	return matches;
}

list[str] getImports(list[str] lines)
{
	matches = [];
	for(line <- lines)
	{
		if(startsWith(trim(line),"import")) matches += line;
	}
	return matches;
}

list[str] projectToList1(M3 m)
{
	project = [];
	for(file <- sort(files(m)))
	{
		project	+= cleanFile1(file);
	}
	return project;
}

set[Clone] getCloneClasses(M3 m, int blockSize)
{
	project		= projectToList1(m);
	projVol		= size(project);
	projStr		= intercalate("\n",project);
	blocks		= [];
	dupVol		= 0;
	firstClass	= true;
	ls 			= {};
	
	set[Clone] cloneClasses	= {};
	Clone lastClass;
	
	for(file <- sort(files(m)))
	//for(file <- files(m))
	{
		lines 	= cleanFile1(file);	
		//println();
		//println("cleaned file: <file>\n");
		//for(l <- [0..size(lines)]) println("  <right("<l>",2," ")> <lines[l]>");
		//println("\nclone classes:\n");
		fileSize	= size(lines);
		maxStart	= fileSize - blockSize;
		lastSize	= 0;
		freq		= 0;
		
		
		if(maxStart >= 0)
		{
			for(i <- [0..maxStart+1])
			{
				block	= slice(lines,i,blockSize);
				strBlock	= intercalate("\n",block);
				dups	    = findAll(projStr,strBlock);
				freq		= size(dups);
				newSize	= blockSize;
				
				<lastBlock,lastSize,lastFreq> = <block,blockSize,freq>;
				
				while(freq > 1)
				{
					<lastBlock,lastSize,lastFreq> = <block,size(block),size(dups)>;
					newSize += 1;
					if(i + newSize <= fileSize)
					{
						block	= slice(lines,i,newSize);
						strBlock	= intercalate("\n",block);
						dups	    = findAll(projStr,strBlock);
						freq		= size(dups);
					}
					else freq = 0;
				}
				
				if(lastFreq > 1)
				{
					Clone currClass	= <lastBlock,file,i,lastSize,lastFreq>;
					addClass		= false;
					
					if(firstClass)
					{
						lastClass	= currClass;
						firstClass	= false;
						addClass		= true;
					}
					
					if(lastClass.file != file)
					{
						addClass = true;
					}
					else
					{
						if(!subsumes(lastClass,currClass)) addClass = true;
					}
					
					if(addClass)
					{
						//println("  lines: <i>..<i+lastSize - 1>, duplicates: <lastFreq>");
						cloneClasses	+= currClass;
						lastClass	 = currClass;
						ls += getCloneLines(currClass);
					}
				}
			}
		}
	}
	
	dupVol	= size(ls);
	perc		= percent(dupVol,projVol);
	
	//println();
	println("<left("duplicate volume:",20," ")> <right("<dupVol>",6," ")>");
	println("<left("total volume:",20," ")> <right("<projVol>",6," ")>");
	println("<left("duplication:",20," ")> <right("<perc>",5," ")>%");
	println();
	
	return cloneClasses;
}

rel[loc,int] getCloneLines(Clone clone) = {<clone.file,l> | l <- [clone.line..clone.line + clone.size]};

bool subsumes(Clone a, Clone b)
{
	subsumed		= true;
	lastLines	= getCloneLines(a);
	currLines	= getCloneLines(b);
	
	// (not) subsumed
	if(!(currLines <= lastLines))
	{
		subsumed = false;
	}
	else
	{
		if(a.freq < b.freq) subsumed = false;
	}
	
	return subsumed;
}
