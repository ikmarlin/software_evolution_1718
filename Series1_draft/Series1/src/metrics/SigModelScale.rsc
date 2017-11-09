module metrics::SigModelScale

import IO;
import String;
import List;
import Map;

public list[str] sigScales = ["++", "+", "o", "-", "--"]; 
public map[str, int] sigScalesMap = ("++":1,"+r":2,"o":3,"-":4,"--":5);
public map[str, int] distribution = ("Moderate":1,"High":2,"VeryHigh":3);
//list[tuple[str code, int min, int max]] volumeSigScales = [<"++",0,66000>, <"++",66000,246000>, <"++",246000,665000>, <"++",665000,1310000>]
