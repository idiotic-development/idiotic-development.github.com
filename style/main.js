(function() {
  var enter, fetchContent, goToIndex, leave, leaveIndex, loadContent, transitionIn, transitionOut;

  enter = function() {
    var span;
    if ($(".index").length > 0) {
      return;
    }
    span = $("nav span");
    return span.css("top", $(this).offset().top + (($(this).height() - span.height()) / 2));
  };

  leave = function() {
    var selected;
    selected = $("nav li.selected");
    if (selected.length > 0) {
      return enter.call(selected);
    }
  };

  $(function() {
    $("nav li").hover(enter, leave);
    leave();
    if (Modernizr.history && Modernizr.cssanimations) {
      $("a[href^='/'][target!='_blank']").click(fetchContent);
      if ($(".index").length > 0) {
        return $("nav a").on("click.index", leaveIndex);
      }
    }
  });

  $(window).on("popstate", function() {
    return $.ajax({
      url: document.location,
      dataType: "html",
      success: loadContent
    });
  });

  fetchContent = function(e) {
    var url;
    e.preventDefault();
    url = $(this).attr("href");
    $.ajax({
      url: url,
      dataType: "html",
      success: loadContent
    });
    return history.pushState(null, "", url);
  };

  loadContent = function(html) {
    var bodyClass, bodyTag, content, pageTitle, selectedUrl, start;
    start = html.indexOf("<title>") + 7;
    pageTitle = html.substring(start, html.indexOf("</title>", start));
    start = html.indexOf("class=\"selected\"");
    start = html.indexOf("href=\"", start) + 6;
    selectedUrl = html.substring(start, html.indexOf("\"", start));
    start = html.indexOf("<body");
    bodyTag = html.substring(start, html.indexOf(">", start));
    start = bodyTag.indexOf("class=\"") + 7;
    bodyClass = bodyTag.substring(start, bodyTag.indexOf("\"", start));
    start = html.indexOf("<main");
    start = html.indexOf(">", start) + 1;
    content = html.substring(start, html.indexOf("</main>", start));
    $(".selected").removeClass("selected");
    $("a[href='" + selectedUrl + "']").parent().addClass("selected");
    leave();
    document.title = pageTitle;
    $("main").removeClass("transitionIn");
    if (bodyClass === "index") {
      return goToIndex();
    } else {
      return transitionOut(function() {
        return transitionIn(content, bodyClass);
      });
    }
  };

  goToIndex = function() {
    $("<div>").one("animationend", function() {
      $("main").empty();
      $("body").removeClass().addClass("index");
      return $(this).one("animationend", function() {
        return $(this).remove();
      }).addClass("screenOut");
    }).appendTo("body").addClass("screenIn");
    return $("nav a").on("click.index", leaveIndex);
  };

  leaveIndex = function() {
    $("nav a").off("click.index");
    return $("<div>").appendTo("body").one("animationend", function() {
      $("body").removeClass("index");
      $("nav span").css("transition", "none");
      leave();
      $("nav span").css("transition", "");
      return $(this).one("animationend", function() {
        return $(this).remove();
      }).addClass("screenOut");
    }).addClass("screenIn");
  };

  transitionOut = function(callback) {
    return $("main").one("animationend", function() {
      $(this).remove();
      $("body").removeClass();
      return callback();
    }).addClass("transitionOut");
  };

  transitionIn = function(content, bodyClass) {
    var main;
    return main = $("<main>").html(content).appendTo($("body").addClass(bodyClass)).addClass("transitionIn").find("a[href^='/'][target!='_blank']").click(fetchContent);
  };

}).call(this);
