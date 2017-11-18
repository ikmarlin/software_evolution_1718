module metrics::duplication

import IO;
import List;
import String;
import Map;
import util::Math;
import lang::java::m3::Core;


list[str] cleanFile(loc f){
	clean = [];
	lines = [trim(l) | l <- readFileLines(f), ! /^\s*$/ := l];
	lines = [l | l <- lines, ! /^[\{\}]+$/ := l];
	for(line <- lines){
		line = replaceAll(line, "{", " ");
		line = replaceAll(line, "}", " ");
		cleanLine = "";
		while (/^<before:\S*><ws:\s+><after:.*$>/ := line){ 
			cleanLine += before + " ";
			line = after;
		}
		cleanLine += line;
		clean += trim(cleanLine);
	}
	return clean;
}

list[str] fileToBlocks(list[str] lines, int n){
	blocks	= [];
	maxI		= size(lines) - n - 1;
	for(i <- [0..maxI]){
		blocks  += intercalate(" ",slice(lines,i,n));
	}
	return blocks;
}

rel[str,int] duplicates(list[str] lines){
	freqs	= toRel(distribution(lines));
	return {<block,freq-1> | <block,freq> <- freqs, freq > 1};
}

void getFileDupPercentage(loc f,int blockSize){
	clean 	= cleanFile(f);
	blocks 	= fileToBlocks(clean,blockSize);
	dups		= duplicates(blocks);
	volume	= (0 | it + size(line) | line <- clean);
	dupVol	= (0 | it + (size(block) * freq) | <block,freq> <- dups);
	perc		= percent(dupVol,volume);
	println("<dupVol>:<volume> = <perc>%");
}

void getDuplication(M3 m){
	project = [*cleanFile(l) | l <- files(m)];
	dups		= duplicates(project);
	projVol	= (0 | it + size(line) | line <- project);
	dupVol	= (0 | it + (size(block) * freq) | <block,freq> <- dups);
	perc		= percent(dupVol,projVol);
	println("<dupVol>:<projVol> = <perc>%");
}