//Define function
function action(input, output, filename) {
	open(input + filename);
	function newname(label) {
		run("Save XY Coordinates...", "save=["+output+filename+"_"+label+".csv]");
		}

 
	makeRectangle(106, 80, 37, 46);
	newname("A_01");
	makeRectangle(161, 80, 37, 46);
	newname("A_02");
	makeRectangle(103, 136, 37, 46);
	newname("A_03");
	makeRectangle(158, 139, 37, 46);
	newname("A_04");
	makeRectangle(104, 199, 37, 46);
	newname("A_05");
	makeRectangle(155, 197, 37, 46);
	newname("A_06");
	makeRectangle(243, 79, 37, 46);
	newname("A_07");
	makeRectangle(299, 78, 37, 46);
	newname("A_08");
	makeRectangle(238, 137, 37, 46);
	newname("A_09");
	makeRectangle(298, 137, 37, 46);
	newname("A_10");
	makeRectangle(239, 200, 37, 46);
	newname("A_11");
	makeRectangle(296, 198, 37, 46);
	newname("A_12");
	makeRectangle(378, 80, 37, 46);
	newname("B_01");
	makeRectangle(434, 77, 37, 46);
	newname("B_02");
	makeRectangle(379, 137, 37, 46);
	newname("B_03");
	makeRectangle(435, 140, 37, 46);
	newname("B_04");
	makeRectangle(376, 201, 37, 46);
	newname("B_05");
	makeRectangle(432, 200, 37, 46);
	newname("B_06");
	makeRectangle(516, 75, 37, 46);
	newname("B_07");
	makeRectangle(569, 79, 37, 46);
	newname("B_08");
	makeRectangle(515, 141, 37, 46);
	newname("B_09");
	makeRectangle(572, 143, 37, 46);
	newname("B_10");
	makeRectangle(515, 201, 37, 46);
	newname("B_11");
	makeRectangle(567, 204, 37, 46);
	newname("B_12");
	makeRectangle(102, 290, 37, 46);
	newname("C_01");
	makeRectangle(154, 293, 37, 46);
	newname("C_02");
	makeRectangle(102, 352, 37, 46);
	newname("C_03");
	makeRectangle(160, 353, 37, 46);
	newname("C_04");
	makeRectangle(107, 413, 37, 46);
	newname("C_05");
	makeRectangle(156, 413, 37, 46);
	newname("C_06");
	makeRectangle(234, 295, 37, 46);
	newname("C_07");
	makeRectangle(296, 300, 37, 46);
	newname("C_08");
	makeRectangle(236, 354, 37, 46);
	newname("C_09");
	makeRectangle(295, 356, 37, 46);
	newname("C_10");
	makeRectangle(236, 412, 37, 46);
	newname("C_11");
	makeRectangle(298, 412, 37, 46);
	newname("C_12");
}
//-----------------------------------------------


//pahts
input = "yourpath/chlf/qym_masked/";
output = "yourpath/chlf/qym_results/";

//Process
setBatchMode(true); 
list = getFileList(input);
for (z = 0; z < list.length; z++)
        action(input, output, list[z]);
setBatchMode(false);
