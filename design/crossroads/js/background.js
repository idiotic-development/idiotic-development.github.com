$(function($){
	$.supersized({
		start_slide             :	0,	//Start slide (0 is random)
		random			: 	0,	//Randomize slide order (Ignores start slide)
		slide_interval          :	3000,	//Length between transitions
		transition              :	1, 	//0-None, 1-Fade, 2-Slide Top, 3-Slide Right, 4-Slide Bottom, 5-Slide Left, 6-Carousel Right, 7-Carousel Left
		transition_speed	:	1000,	//Speed of transition
		pause_hover             :	0,		//Pause slideshow on hover
		keyboard_nav            :	0,		//Keyboard navigation on/off
		performance		:	3,		//0-Normal, 1-Hybrid speed/quality, 2-Optimizes image quality, 3-Optimizes transition speed // (Only works for Firefox/IE, not Webkit)
		image_path		:	'styles/img/', //Default image path

		//Size & Position
		min_width		:	0,		//Min width allowed (in pixels)
		min_height		:	0,		//Min height allowed (in pixels)
		vertical_center         :	1,		//Vertically center background
		horizontal_center       :	1,		//Horizontally center background
		fit_portrait         	:	0,		//Portrait images will not exceed browser height
		fit_landscape		:	0,		//Landscape images will not exceed browser width

		//Components
		navigation              :	1,		//Slideshow controls on/off
		thumbnail_navigation    :	0,		//Thumbnail navigation
		slide_counter           :	0,		//Display slide numbers
		slide_captions          :	0,		//Slide caption (Pull from "title" in slides array)
		slides 			:	[		//Slideshow Images
		{image : 'styles/backgrounds/1.jpg'},
		{image : 'styles/backgrounds/2.jpg'},
		{image : 'styles/backgrounds/3.jpg'},
		{image : 'styles/backgrounds/4.jpg'},
		{image : 'styles/backgrounds/5.jpg'},
		{image : 'styles/backgrounds/6.jpg'},
		{image : 'styles/backgrounds/7.jpg'},
		{image : 'styles/backgrounds/8.jpg'},
		{image : 'styles/backgrounds/9.jpg'},
		{image : 'styles/backgrounds/10.jpg'},
		{image : 'styles/backgrounds/11.jpg'},
		{image : 'styles/backgrounds/12.jpg'},
		{image : 'styles/backgrounds/13.jpg'}
						]	
	}); 
});
