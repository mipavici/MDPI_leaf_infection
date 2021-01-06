//define function
function action(input, input2, output, filename, filename2) {
	open(input + filename);
	open(input2 + filename2);
	
list3 = getList("image.titles");
var done = false; // used to prematurely terminate loop 
for (i = 0; i < list3.length && !done; i++){
	if (indexOf(list3[i], "Fo") >= 0) {
	selectWindow(list3[i]);
	setAutoThreshold("Default dark");
	run("Create Selection");
	run("Make Inverse");
		done = true;
}
}

list4 = getList("image.titles");
var done = false; // used to prematurely terminate loop 
for (i = 0; i < list4.length && !done; i++) {
	if (indexOf(list4[i], "QY") >= 0) {
	selectWindow(list4[i]);
	run("Restore Selection");
	run("Set...", "value=-100");
	saveAs("Tiff", output + filename);
	done = true;
}
}
	close();
	close();
}

//pahts
input = "yourpath/chlf/masks/";
input2 = "yourpath/chlf/qym/";
output = "yourpath/chlf/qym_masked/";

//Process
setBatchMode(true); 
list = getFileList(input);
list2 = getFileList(input2);
for (i = 0; i < list.length; i++){
        action(input, input2, output, list[i], list2[i]);
}
setBatchMode(false);
