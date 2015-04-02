$(document).ready(function()
{
	var changeDelay = 10000;
	var fadeDelay = 3000;
	var backgroundNum = 13;
	var currentNum = $.randomMax(1, backgroundNum);
	$("<div/>", {
		"id": "bgslider"
	}).appendTo("body");
	$("<img>", {
		"style": "width:100%;position:fixed;top:0;left:0;z-index:-100;",
		"src": "styles/backgrounds/"+ currentNum + ".jpg",
		"id": "img0"
	}).appendTo("#bgslider");
//	$("<img>", {
//		"style": "width:100%;display:none;position:fixed;top:0;left:0;z-index:-50;",
//		"src": "",
//		"id": "img1"
//	}).appendTo("#bgslider");
	$("<div/>", {
		"style": "width:100%;height:100%;background-color:#999;display:none;position:fixed;top:0;left:0;z-index:-50",
		"id": "fade"
	}).appendTo("#bgslider");
	$("<div/>", {
		"style": "float:right;",
		"id": "bgbuttons",
		html: "<a href=\"#\">Prev</a><a href=\"#\">Next</a><a href=\"#\">Stop</a>"
	}).appendTo("#bgslider");

	$("#bgbuttons > a:contains(Prev)").css("text-decoration", "underline");

	var timer = setTimeout(changeImageTwo, changeDelay);

	function changeImageTwo()
	{
		$("#fade").fadeIn(fadeDelay/2);
		upNum();
		$("#img0")
			.delay(fadeDelay)
			.attr("src", "styles/backgrounds/" + currentNum + ".jpg");
		$("#fade").fadeOut(fadeDelay/2);
	}

	function changeImage()
	{
		upNum();
		$("#img1").attr("src", "styles/backgrounds/" + currentNum + ".jpg")
			.fadeIn(fadeDelay)
			.delay(changeDelay);
		upNum();
		$("#img0").attr("src", "styles/backgrounds/" + currentNum + ".jpg");
		$("#img1").fadeOut(fadeDelay);

		var timer = setTimeout(changeImage, changeDelay);
	}

	function upNum()
	{
		currentNum = currentNum == backgroundNum ? 1 : currentNum + 1;
	}
});
