module metrics::SigModelScale
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import String;
import List;
import Map;

public list[int] sigScales = [5, 4, 3, 2, 1];

public map[int,str] sigScalesMap = (5:"++", 4:"+", 3:"o", 2:"-", 1:"--");