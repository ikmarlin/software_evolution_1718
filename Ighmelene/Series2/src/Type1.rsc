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
 
list[str] cleanFile(loc f)
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

rel[Block b, loc f, int l, int s, int d] getCloneClasses(M3 m, int blockSize)
{
	project		= projectToList(m);
	projVol		= size(project);
	projStr		= intercalate("\n",project);
	blocks		= [];
	dupVol		= 0;
	firstClass	= true;
	cloneClasses	= {};
	ls 			= {};
	
	tuple[Block block, loc file, int line, int size, int frequency] lastClass;
	
	for(file <- sort(files(m)))
	//for(file <- files(m))
	{
		lines 	= cleanFile(file);	
		println();
		println("cleaned file: <file>\n");
		for(l <- [0..size(lines)]) println("  <right("<l>",2," ")> <lines[l]>");
		println("\nclone classes:\n");
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
					tuple[Block block, loc file, int line, int size, int frequency] currClass	= <lastBlock,file,i,lastSize,lastFreq>;
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
						lastLines = [lastClass.line..lastClass.line + lastClass.size];
						currLines = [i..i + lastSize];
						
						// (not) subsumed
						if(!(currLines <= lastLines))
						{
							addClass = true;
						}
						else
						{
							if(lastClass.frequency < lastFreq) addClass = true;
						}
					}
					
					if(addClass)
					{
						println("  lines: <i>..<i+lastSize - 1>, duplicates: <lastFreq>");
						cloneClasses	+= currClass;
						lastClass	 = currClass;
					}
				}
			}
		}
	}
	
	println("\n----------------------------------------\n");
	for(<b,f,l,s,d> <- cloneClasses)
	{
		ls += {<f,i> | i <- [l..l+s]};
	}
	dupVol	= size(ls);
	perc		= percent(dupVol,projVol);
	println("<left("duplicate volume:",20," ")> <right("<dupVol>",6," ")>");
	println("<left("total volume:",20," ")> <right("<projVol>",6," ")>");
	println("<left("duplication:",20," ")> <right("<perc>",5," ")>%");
	println("\n----------------------------------------\n");
	
	for(b <- dup(sort(domain(cloneClasses))))
	{
		println(b);
		println();
		for(<f,l,s,d> <- sort(cloneClasses[b]))
		{
			println("  \<<f.file>,<l>,<s>,<d>\>");
		}
		println();
	}
	println("\n----------------------------------------\n");
	
	return cloneClasses;
}
