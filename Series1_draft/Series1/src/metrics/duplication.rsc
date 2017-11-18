module metrics::duplication

import IO;
import ValueIO;
import List;
import String;
import Map;
import util::Math;
import lang::java::m3::Core;
import Extractor;
import metrics::CalculateLOC;


list[str] fileToBlocks(loc f, int n){
	blocks	= [];
	lines = getLOCNoCurlyBraces(f);
	maxI	= size(lines) - n - 1;
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
	clean 	= getLOCNoCurlyBraces(f);
	blocks 	= fileToBlocks(clean,blockSize);
	dups	= duplicates(blocks);
	volume	= (0 | it + size(line) | line <- clean);
	dupVol	= (0 | it + (size(block) * freq) | <block,freq> <- dups);
	perc	= percent(dupVol,volume);
	println("<dupVol>:<volume> = <perc>%");
}

void getDuplication(M3 model, int blockSize){
	project = [f | f <- files(model)];
	alllines = [];
	for (f<-project) {
		alllines= fileToBlocks(f,blockSize);
	}
	println("alllines <alllines>");
	//writeTextValueFile(|project://Series1/src/testExamples/smallsql/database/bla.java|,alllines);
	/*dups	= duplicates(alllines);
	projVol	= (0 | it + size(line) | line <- alllines);
	dupVol	= (0 | it + (size(block) * freq) | <block,freq> <- dups);
	perc	= percent(dupVol,projVol);
	println("<dupVol>:<projVol> = <perc>%");*/
}
void getDuplication_(M3 m){
	project = [*getLOCNoCurlyBraces(l) | l <- files(m)];
	dups	= duplicates(project);
	projVol	= (0 | it + size(line) | line <- project);
	dupVol	= (0 | it + (size(block) * freq) | <block,freq> <- dups);
	perc		= percent(dupVol,projVol);
	println("<dupVol>:<projVol> = <perc>%");
}