$(document).ready(function() {
	
	var table = $('#example').DataTable( {
                <!-- "order":['REPORTEDDT', 'desc'], <\!-- disable initial sort-\-> -->
		"order" : [3, 'desc'],
                "iDisplayLength": 25,
		"ajax": "http://tully.dpm.bwh.harvard.edu/api/getSAEs"

		, "columns": [
	{ "data" : "PATID" },
	{ "data" : "EVENT" },
	{ "data" : "RECNO" },
	{ "data" : "REPORTEDDT" }, 
	{ "data" : "STARTDT" },
	{ "data" : "DTMedRecRecieved" },
	{ "data" : "1stReqDT" },
	{ "data" : "1stReqBy" },
	{ "data" : "2ndReqDT" },
	{ "data" : "2ndReqBy" },
	{ "data" : "3rdReqDT" },
	{ "data" : "3rdReqBy" },
	{ "data" : "Notes" },
	{ "data" : "RequestedByMM" },
	{ "data" : "DTSentToMM" },
	{ "data" : "Filed" },
	{ "data" : "ScanID" },
	{ "data" : "BoxNo" }
			      ]
	    } ); <!-- end table -->

	var patid;
	var $username = '<%== getUserName %>' ;

	$('#example tbody').on('dblclick', 'tr', function () {
		patid  = table.row( this ).data()["PATID"];
		recno  = table.row( this ).data()["RECNO"];

		$('#UpdateSAEModalLabel').text("Update SAE for " + patid + " AE # " + recno );
		$( '#DTMedRecRecieved' ).val( table.row( this ).data()["DTMedRecRecieved"] );
		$( '#ClinicianReview' ).val( table.row( this ).data()["ClinicianReview"] );
		$( '#ScanID' ).val( table.row( this ).data()["ScanID"] );
		// <!-- $( '#RequestedByMM' ).val( table.row( this ).data()["RequestedByMM"] );  -->
		//      <!-- console.log( table.row( this ).data()["RequestedByMM"] ); -->
		$( '#RequestedByMM' ).prop('checked', table.row( this ).data()["RequestedByMM"] );
		$( '#DTSentToMM' ).val( table.row( this ).data()["DTSentToMM"] );
		<!-- console.log( table.row( this ).data()["Filed"] ); -->
		$( '#Filed' ).prop('checked', table.row( this ).data()["Filed"] );
		$( '#BoxNo' ).val( table.row( this ).data()["BoxNo"] );
		
		$("#UpdateSAEModal").modal();
		
	    } ); <!-- end dblclick -->
		      
	
	$( ".datepicker" ).datepicker( { dateFormat: "yy-mm-dd" });
	
	
	$('#CreateSAESave').click( function() {
		
		var MyH = {};
		
		MyH['PATID'] =  $( '#PATID' ).val();
		MyH['EVENT'] =  $( '#EVENT' ).val();
		MyH['RECNO'] =  $( '#RECNO' ).val();
		MyH['STARTDT'] =  $( '#STARTDT' ).val();
		MyH['ENDPOINT'] =  $( 'input[name="ENDPOINT"]:checked' ).val();
		MyH['RELATED'] = $( 'input[name="RELATED"]:checked' ).val();
		MyH['UNEXPECTED'] = $( 'input[name="UNEXPECTED"]:checked' ).val();
		MyH['Randomized'] = $( 'input[name="Randomized"]:checked' ).val();
		MyH['DTMedRecRequested'] =  $( '#DTMedRecRequested' ).val();

		if ( $( '#CNotes' ).val().length > 0 ) {
		    MyH['Notes'] = $( '#CNotes' ).val();
	    
		    // // create a log from indexEvent DCC comments
		    // // only if there is a comment
		    // $.ajax({
		    // 	    type: "POST",
		    // 		url: "http://tully.dpm.bwh.harvard.edu/api/createLog",
		    // 		data: "siteid=" + patid.substring(0, 7) +"&" + "bwhStaff=#" + $username + "&message=#"+ patid.substring(8, 12) + " #indexEvent " + $('#DCCcomments').val() + "&hashtag=indexEvent " + patid.substring(8, 12) + " " + $username,
			
		    // 		success: function() {
		    // 		console.log("success!!!");
		    // 	    },
		    // 		});

		} // end if DCCcomments.val.length
	
		//console.log( Object.keys(MyH).map(function(x){return x + "=" + MyH[x];}).join('&') );
		var myData = Object.keys(MyH).map(function(x){return x + "=" + MyH[x];}).join('&');
	
		$.ajax({
			type: "POST",
			    url: "http://tully.dpm.bwh.harvard.edu/api/createSAE",
			    data: myData,
			    success: function()
			    {
				//console.log("success!!!");
				table.ajax.reload();
			    },
			    });
		
		$('#CreateSAEModal').modal('hide');
		
	    }); // 		<!-- end CreateSAESave -->
	    
	
	$('#UpdateSAESave').click( function() {
		
		var MyH = {};
		
		<!-- console.log( patid ); -->
		     <!-- console.log( recno ); -->
			  
		MyH['PATID'] =  patid;
		MyH['RECNO'] =  recno;
		MyH['DTMedRecRecieved'] = $( '#DTMedRecRecieved' ).val();
		MyH['ClinicianReview'] = $( '#ClinicianReview' ).val();
		
		if( $('#RequestedByMM').is(':checked') ) {
		    MyH['RequestedByMM'] = "yes";
		} else {
		    MyH['RequestedByMM'] = "";
		}
		MyH['DTSentToMM'] = $( '#DTSentToMM' ).val();
		
		if( $('#Filed').is(':checked') ) {
		    MyH['Filed'] = "yes";
		} else {
		    MyH['Filed'] = "";
		}
		MyH['ScanID'] = $( '#ScanID' ).val();
		MyH['BoxNo'] = $( '#BoxNo' ).val();
		
		if ( $( '#UNotes' ).val().length > 0 ) {
		    MyH['Notes'] = $( '#UNotes' ).val();
		    
		    // // create a log from indexEvent DCC comments
		    // // only if there is a comment
		    // $.ajax({
		    // 	    type: "POST",
		    // 		url: "http://tully.dpm.bwh.harvard.edu/api/createLog",
		    // 		data: "siteid=" + patid.substring(0, 7) +"&" + "bwhStaff=#" + $username + "&message=#"+ patid.substring(8, 12) + " #indexEvent " + $('#DCCcomments').val() + "&hashtag=indexEvent " + patid.substring(8, 12) + " " + $username,
		    
		    // 		success: function() {
		    // 		console.log("success!!!");
		    // 	    },
		    // 		});
		    
		} // end if DCCcomments.val.length
		
		//console.log( Object.keys(MyH).map(function(x){return x + "=" + MyH[x];}).join('&') );
		var myData = Object.keys(MyH).map(function(x){return x + "=" + MyH[x];}).join('&');
		
		$.ajax({
			type: "POST",
			    url: "http://tully.dpm.bwh.harvard.edu/api/updateSAE",
			    data: myData,
			    success: function()
			    {
				console.log("success!!!");
				table.ajax.reload();
			    }
		    });
		
		$('#UpdateSAEModal').modal('hide');
		
	    }); 		<!-- end UpdateSAESave -->
				     
	
    } );