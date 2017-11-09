module utils::Tools

import IO;
import String;

public str newLine = "\n";
public str tab = "\t";

public bool isComment(str s){
	if(/((\s|\/*)(\/\*|^(\s*\/*\/)|^(\s+\*)))/ :=s) return true; else return false;
}

public bool isSpace(str s){
	if(/^[\r\t\n ]*$/ := s) return true; else return false;
}

public int countLines(str s){
  count = 1; 
  for(i <- [0 .. size(s)], s[i]==newLine) count+=1;
  return count;
}

public str eraseComments(str s) {
	return visit(s) {
		case /\/\/.*/ => ""
		case /\/\*.*?\*\//s => ""
	}
}

public str eraseEmptyLines(str s) {
    return visit(s) {
        case /^\n[ \t\n]*\n/ => "\n"  
    }
}

