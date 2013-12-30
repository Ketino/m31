$ ->
	hide_unhide = ->
		tmp = $(".newnew").text()
		if tmp == "All"
			$(".news").hide()
			$(".lli").show()
			$(".newnew").text("Only New")	
		else
			$(".news").show()
			$(".lli").hide()
			$(".newnew").text("All")	

	file_selected = ->
		$(".check-file").attr('disabled', false)

	$(".newnew").on('click',hide_unhide)
	$("#audiofile_audio").on('change',file_selected)
	$(".news").hide()
	$(".check-file").attr('disabled','disabled')
