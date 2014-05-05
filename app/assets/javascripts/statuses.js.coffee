# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
	$('.status').hover (event) ->
		$(this).toggleClass("hover")

window.loadedActivities = []
addActivity = (item) ->
  found = false
  i = 0

  while i < window.loadedActivities
    found = true  if window.loadedActivities[i].id is item.id
    i++
  unless found
    window.loadedActivities.push item
    window.loadedActivities.sort (a, b) ->
      returnValue = undefined
      returnValue = -1  if a.created_at > b.created_at
      returnValue = 1  if a.created_at < b.created_at
      returnValue = 0  if a.created_at is b.created_at
      returnValue

  item

renderActivities = ->
  source = $("#activities-template").html()
  template = Handlebars.compile(source)
  html = template(
    activities: window.loadedActivities
    count: window.loadedActivities.length
  )
  $activityFeedLink = $("li#activity-feed")
  $activityFeedLink.empty()
  $activityFeedLink.addClass "dropdown"
  $activityFeedLink.html html
  $activityFeedLink.find("a.dropdown-toggle").dropdown()
  return

pollActivity = ->
  $.ajax
    url: Routes.activities_path(
      format: "json"
      since: window.lastFetch
    )
    type: "GET"
    dataType: "json"
    success: (data) ->
      window.lastFetch = Math.floor((new Date).getTime() / 1000)
      if data.length > 0
        i = 0

        while i < data.length
          addActivity data[i]
          i++
        renderActivities()
      return

  return

Handlebars.registerHelper "activityFeedLink", ->
  new Handlebars.SafeString(Routes.activities_path())

Handlebars.registerHelper "activityLink", ->
  
  #<li><a href="#">{{this.user_id}} {{this.action}} a {{this.targetable_type}} </li>
  activity = this
  link = undefined
  path = undefined
  linkText = activity.targetable_type.toLowerCase()
  switch linkText
    when "status"
      path = Routes.status_path(activity.targetable_id)
    when "album"
      path = Routes.album_path(activity.profile_name, activity.targetable_id)
    when "picture"
      path = Routes.album_picture_path(activity.profile_name, activity.targetable.album_id, activity.targetable_id)
    when "userfriendship"
      path = Routes.profile_path(activity.profile_name)
      linkText = "friend"
  path = "#"  if activity.action is "deleted"
  html = "<li><a href='" + path + "''>" + activity.user_name + " " + activity.action + " a " + linkText + ".</a></li>"
  new Handlebars.SafeString(html)

window.pollInterval = window.setInterval(pollActivity, 5000)
pollActivity()