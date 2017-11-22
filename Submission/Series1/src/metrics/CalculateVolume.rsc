module metrics::CalculateVolume
/**
 *
 * @author ighmelene.marlin, rasha.daoud
 *
 */
import IO;
import List;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import Main;
import Extractor;
import metrics::SigModelScale;
import metrics::CalculateUnitSize;

/* Based on java KLOC ranking for Volume of a project, get the sig scale string
*	
*		Rank (Java KLOC)
*		##############
*		 ++   0-66
*		##############
*		 +   66-246
*		##############
*		 o   246-665
*		##############
*		 - 	 655-1,310
*		##############
*		 --	 > 310
*		##############
*/

/* calculate volume based on files in java project */
public int getVolume(M3 m) = (0 | it + getUnitSize(l) | l <- files(m));

/* get sig ranking string based on volume */
public int getVolumeRating(int vol) {
	if(vol <= 66000) return sigScales[0];
	if(vol <= 246000) return sigScales[1];
	if(vol <= 665000) return sigScales[2]; 
	if(vol <= 1310000) return sigScales[3];
	return sigScales[4];
}