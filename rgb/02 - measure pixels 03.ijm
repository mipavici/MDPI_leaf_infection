//Define function
function action(input, output, filename) {
	open(input + filename);
	function newname(label) {
		run("Save XY Coordinates...", "save=["+output+filename+"_"+label+".csv]");
		}

 
	makeRectangle(228, 195, 156, 177);
	newname("A_01");
	makeRectangle(471, 195, 156, 177);
	newname("A_02");
	makeRectangle(228, 414, 156, 177);
	newname("A_03");
	makeRectangle(477, 414, 156, 177);
	newname("A_04");
	makeRectangle(264, 654, 156, 177);
	newname("A_05");
	makeRectangle(480, 648, 156, 177);
	newname("A_06");
	makeRectangle(783, 189, 156, 177);
	newname("A_07");
	makeRectangle(1023, 192, 156, 177);
	newname("A_08");
	makeRectangle(792, 420, 156, 177);
	newname("A_09");
	makeRectangle(1029, 432, 156, 177);
	newname("A_10");
	makeRectangle(774, 666, 156, 177);
	newname("A_11");
	makeRectangle(1023, 663, 156, 177);
	newname("A_12");
	makeRectangle(1350, 198, 156, 177);
	newname("B_01");
	makeRectangle(1569, 198, 156, 177);
	newname("B_02");
	makeRectangle(1347, 435, 156, 177);
	newname("B_03");
	makeRectangle(1578, 435, 156, 177);
	newname("B_04");
	makeRectangle(1350, 657, 156, 177);
	newname("B_05");
	makeRectangle(1569, 666, 156, 177);
	newname("B_06");
	makeRectangle(1875, 186, 156, 177);
	newname("B_07");
	makeRectangle(2112, 189, 156, 177);
	newname("B_08");
	makeRectangle(1890, 411, 156, 177);
	newname("B_09");
	makeRectangle(2115, 420, 156, 177);
	newname("B_10");
	makeRectangle(1887, 666, 156, 177);
	newname("B_11");
	makeRectangle(2118, 663, 156, 177);
	newname("B_12");
	makeRectangle(225, 1041, 156, 177);
	newname("C_01");
	makeRectangle(465, 1029, 156, 177);
	newname("C_02");
	makeRectangle(234, 1257, 156, 177);
	newname("C_03");
	makeRectangle(462, 1257, 156, 177);
	newname("C_04");
	makeRectangle(228, 1500, 156, 177);
	newname("C_05");
	makeRectangle(462, 1494, 156, 177);
	newname("C_06");
	makeRectangle(798, 1041, 156, 177);
	newname("C_07");
	makeRectangle(1014, 1050, 156, 177);
	newname("C_08");
	makeRectangle(789, 1269, 156, 177);
	newname("C_09");
	makeRectangle(1029, 1278, 156, 177);
	newname("C_10");
	makeRectangle(795, 1503, 156, 177);
	newname("C_11");
	makeRectangle(1008, 1518, 156, 177);
	newname("C_12");

}
//-----------------------------------------------


//pahts
input = "your_path/rgb/input/";
output = "your_path/rgb/results_rgb/";

//Process
setBatchMode(true); 
list = getFileList(input);
for (z = 0; z < list.length; z++)
        action(input, output, list[z]);
setBatchMode(false);
