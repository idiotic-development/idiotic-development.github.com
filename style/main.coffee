---
---
#
# Menu animation
#

enter = ->
	if ($(".index").length > 0)
		return

	span = $ "nav span"
	span.css "top", $(this).offset().top + (($(this).height() - span.height()) / 2)
leave = ->
	selected = $("nav li.selected")
	if (selected.length > 0)
		enter.call selected


$ ->
	$("nav li").hover enter, leave
	leave()

	if Modernizr.history && Modernizr.cssanimations
		$("a[href^='/'][target!='_blank']").click fetchContent
		if ($(".index").length > 0)
			$("nav a").on "click.index", leaveIndex

#
# Page transitions
#

# Handle back/forward buttons
$(window).on "popstate", ->
	$.ajax(
		url: document.location
		dataType: "html"
		success: loadContent
	)

# Fetch page from server
fetchContent = (e) ->
	e.preventDefault()
	url = $(this).attr "href"
	$.ajax(
		url: url
		dataType: "html"
		success: loadContent
	)
	history.pushState null, "", url

# Extract content from source
loadContent = (html) ->

	start = html.indexOf("<title>") + 7
	pageTitle = html.substring(start, html.indexOf("</title>", start))

	start = html.indexOf "class=\"selected\""
	start = html.indexOf("href=\"", start) + 6
	selectedUrl = html.substring(start, html.indexOf("\"", start))

	start = html.indexOf "<body"
	bodyTag = html.substring(start, html.indexOf(">", start))

	start = bodyTag.indexOf("class=\"") + 7
	bodyClass = bodyTag.substring(start, bodyTag.indexOf("\"", start))

	start = html.indexOf "<main"
	start = html.indexOf(">", start) + 1
	content = html.substring(start, html.indexOf("</main>", start))

	$(".selected").removeClass "selected"
	$("a[href='#{selectedUrl}']").parent().addClass "selected"
	leave()

	document.title = pageTitle

	$("main").removeClass("transitionIn")

	if (bodyClass == "index")
		goToIndex()
	else
		transitionOut ->
			transitionIn content, bodyClass

goToIndex = ->
	$("<div>")
		.one "animationend", ->
			$("main").empty()
			$("body")
				.removeClass()
				.addClass "index"
			$(this)
				.one "animationend", ->
					$(this).remove()
				.addClass "screenOut"
		.appendTo "body"
		.addClass "screenIn"
	$("nav a").on "click.index", leaveIndex

leaveIndex = ->
	$("nav a").off "click.index"
	$("<div>")
		.appendTo "body"
		.one "animationend", ->
			$("body").removeClass "index"
			$("nav span").css "transition", "none"
			leave()
			$("nav span").css "transition", ""
			$(this)
				.one "animationend", ->
					$(this).remove()
				.addClass "screenOut"
		.addClass "screenIn"

# Transition out old content
transitionOut = (callback) ->
	$("main")
		.one "animationend", ->
			$(this).remove()
			$("body").removeClass()
			callback()
		.addClass "transitionOut"

# Transition in new content
transitionIn = (content, bodyClass) ->
	main = $("<main>")
		.html content
		.appendTo ($("body").addClass(bodyClass))
		.addClass "transitionIn"
		.find ("a[href^='/'][target!='_blank']")
			.click fetchContent
